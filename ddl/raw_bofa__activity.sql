-- ====================================
-- Bank of America transaction activity
-- exported from 'My Financial Picture'
-- ====================================
DROP TABLE IF EXISTS raw_bofa__activity;
CREATE TABLE raw_bofa__activity (
    status VARCHAR,
    date VARCHAR,
    original_description VARCHAR,
    split_type VARCHAR,
    category VARCHAR,
    currency VARCHAR,
    amount VARCHAR,
    user_description VARCHAR,
    memo VARCHAR,
    classification VARCHAR,
    account_name VARCHAR,
    simple_description VARCHAR
);
