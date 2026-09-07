"""Initial schema: users, device_registrations, courses, videos, payments

Revision ID: 001_initial_tables
Revises:
Create Date: 2025-09-07

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "001_initial_tables"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("phone", sa.String(length=15), nullable=False),
        sa.Column("email", sa.String(length=100), nullable=True),
        sa.Column("full_name", sa.String(length=100), nullable=True),
        sa.Column("password_hash", sa.String(length=255), nullable=True),
        sa.Column("is_active", sa.Boolean(), server_default=sa.text("true")),
        sa.Column("is_admin", sa.Boolean(), server_default=sa.text("false"), nullable=False),
        sa.Column("subscription_expires_at", sa.DateTime(), nullable=True),
        sa.Column("created_at", sa.DateTime(), server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(), server_default=sa.text("now()")),
    )
    op.create_index("ix_users_phone", "users", ["phone"], unique=True)
    op.create_index("ix_users_id", "users", ["id"])

    op.create_table(
        "device_registrations",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column(
            "user_id",
            sa.Integer(),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("device_id_hash", sa.String(length=64), nullable=False),
        sa.Column("system_device_id_hash", sa.String(length=64), nullable=True),
        sa.Column("platform", sa.String(length=16), server_default=sa.text("'mobile'"), nullable=False),
        sa.Column("attestation_provider", sa.String(length=32), nullable=True),
        sa.Column("attestation_token_hash", sa.String(length=64), nullable=True),
        sa.Column("attestation_key_id", sa.String(length=255), nullable=True),
        sa.Column("registration_ip", sa.String(length=45), nullable=False),
        sa.Column("last_ip", sa.String(length=45), nullable=False),
        sa.Column("user_agent", sa.String(length=500), nullable=True),
        sa.Column("created_at", sa.DateTime(), server_default=sa.text("now()"), nullable=False),
        sa.Column("last_seen_at", sa.DateTime(), server_default=sa.text("now()"), nullable=False),
        sa.UniqueConstraint("device_id_hash", name="uq_device_registrations_device"),
        sa.UniqueConstraint(
            "system_device_id_hash",
            name="uq_device_registrations_system_device",
        ),
    )
    op.create_index(
        "ix_device_registrations_user_id",
        "device_registrations",
        ["user_id"],
    )
    op.create_index(
        "ix_device_registrations_device_id_hash",
        "device_registrations",
        ["device_id_hash"],
    )
    op.create_index(
        "ix_device_registrations_system_device_id_hash",
        "device_registrations",
        ["system_device_id_hash"],
    )

    op.create_table(
        "courses",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("price", sa.Integer(), nullable=False),
        sa.Column("cover_image_url", sa.String(length=500), nullable=True),
        sa.Column("is_active", sa.Boolean(), server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(), server_default=sa.text("now()")),
    )

    op.create_table(
        "videos",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column(
            "course_id",
            sa.Integer(),
            sa.ForeignKey("courses.id"),
            nullable=True,
        ),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("description", sa.String(length=500), nullable=True),
        sa.Column("order", sa.Integer(), server_default=sa.text("0")),
        sa.Column("s3_key", sa.String(length=500), nullable=False),
        sa.Column("duration_seconds", sa.Integer(), nullable=True),
        sa.Column("is_preview", sa.Boolean(), server_default=sa.text("false")),
        sa.Column("is_active", sa.Boolean(), server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(), server_default=sa.text("now()")),
    )

    op.create_table(
        "payments",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column(
            "user_id",
            sa.Integer(),
            sa.ForeignKey("users.id"),
            nullable=False,
        ),
        sa.Column("authority", sa.String(length=64), nullable=False),
        sa.Column("amount", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(length=20), server_default=sa.text("'pending'"), nullable=False),
        sa.Column("ref_id", sa.String(length=64), nullable=True),
        sa.Column("created_at", sa.DateTime(), server_default=sa.text("now()"), nullable=False),
        sa.Column("paid_at", sa.DateTime(), nullable=True),
        sa.UniqueConstraint("authority", name="uq_payments_authority"),
    )
    op.create_index("ix_payments_user_id", "payments", ["user_id"])
    op.create_index("ix_payments_authority", "payments", ["authority"])


def downgrade() -> None:
    op.drop_table("payments")
    op.drop_table("videos")
    op.drop_table("courses")
    op.drop_table("device_registrations")
    op.drop_table("users")
