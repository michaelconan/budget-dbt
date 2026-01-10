-- =============================================================================
-- STAGE: Revolut Combined Transactions
-- =============================================================================
-- Purpose:
-- This model consolidates transaction data from three different Revolut account
-- sources: Personal, Spouse, and Joint. It unions them into a single dataset
-- for downstream processing.
--
-- 1. Union data from all account types
select
    type as transaction_type,
    product,
    started_date,
    completed_date,
    description as transaction_description,
    amount,
    fee,
    currency,
    state as transaction_state,
    balance
from
    {{ make_source('revolut', 'personal') }}

union all

select
    type,
    'Spouse' as product,
    started_date,
    completed_date,
    description,
    amount,
    fee,
    currency,
    state,
    balance
from
    {{ make_source('revolut', 'spouse') }}

union all

select
    type,
    'Joint' as product,
    started_date,
    completed_date,
    description,
    amount,
    fee,
    currency,
    state,
    balance
from
    {{ make_source('revolut', 'joint') }}
