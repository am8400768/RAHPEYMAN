import os
from pathlib import Path

from dotenv import load_dotenv
from pydantic_settings import BaseSettings

load_dotenv(Path(__file__).resolve().parents[2] / ".env")

WEAK_JWT_SECRETS = {"", "your-secret-key-change-this", "change-me", "secret"}


class Settings(BaseSettings):
    ENV: str = os.getenv("ENV", "development")
    JWT_SECRET: str = os.getenv("JWT_SECRET", "")
    JWT_EXPIRE_DAYS: int = 7

    REQUIRE_DEVICE_ATTESTATION: bool = os.getenv(
        "REQUIRE_DEVICE_ATTESTATION", "false"
    ).lower() == "true"
    GOOGLE_CLOUD_PROJECT_NUMBER: str = os.getenv(
        "GOOGLE_CLOUD_PROJECT_NUMBER", ""
    )
    ANDROID_PACKAGE_NAME: str = os.getenv(
        "ANDROID_PACKAGE_NAME", "ir.rahpeyman.app"
    )
    GOOGLE_APPLICATION_CREDENTIALS: str = os.getenv(
        "GOOGLE_APPLICATION_CREDENTIALS", ""
    )

    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://user:pass@localhost:5432/rahpeyman",
    )
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379")
    CORS_ORIGINS: str = os.getenv("CORS_ORIGINS", "*")

    AWS_ACCESS_KEY: str = os.getenv("AWS_ACCESS_KEY", "")
    AWS_SECRET_KEY: str = os.getenv("AWS_SECRET_KEY", "")
    AWS_REGION: str = os.getenv("AWS_REGION", "us-east-1")
    S3_BUCKET_NAME: str = os.getenv("S3_BUCKET_NAME", "rahpeyman-videos")
    CLOUDFRONT_DOMAIN: str = os.getenv("CLOUDFRONT_DOMAIN", "")
    CLOUDFRONT_KEY_PAIR_ID: str = os.getenv("CLOUDFRONT_KEY_PAIR_ID", "")
    CLOUDFRONT_PRIVATE_KEY: str = os.getenv("CLOUDFRONT_PRIVATE_KEY", "")

    ZARINPAL_MERCHANT_ID: str = os.getenv("ZARINPAL_MERCHANT_ID", "")
    SUBSCRIPTION_PRICE: int = int(os.getenv("SUBSCRIPTION_PRICE", "1000000"))
    ZARINPAL_CALLBACK_URL: str = os.getenv(
        "ZARINPAL_CALLBACK_URL",
        "https://api.rahpeyman.ir/payments/zarinpal/callback",
    )
    SUBSCRIPTION_DAYS: int = int(os.getenv("SUBSCRIPTION_DAYS", "30"))

    KAVENEGAR_API_KEY: str = os.getenv("KAVENEGAR_API_KEY", "")

    def validate(self) -> "Settings":
        """Fail fast in production when security-critical values are missing."""
        is_production = self.ENV.lower() in {"production", "prod"}
        if is_production and self.JWT_SECRET in WEAK_JWT_SECRETS:
            raise RuntimeError(
                "JWT_SECRET must be set to a strong random value in production."
            )
        if is_production and len(self.JWT_SECRET) < 32:
            raise RuntimeError("JWT_SECRET must be at least 32 characters in production.")
        if self.ENV.lower() not in {"development", "production", "prod", "test"}:
            raise RuntimeError(f"Unknown ENV value: {self.ENV!r}")
        return self


settings = Settings().validate()
