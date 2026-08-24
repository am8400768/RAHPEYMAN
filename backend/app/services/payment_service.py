import requests

from app.core.config import settings


class PaymentService:
    @staticmethod
    def create_payment(amount: int, callback_url: str) -> dict | None:
        if not settings.ZARINPAL_MERCHANT_ID:
            return None

        response = requests.post(
            "https://api.zarinpal.com/pg/v4/payment/request.json",
            json={
                "merchant_id": settings.ZARINPAL_MERCHANT_ID,
                "amount": amount,
                "callback_url": callback_url,
                "description": "اشتراک رهپیمان",
            },
            timeout=20,
        )
        data = response.json()
        if data.get("data", {}).get("code") != 100:
            return None

        authority = data["data"]["authority"]
        return {
            "authority": authority,
            "url": data["data"].get("url")
            or f"https://www.zarinpal.com/pg/StartPay/{authority}",
        }

    @staticmethod
    def verify_payment(amount: int, authority: str) -> dict | None:
        response = requests.post(
            "https://api.zarinpal.com/pg/v4/payment/verify.json",
            json={
                "merchant_id": settings.ZARINPAL_MERCHANT_ID,
                "amount": amount,
                "authority": authority,
            },
            timeout=20,
        )
        data = response.json().get("data", {})
        if data.get("code") not in {100, 101}:
            return None
        return {
            "ref_id": str(data.get("ref_id", "")),
            "code": data.get("code"),
        }
