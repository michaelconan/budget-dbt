-- =======================================
-- Revolut statement for spouse accounts
-- =======================================
DROP TABLE IF EXISTS raw_revolut__spouse;
CREATE TABLE raw_revolut__spouse (
    type VARCHAR,
    product VARCHAR,
    started_date VARCHAR,
    completed_date VARCHAR,
    description VARCHAR,
    amount VARCHAR,
    fee VARCHAR,
    currency VARCHAR,
    state VARCHAR,
    balance VARCHAR
);
