from datetime import datetime, timedelta
from html import escape

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.payment import Payment
from app.models.user import User
from app.services.payment_service import PaymentService


router = APIRouter(prefix="/payments", tags=["Payments"])


@router.post("/subscription")
async def create_subscription_payment(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not settings.ZARINPAL_MERCHANT_ID:
        return {
            "error": "payment_not_configured",
            "message": "درگاه پرداخت روی سرور تنظیم نشده است",
        }

    payment = Payment(
        user_id=user.id,
        authority=f"creating-{user.id}-{int(datetime.utcnow().timestamp())}",
        amount=settings.SUBSCRIPTION_PRICE,
        status="creating",
    )
    db.add(payment)
    db.flush()

    result = PaymentService.create_payment(
        amount=payment.amount,
        callback_url=settings.ZARINPAL_CALLBACK_URL,
    )
    if not result:
        db.rollback()
        return {
            "error": "payment_request_failed",
            "message": "ایجاد درخواست پرداخت ناموفق بود",
        }

    payment.authority = result["authority"]
    payment.status = "pending"
    db.commit()
    return {
        "payment_id": payment.id,
        "authority": payment.authority,
        "payment_url": result["url"],
        "amount": payment.amount,
    }


@router.get("/zarinpal/callback", response_class=HTMLResponse)
async def zarinpal_callback(
    request: Request,
    db: Session = Depends(get_db),
):
    status = request.query_params.get("Status", "").upper()
    authority = request.query_params.get("Authority", "")
    payment = (
        db.query(Payment)
        .filter(Payment.authority == authority)
        .with_for_update()
        .first()
    )

    if payment is None:
        return _payment_page(False, "تراکنش پیدا نشد.")

    if payment.status == "paid":
        return _payment_page(
            True,
            f"پرداخت قبلاً ثبت شده است. کد پیگیری: {escape(payment.ref_id or '')}",
        )

    if status != "OK":
        payment.status = "cancelled"
        db.commit()
        return _payment_page(False, "پرداخت توسط کاربر لغو شد.")

    verification = PaymentService.verify_payment(
        amount=payment.amount,
        authority=payment.authority,
    )
    if not verification:
        payment.status = "failed"
        db.commit()
        return _payment_page(False, "تأیید پرداخت از زرین‌پال ناموفق بود.")

    user = (
        db.query(User)
        .filter(User.id == payment.user_id)
        .with_for_update()
        .first()
    )
    if user is None:
        payment.status = "failed"
        db.commit()
        return _payment_page(False, "کاربر تراکنش پیدا نشد.")

    now = datetime.utcnow()
    base = (
        user.subscription_expires_at
        if user.subscription_expires_at
        and user.subscription_expires_at > now
        else now
    )
    user.subscription_expires_at = base + timedelta(
        days=settings.SUBSCRIPTION_DAYS
    )
    payment.status = "paid"
    payment.ref_id = verification["ref_id"]
    payment.paid_at = now
    db.commit()
    return _payment_page(
        True,
        f"پرداخت موفق بود. کد پیگیری: {escape(payment.ref_id or '')}",
    )


def _payment_page(success: bool, message: str) -> HTMLResponse:
    color = "#16803c" if success else "#b42318"
    title = "پرداخت موفق" if success else "پرداخت ناموفق"
    return HTMLResponse(
        f"""<!doctype html>
<html lang="fa" dir="rtl">
<meta charset="utf-8">
<title>{title}</title>
<body style="font-family:sans-serif;text-align:center;padding:48px">
<h2 style="color:{color}">{title}</h2>
<p>{message}</p>
<p>اکنون می‌توانید به برنامه بازگردید.</p>
</body>
</html>"""
    )
