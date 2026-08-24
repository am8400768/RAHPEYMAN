from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import admin_courses, auth, courses, payments
from app.core.config import settings
from app.db.database import Base, engine
from app.models.device_registration import DeviceRegistration  # noqa: F401
from app.models.payment import Payment  # noqa: F401

app = FastAPI(title="Rahpeyman API", version="1.0.0")

cors_origins = [
    origin.strip()
    for origin in settings.CORS_ORIGINS.split(",")
    if origin.strip()
]
if not cors_origins:
    cors_origins = ["*"]


@app.on_event("startup")
def create_database_tables():
    Base.metadata.create_all(bind=engine)

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=cors_origins != ["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(courses.router)
app.include_router(payments.router)
app.include_router(admin_courses.router)

@app.get("/")
async def root():
    return {"message": "Rahpeyman API"}
