import pytest
from fastapi import HTTPException

from app.services.auth_service import AuthService


@pytest.mark.parametrize(
    "raw,normalized",
    [
        ("09121234567", "09121234567"),
        ("+98 912 123 4567", "09121234567"),
        ("00989121234567", "09121234567"),
        ("0912-123-4567", "09121234567"),
        ("(0912) 1234567", "09121234567"),
    ],
)
def test_normalize_phone_valid(raw, normalized):
    assert AuthService.normalize_phone(raw) == normalized


@pytest.mark.parametrize("raw", ["12345", "0912345678", "02111111111", ""])
def test_normalize_phone_invalid(raw):
    with pytest.raises(HTTPException) as exc:
        AuthService.normalize_phone(raw)
    assert exc.value.status_code == 422


def test_generate_otp_format():
    for _ in range(50):
        otp = AuthService.generate_otp()
        assert len(otp) == 6
        assert otp.isdigit()


def test_hash_device_id():
    hashed = AuthService.hash_device_id("a" * 32)
    assert len(hashed) == 64
    # Same input -> same hash, different input -> different hash.
    assert hashed == AuthService.hash_device_id("a" * 32)
    assert hashed != AuthService.hash_device_id("b" * 32)


def test_hash_device_id_rejects_short():
    with pytest.raises(HTTPException):
        AuthService.hash_device_id("short")
