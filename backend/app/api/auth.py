from datetime import datetime
from typing import Literal

import redis.asyncio as redis
from fastapi import APIRouter, Depends, HTTPException, Request
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.dependencies import get_current_user
from app.core.security import Security
from app.db.database import get_db
from app.services.attestation_service import AttestationService
from app.services.auth_service import AuthService
from app.services.sms_service import send_otp_sms


router = APIRouter(prefix="/auth", tags=["Authentication"])
redis_client = redis.from_url(
    "redis://localhost:6379",
    decode_responses=True,
)


class OtpRequest(BaseModel):
    phone: str = Field(min_length=10, max_length=20)


class OtpVerification(BaseModel):
    phone: str = Field(min_length=10, max_length=20)
    otp: str = Field(min_length=6, max_length=6)
    device_id: str = Field(min_length=16, max_length=200)
    system_device_id: str | None = Field(
        default=None,
        min_length=8,
        max_length=255,
    )
    platform: Literal["mobile", "web"] = "mobile"
    attestation_provider: str | None = Field(default=None, max_length=32)
    attestation_token: str | None = Field(
        default=None,
        max_length=10000,
    )
    attestation_key_id: str | None = Field(default=None, max_length=255)


@router.post("/request-otp")
async def request_otp(payload: OtpRequest):
    phone = AuthService.normalize_phone(payload.phone)
    rate_key = f"otp-rate:{phone}"
    requests_in_window = await redis_client.incr(rate_key)
    if requests_in_window == 1:
        await redis_client.expire(rate_key, 600)
    if requests_in_window > 5:
        raise HTTPException(
            status_code=429,
            detail="تعداد درخواست‌ها زیاد است؛ بعداً دوباره تلاش کنید",
        )

    otp = AuthService.generate_otp()
    await redis_client.setex(f"otp:{phone}", 120, otp)
    await redis_client.delete(f"otp-attempts:{phone}")
    send_otp_sms(phone, otp)
    return {"message": "کد تأیید ارسال شد"}


@router.post("/verify-otp")
async def verify_otp(
    payload: OtpVerification,
    request: Request,
    db: Session = Depends(get_db),
):
    phone = AuthService.normalize_phone(payload.phone)
    stored = await redis_client.get(f"otp:{phone}")

    if stored is None or stored != payload.otp:
        attempts_key = f"otp-attempts:{phone}"
        attempts = await redis_client.incr(attempts_key)
        if attempts == 1:
            await redis_client.expire(attempts_key, 120)
        if attempts >= 5:
            await redis_client.delete(f"otp:{phone}")
        raise HTTPException(
            status_code=429 if attempts >= 5 else 400,
            detail=(
                "تعداد تلاش‌ها بیش از حد مجاز است؛ کد جدید درخواست کنید"
                if attempts >= 5
                else "کد تأیید اشتباه یا منقضی شده است"
            ),
        )

    if payload.platform == "web" and (
        not payload.system_device_id
        or payload.attestation_provider != "web_browser"
    ):
        raise HTTPException(
            status_code=403,
            detail="شناسه مرورگر برای احراز هویت وب الزامی است",
        )

    attestation_verified = False
    if (
        payload.attestation_provider == "play_integrity"
        and payload.attestation_token
        and payload.system_device_id
    ):
        expected_hash = AttestationService.request_hash(
            phone,
            payload.device_id,
            payload.system_device_id,
        )
        attestation_verified = AttestationService.verify_play_integrity(
            payload.attestation_token,
            expected_hash,
        )

    if settings.REQUIRE_DEVICE_ATTESTATION and payload.platform != "web" and (
        not payload.system_device_id
        or payload.attestation_provider not in {"play_integrity", "app_attest"}
        or not payload.attestation_token
        or not attestation_verified
    ):
        raise HTTPException(
            status_code=403,
            detail="تأیید اصالت دستگاه برای ثبت‌نام الزامی است",
        )

    await redis_client.delete(f"otp:{phone}")
    client_ip = request.client.host if request.client else "unknown"
    user_agent = request.headers.get("user-agent")
    user = AuthService.register_user(
        db,
        phone=phone,
        device_id=payload.device_id,
        ip_address=client_ip,
        user_agent=user_agent,
        system_device_id=payload.system_device_id,
        platform=payload.platform,
        attestation_provider=payload.attestation_provider,
        attestation_token=payload.attestation_token,
        attestation_key_id=payload.attestation_key_id,
    )
    token = Security.create_access_token(user.id)
    return {
        "access_token": token,
        "user": {"id": user.id, "phone": user.phone},
    }


@router.get("/me")
async def get_me(user=Depends(get_current_user)):
    now = datetime.utcnow()
    subscription_active = bool(
        user.subscription_expires_at
        and user.subscription_expires_at > now
    )
    return {
        "id": user.id,
        "phone": user.phone,
        "full_name": user.full_name,
        "subscription_active": subscription_active,
        "subscription_expires_at": (
            user.subscription_expires_at.isoformat()
            if user.subscription_expires_at
            else None
        ),
    }
