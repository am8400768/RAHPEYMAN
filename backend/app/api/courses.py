from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.course import Course
from app.models.user import User
from app.models.video import Video
from app.services.video_service import VideoService


router = APIRouter(prefix="/courses", tags=["Courses"])


def has_active_subscription(user: User) -> bool:
    return bool(
        user.subscription_expires_at
        and user.subscription_expires_at > datetime.utcnow()
    )


@router.get("/")
async def list_courses(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    has_access = has_active_subscription(user)
    courses = (
        db.query(Course)
        .filter(Course.is_active.is_(True))
        .order_by(Course.id.desc())
        .all()
    )
    return [
        {
            "id": course.id,
            "title": course.title,
            "description": course.description,
            "price": course.price,
            "cover_image_url": course.cover_image_url,
            "has_access": has_access,
        }
        for course in courses
    ]


@router.get("/{course_id}/videos")
async def list_videos(
    course_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.is_active.is_(True),
    ).first()
    if course is None:
        raise HTTPException(404, "دوره پیدا نشد")

    query = db.query(Video).filter(
        Video.course_id == course_id,
        Video.is_active.is_(True),
    )
    if not has_active_subscription(user):
        query = query.filter(Video.is_preview.is_(True))

    videos = query.order_by(Video.order.asc(), Video.id.asc()).all()
    return [
        {
            "id": video.id,
            "title": video.title,
            "description": video.description,
            "duration_seconds": video.duration_seconds,
            "is_preview": bool(video.is_preview),
            "locked": not bool(video.is_preview) and not has_active_subscription(user),
        }
        for video in videos
    ]


@router.get("/videos/{video_id}/stream")
async def get_video_stream(
    video_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    video = db.query(Video).filter(
        Video.id == video_id,
        Video.is_active.is_(True),
    ).first()
    if video is None:
        raise HTTPException(404, "ویدئو پیدا نشد")

    if not video.is_preview and not has_active_subscription(user):
        raise HTTPException(
            403,
            "برای مشاهده این ویدئو باید اشتراک فعال داشته باشید",
        )

    stream_url = VideoService().generate_signed_url(video.s3_key)
    return {
        "stream_url": stream_url,
        "duration": video.duration_seconds,
    }
