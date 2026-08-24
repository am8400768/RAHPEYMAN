CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    authority VARCHAR(64) NOT NULL UNIQUE,
    amount INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    ref_id VARCHAR(64),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP NULL
);

CREATE INDEX IF NOT EXISTS ix_payments_user_id
    ON payments (user_id);

CREATE INDEX IF NOT EXISTS ix_payments_authority
    ON payments (authority);
