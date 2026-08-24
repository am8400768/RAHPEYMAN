import hashlib
import random
import re

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import Security
from app.models.device_registration import DeviceRegistration
from app.models.user import User


class AuthService:
    @staticmethod
    def generate_otp() -> str:
        return f"{random.SystemRandom().randint(100000, 999999):06d}"

    @staticmethod
    def normalize_phone(phone: str) -> str:
        value = re.sub(r"[\s\-()]", "", phone.strip())
        if value.startswith("+98"):
            value = "0" + value[3:]
        elif value.startswith("0098"):
            value = "0" + value[4:]

        if not re.fullmatch(r"09\d{9}", value):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="شماره موبایل معتبر نیست",
            )
        return value

    @staticmethod
    def hash_device_id(device_id: str) -> str:
        value = device_id.strip()
        if len(value) < 16 or len(value) > 200:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="شناسه دستگاه معتبر نیست",
            )
        return hashlib.sha256(value.encode("utf-8")).hexdigest()

    @staticmethod
    def hash_optional(value: str | None) -> str | None:
        if not value:
            return None
        return hashlib.sha256(value.strip().encode("utf-8")).hexdigest()

    @staticmethod
    def register_user(
        db: Session,
        phone: str,
        device_id: str,
        ip_address: str,
        user_agent: str | None = None,
        full_name: str | None = None,
        system_device_id: str | None = None,
        platform: str = "mobile",
        attestation_provider: str | None = None,
        attestation_token: str | None = None,
        attestation_key_id: str | None = None,
    ) -> User:
        phone = AuthService.normalize_phone(phone)
        device_hash = AuthService.hash_device_id(device_id)
        system_device_hash = AuthService.hash_optional(system_device_id)

        user = db.query(User).filter(User.phone == phone).first()
        installation = (
            db.query(DeviceRegistration)
            .filter(DeviceRegistration.device_id_hash == device_hash)
            .first()
        )
        system_device = None
        if system_device_hash:
            system_device = (
                db.query(DeviceRegistration)
                .filter(
                    DeviceRegistration.system_device_id_hash
                    == system_device_hash
                )
                .first()
            )

        known_devices = [
            item for item in (installation, system_device) if item is not None
        ]
        if any(user is None or item.user_id != user.id for item in known_devices):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="این دستگاه قبلاً برای حساب دیگری استفاده شده است",
            )

        if user is None:
            user = User(phone=phone, full_name=full_name)
            db.add(user)
            db.flush()

        device = system_device or installation
        if device is None:
            device = DeviceRegistration(
                user_id=user.id,
                device_id_hash=device_hash,
                system_device_id_hash=system_device_hash,
                platform=platform,
                attestation_provider=attestation_provider,
                attestation_token_hash=AuthService.hash_optional(
                    attestation_token
                ),
                attestation_key_id=attestation_key_id,
                registration_ip=ip_address,
                last_ip=ip_address,
                user_agent=user_agent,
            )
            db.add(device)
        else:
            device.device_id_hash = device_hash
            device.last_ip = ip_address
            device.user_agent = user_agent
            if system_device_hash:
                device.system_device_id_hash = system_device_hash
            device.platform = platform
            if attestation_provider:
                device.attestation_provider = attestation_provider
            if attestation_token:
                device.attestation_token_hash = AuthService.hash_optional(
                    attestation_token
                )
            if attestation_key_id:
                device.attestation_key_id = attestation_key_id

        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def login_with_password(
        db: Session,
        phone: str,
        password: str,
    ) -> User | None:
        user = db.query(User).filter(User.phone == phone).first()
        if not user or not user.password_hash:
            return None
        if not Security.verify_password(password, user.password_hash):
            return None
        return user
