import requests
from app.core.config import settings

def send_otp_sms(phone: str, otp: str) -> bool:
    """ارسال پیامک با Kavenegar"""
    url = f"https://api.kavenegar.com/v1/{settings.KAVENEGAR_API_KEY}/verify/lookup.json"
    payload = {
        "receptor": phone,
        "token": otp,
        "template": "rahpeyman-otp"
    }
    response = requests.post(url, data=payload)
    return response.status_code == 200