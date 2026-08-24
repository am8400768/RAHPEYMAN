import hashlib
import os

import requests

from app.core.config import settings


class AttestationService:
    @staticmethod
    def request_hash(phone: str, device_id: str, system_device_id: str) -> str:
        value = f"{phone}|{device_id}|{system_device_id}"
        return hashlib.sha256(value.encode("utf-8")).hexdigest()

    @staticmethod
    def verify_play_integrity(
        token: str,
        expected_request_hash: str,
    ) -> bool:
        """Decode and validate a Play Integrity token when server credentials exist."""
        if not settings.GOOGLE_APPLICATION_CREDENTIALS:
            return False

        try:
            from google.auth.transport.requests import Request
            from google.oauth2 import service_account

            credentials = service_account.Credentials.from_service_account_file(
                settings.GOOGLE_APPLICATION_CREDENTIALS,
                scopes=["https://www.googleapis.com/auth/playintegrity"],
            )
            credentials.refresh(Request())
            response = requests.post(
                "https://playintegrity.googleapis.com/v1/"
                f"{settings.ANDROID_PACKAGE_NAME}:decodeIntegrityToken",
                headers={
                    "Authorization": f"Bearer {credentials.token}",
                    "Content-Type": "application/json",
                },
                json={"integrity_token": token},
                timeout=15,
            )
            response.raise_for_status()
            payload = response.json().get("tokenPayloadExternal", {})
            request_details = payload.get("requestDetails", {})
            app_integrity = payload.get("appIntegrity", {})
            device_integrity = payload.get("deviceIntegrity", {})

            request_hash_ok = (
                request_details.get("requestHash") == expected_request_hash
            )
            app_ok = (
                app_integrity.get("appRecognitionVerdict") == "PLAY_RECOGNIZED"
            )
            device_verdicts = device_integrity.get(
                "deviceRecognitionVerdict", []
            )
            device_ok = any(
                verdict in {"MEETS_DEVICE_INTEGRITY", "MEETS_STRONG_INTEGRITY"}
                for verdict in device_verdicts
            )
            return request_hash_ok and app_ok and device_ok
        except Exception:
            return False
