-- =======================================
-- Revolut statement for joint accounts
-- =======================================
DROP TABLE IF EXISTS raw_revolut__joint;
CREATE TABLE raw_revolut__joint (
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
