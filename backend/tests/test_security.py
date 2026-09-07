from app.core.security import Security


def test_password_hash_roundtrip():
    hashed = Security.hash_password("s3cret-password")
    assert hashed != "s3cret-password"
    assert Security.verify_password("s3cret-password", hashed) is True
    assert Security.verify_password("wrong-password", hashed) is False


def test_create_and_verify_token():
    token = Security.create_access_token(user_id=42)
    payload = Security.verify_token(token)
    assert payload is not None
    assert payload["sub"] == "42"


def test_verify_token_rejects_garbage():
    assert Security.verify_token("not-a-jwt") is None
