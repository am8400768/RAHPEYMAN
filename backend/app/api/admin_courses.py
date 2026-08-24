from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_admin
from app.db.database import get_db
from app.models.course import Course
from app.models.video import Video
from app.services.video_service import VideoService


router = APIRouter(prefix="/admin/courses", tags=["Admin Courses"])


class CourseCreatePayload(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    description: str | None = Field(default=None, max_length=5000)
    price: int = Field(default=0, ge=0)
    cover_image_url: str | None = Field(default=None, max_length=500)


class CourseUpdatePayload(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=200)
    description: str | None = Field(default=None, max_length=5000)
    price: int | None = Field(default=None, ge=0)
    cover_image_url: str | None = Field(default=None, max_length=500)
    is_active: bool | None = None


class VideoCreatePayload(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    s3_key: str = Field(min_length=1, max_length=500)
    description: str | None = Field(default=None, max_length=500)
    order: int = Field(default=0, ge=0)
    duration_seconds: int | None = Field(default=None, ge=0)
    is_preview: bool = False


class VideoUpdatePayload(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=200)
    description: str | None = Field(default=None, max_length=500)
    order: int | None = Field(default=None, ge=0)
    duration_seconds: int | None = Field(default=None, ge=0)
    is_preview: bool | None = None
    is_active: bool | None = None


@router.get("")
async def list_admin_courses(
    _: object = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    courses = db.query(Course).order_by(Course.id.desc()).all()
    return [_course_payload(course) for course in courses]


@router.post("", status_code=201)
async def create_course(
    payload: CourseCreatePayload,
    _: object = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    course = Course(
        title=payload.title.strip(),
        description=payload.description,
        price=payload.price,
        cover_image_url=payload.cover_image_url,
        is_active=True,
    )
    db.add(course)
    db.commit()
    db.refresh(course)
    return _course_payload(course)


@router.patch("/{course_id}")
async def update_course(
    course_id: int,
    payload: CourseUpdatePayload,
    _: object = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    course = _get_course(course_id, db)
    changes = payload.model_dump(exclude_unset=True)
    if "title" in changes and changes["title"] is not None:
        changes["title"] = changes["title"].strip()
    for key, value in changes.items():
        setattr(course, key, value)
    db.commit()
    db.refresh(course)
    return _course_payload(course)


@router.delete("/{course_id}")
async def deactivate_course(
    course_id: int,
    _: object = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    course = _get_course(course_id, db)
    course.is_active = False
    db.commit()
    return {"message": "دوره غیرفعال شد"}


@router.post("/{course_id}/videos", status_code=201)
async def create_video(
    course_id: int,
    payload: VideoCreatePayload,
    _: object = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    course = _get_course(course_id, db)
    video = Video(
        course_id=course.id,
        title=payload.title.strip(),
        description=payload.description,
        order=payload.order,
        s3_key=payload.s3_key.strip(),
        duration_seconds=payload.duration_seconds,
        is_preview=payload.is_preview,
        is_active=True,
    )
    db.add(video)
    db.commit()
    db.refresh(video)
    return _video_payload(video)


@router.post("/{course_id}/videos/upload", status_code=201)
async def upload_video(
    course_id: int,
    title: str = Form(..., min_length=1, max_length=200),
    description: str | None = Form(default=None, max_length=500),
    order: int = Form(default=0, ge=0),
    duration_seconds: int | None = Form(default=None, ge=0),
    is_preview: bool = Form(default=False),
    file: UploadFile = File(...),
    _: object = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    course = _get_course(course_id, db)
    suffix = Path(file.filename or "").suffix.lower()
    if suffix not in {".mp4", ".mov", ".m4v", ".webm"}:
        raise HTTPException(
            status_code=415,
            detail="فرمت ویدئو پشتیبانی نمی‌شود",
        )

    try:
        s3_key = VideoService().upload_video(
            file.file,
            f"{uuid4().hex}{suffix}",
            course.id,
        )
    except Exception as error:
        raise HTTPException(
            status_code=503,
            detail=f"آپلود ویدئو انجام نشد: {error}",
        ) from error
    finally:
        await file.close()

    video = Video(
        course_id=course.id,
        title=title.strip(),
        description=description,
        order=order,
        s3_key=s3_key,
        duration_seconds=duration_seconds,
        is_preview=is_preview,
        is_active=True,
    )
    db.add(video)
    db.commit()
    db.refresh(video)
    return _video_payload(video)


@router.patch("/{course_id}/videos/{video_id}")
async def update_video(
    course_id: int,
    video_id: int,
    payload: VideoUpdatePayload,
    _: object = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    _get_course(course_id, db)
    video = _get_video(course_id, video_id, db)
    changes = payload.model_dump(exclude_unset=True)
    if "title" in changes and changes["title"] is not None:
        changes["title"] = changes["title"].strip()
    for key, value in changes.items():
        setattr(video, key, value)
    db.commit()
    db.refresh(video)
    return _video_payload(video)


@router.delete("/{course_id}/videos/{video_id}")
async def deactivate_video(
    course_id: int,
    video_id: int,
    _: object = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    _get_course(course_id, db)
    video = _get_video(course_id, video_id, db)
    video.is_active = False
    db.commit()
    return {"message": "ویدئو غیرفعال شد"}


def _get_course(course_id: int, db: Session) -> Course:
    course = db.query(Course).filter(Course.id == course_id).first()
    if course is None:
        raise HTTPException(status_code=404, detail="دوره پیدا نشد")
    return course


def _get_video(course_id: int, video_id: int, db: Session) -> Video:
    video = (
        db.query(Video)
        .filter(Video.id == video_id, Video.course_id == course_id)
        .first()
    )
    if video is None:
        raise HTTPException(status_code=404, detail="ویدئو پیدا نشد")
    return video


def _course_payload(course: Course) -> dict:
    return {
        "id": course.id,
        "title": course.title,
        "description": course.description,
        "price": course.price,
        "cover_image_url": course.cover_image_url,
        "is_active": bool(course.is_active),
        "videos": [_video_payload(video) for video in course.videos],
    }


def _video_payload(video: Video) -> dict:
    return {
        "id": video.id,
        "course_id": video.course_id,
        "title": video.title,
        "description": video.description,
        "order": video.order,
        "s3_key": video.s3_key,
        "duration_seconds": video.duration_seconds,
        "is_preview": bool(video.is_preview),
        "is_active": bool(video.is_active),
    }
