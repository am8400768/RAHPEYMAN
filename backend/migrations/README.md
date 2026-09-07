# Migrations

This directory used to hold hand-written raw PostgreSQL SQL files
(`002_device_attestation.sql`, `003_payments.sql`, ...). They were applied
manually and had no `001_initial` file.

The source of truth for the schema is now **Alembic** (see `../alembic/`).
`alembic/versions/001_initial_tables.py` creates the full current schema and
includes everything the old SQL files covered.

Usage (from `backend/`):

```bash
alembic upgrade head
```
