-- =======================================
-- Revolut statement for joint accounts
-- =======================================
DROP TABLE IF EXISTS raw_revolut__joint;
CREATE TABLE raw_revolut__joint (
    "type" TEXT,
    product TEXT,
    started_date TEXT,
    completed_date TEXT,
    "description" TEXT,
    amount FLOAT,
    fee FLOAT,
    currency TEXT,
    "state" TEXT,
    balance FLOAT
);