from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String(15), unique=True, index=True, nullable=False)
    email = Column(String(100), nullable=True)
    full_name = Column(String(100), nullable=True)
    password_hash = Column(String(255), nullable=True)  # برای رمز عبور (اختیاری)
    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)
    subscription_expires_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())
    device_registrations = relationship(
        "DeviceRegistration",
        back_populates="user",
        cascade="all, delete-orphan",
    )
    payments = relationship(
        "Payment",
        back_populates="user",
        cascade="all, delete-orphan",
    )
