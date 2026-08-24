from sqlalchemy import Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.database import Base


class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    authority = Column(String(64), unique=True, nullable=False, index=True)
    amount = Column(Integer, nullable=False)
    status = Column(String(20), nullable=False, default="pending")
    ref_id = Column(String(64), nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    paid_at = Column(DateTime, nullable=True)

    user = relationship("User", back_populates="payments")
