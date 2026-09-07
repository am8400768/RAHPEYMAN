from fastapi import APIRouter

from app.core.config import settings

router = APIRouter(tags=["Health"])


@router.get("/health")
async def health() -> dict:
    return {
        "status": "ok",
        "service": "rahpeyman-api",
        "version": "1.0.0",
        "env": settings.ENV,
    }
