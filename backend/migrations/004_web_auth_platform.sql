ALTER TABLE device_registrations
    ADD COLUMN IF NOT EXISTS platform VARCHAR(16) NOT NULL DEFAULT 'mobile';
