-- =============================================================================
-- STAGE: Bank of America Transactions
-- =============================================================================
-- Purpose:
-- This model loads raw transaction data from Bank of America, cleanses it,
-- handles duplicates, and standardizes the schema for downstream analysis.
--
-- 1. Load transactions from Bank of America


with transactions as (

    select
        status,
        currency,
        cast(replace(cast(amount as varchar), ',', '') as double) as amount,
        lower(category) as category,
        substr(account_name, 1, instr(account_name, '-') - 2) as bank_name,
        substr(
            account_name, instr(account_name, '-') + 2,
            instr(substr(account_name, instr(account_name, '-') + 1), '-') - 3
        ) as account_type,
        substr(
            account_name,
            instr(account_name, '-') + instr(
                substr(account_name, instr(account_name, '-') + 1), '-'
            ) + 2
        ) as account_name,
        -- convert date from US to ISO format
        concat(
            substr(date, 7, 4), '-',
            substr(date, 1, 2), '-',
            substr(date, 4, 2)
        ) as date,
        trim(original_description) as original_description,
        nullif(trim(split_type), '') as split_type,
        nullif(trim(user_description), '') as user_description,
        nullif(trim(memo), '') as memo,
        nullif(trim(classification), '') as classification,
        nullif(trim(simple_description), '') as simple_description
    from
        {{ make_source('bofa', 'activity') }}

),

-- 2. Add row numbers to handle potential duplicates
-- Since the source data lacks a unique ID and can contain identical transactions
-- (same date, amount, description), we generate a duplicate_id to distinguish them.

numbered as (

    select
        *,
        row_number() over (
            partition by account_name, date, original_description, amount
            order by account_name
        ) as duplicate_id
    from transactions

),

-- 3. Create a surrogate key for each transaction
-- The surrogate key is a hash of the transaction details and the duplicate_id.
-- This ensures that every row has a unique identifier for testing and tracking.

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(
                ['account_name', 'date', 'original_description', 'amount', 'duplicate_id']
            )
        }}
            as transaction_key,
        *
    from
        numbered

),

-- 4. Identify transfers between accounts
-- Use the project macro to match transactions that look like transfers
-- (e.g. negative in one account, positive in another on the same day).

transfers as (

    {{ get_transfer_transactions('keyed', 'date', 'account_name', 'amount') }}),

-- 5. Final projection and transfer flagging
-- Select the final columns and join with the transfers CTE to flag
-- transfer transactions.

flagged as (

    select
        cast(k.transaction_key as text) as transaction_key,
        k.status,
        k.category,
        k.currency,
        k.amount,
        cast(k.bank_name as text) as bank_name,
        cast(k.account_type as text) as account_type,
        cast(k.account_name as text) as account_name,
        cast(k.date as text) as date,
        k.original_description,
        k.split_type,
        k.user_description,
        k.memo,
        k.classification,
        k.simple_description,
        (t.transaction_key is not null) as is_transfer
    from
        keyed as k
    left join
        transfers as t
        on k.transaction_key = t.transaction_key

)

select *
from flagged
