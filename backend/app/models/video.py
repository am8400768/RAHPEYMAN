from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.database import Base

class Video(Base):
    __tablename__ = "videos"
    
    id = Column(Integer, primary_key=True)
    course_id = Column(Integer, ForeignKey("courses.id"))
    title = Column(String(200), nullable=False)
    description = Column(String(500))
    order = Column(Integer, default=0)
    s3_key = Column(String(500), nullable=False)  # مسیر در S3
    duration_seconds = Column(Integer)
    is_preview = Column(Boolean, default=False)  # رایگان؟
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, server_default=func.now())
    
    course = relationship("Course", back_populates="videos")