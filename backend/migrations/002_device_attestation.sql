ALTER TABLE device_registrations
    ADD COLUMN IF NOT EXISTS system_device_id_hash VARCHAR(64);

ALTER TABLE device_registrations
    ADD COLUMN IF NOT EXISTS attestation_provider VARCHAR(32);

ALTER TABLE device_registrations
    ADD COLUMN IF NOT EXISTS attestation_token_hash VARCHAR(64);

ALTER TABLE device_registrations
    ADD COLUMN IF NOT EXISTS attestation_key_id VARCHAR(255);

CREATE INDEX IF NOT EXISTS ix_device_registrations_system_device_id_hash
    ON device_registrations (system_device_id_hash);

CREATE UNIQUE INDEX IF NOT EXISTS uq_device_registrations_system_device
    ON device_registrations (system_device_id_hash)
    WHERE system_device_id_hash IS NOT NULL;
