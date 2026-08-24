from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.database import Base


class DeviceRegistration(Base):
    """Links one app installation to the first account registered on it."""

    __tablename__ = "device_registrations"
    __table_args__ = (
        UniqueConstraint("device_id_hash", name="uq_device_registrations_device"),
        UniqueConstraint(
            "system_device_id_hash",
            name="uq_device_registrations_system_device",
        ),
    )

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    device_id_hash = Column(String(64), nullable=False, index=True)
    system_device_id_hash = Column(String(64), nullable=True, index=True)
    platform = Column(String(16), nullable=False, default="mobile")
    attestation_provider = Column(String(32), nullable=True)
    attestation_token_hash = Column(String(64), nullable=True)
    attestation_key_id = Column(String(255), nullable=True)
    registration_ip = Column(String(45), nullable=False)
    last_ip = Column(String(45), nullable=False)
    user_agent = Column(String(500), nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    last_seen_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    user = relationship("User", back_populates="device_registrations")
