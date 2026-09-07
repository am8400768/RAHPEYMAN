from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import admin_courses, auth, courses, health, payments
from app.core.config import settings
from app.db.database import Base, engine
from app.models.course import Course  # noqa: F401
from app.models.device_registration import DeviceRegistration  # noqa: F401
from app.models.payment import Payment  # noqa: F401
from app.models.user import User  # noqa: F401
from app.models.video import Video  # noqa: F401


@asynccontextmanager
async def lifespan(_: FastAPI):
    # NOTE: create_all is only a convenience for development. Production schema
    # changes must go through Alembic (see backend/alembic).
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(title="Rahpeyman API", version="1.0.0", lifespan=lifespan)

cors_origins = [
    origin.strip()
    for origin in settings.CORS_ORIGINS.split(",")
    if origin.strip()
]
if not cors_origins:
    cors_origins = ["*"]


app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=cors_origins != ["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(auth.router)
app.include_router(courses.router)
app.include_router(payments.router)
app.include_router(admin_courses.router)


@app.get("/")
async def root():
    return {"message": "Rahpeyman API"}
