-- ====================================
-- Bank of America transaction activity
-- exported from 'My Financial Picture'
-- ====================================
CREATE TABLE raw_bofa__activity (
    "status" TEXT,
    "date" TEXT,
    original_description TEXT,
    split_type TEXT,
    category TEXT,
    currency TEXT,
    amount FLOAT,
    user_description TEXT,
    memo TEXT,
    classification TEXT,
    account_name TEXT,
    simple_description TEXT
);