-- =======================================
-- Revolut statement for personal accounts
-- =======================================
DROP TABLE IF EXISTS raw_revolut__personal;
CREATE TABLE raw_revolut__personal (
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
