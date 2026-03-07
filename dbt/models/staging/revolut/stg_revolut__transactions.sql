-- =============================================================================
-- STAGE: Revolut Transactions
-- =============================================================================
-- Purpose:
-- This model processes the combined Revolut data, standardizing types,
-- generating keys, handling transfers, and assigning vendor categories.
--
-- 1. Load personal, spouse, joint transactions from Revolut
--    and standardize column types and formats.

with combined as (

    select
        -- Standardize transaction types to UPPER_CASE with underscores
        upper(replace(transaction_type, ' ', '_')) as transaction_type,
        product,
        started_date,
        completed_date,
        {{ standardise_ascii('trim(transaction_description)') }}
            as transaction_description,
        cast(replace(cast(amount as varchar), ',', '') as double) as amount,
        cast(replace(cast(fee as varchar), ',', '') as double) as fee,
        currency,
        transaction_state,
        cast(replace(cast(balance as varchar), ',', '') as double) as balance
    from
        {{ ref('stg_revolut__combined') }}

),

-- 2. Create a surrogate key for each transaction
--    Hash relevant fields to create a unique ID.
--    Filter to only COMPLETED transactions at this stage.

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(
                ['product', 'completed_date', 'transaction_description', 'amount', 'balance']
            )
        }}
            as transaction_key,
        *
    from
        combined
    -- only include completed transactions (exclude pending or reverted)
    where
        transaction_state = 'COMPLETED'

),

-- 3. Identify transfers between accounts
--    Use the project macro to find potential internal transfers.

transfers as (

    {{
        get_transfer_transactions(
            'keyed', 'completed_date', 'product', 'amount'
        )
    }}
),

-- 4. Select all transactions and indicate if they are transfers
--    Join back to the transfer identification CTE to flag rows.
flagged as (

    select
        cast(k.transaction_key as text) as transaction_key,
        k.transaction_type,
        cast(k.product as text) as product,
        cast(substr(cast(k.started_date as varchar), 1, 10) as date) as started_date,
        cast(
            substr(cast(k.completed_date as varchar), 1, 10) as date
        ) as completed_date,
        k.transaction_description,
        k.amount,
        k.fee,
        k.currency,
        k.transaction_state,
        k.balance,
        (t.transaction_key is not null) as is_transfer
    from
        keyed as k
    left join
        transfers as t
        on k.transaction_key = t.transaction_key

),

-- 5. Categorise transactions based on description
--    Attempt to map descriptions to known vendor categories.
--    If no direct match, use the categorise_keywords macro as a fallback.

categorised as (

    select
        f.transaction_key,
        f.transaction_type,
        f.product,
        f.started_date,
        f.completed_date,
        f.transaction_description,
        f.amount,
        f.fee,
        f.currency,
        f.transaction_state,
        f.balance,
        f.is_transfer,
        -- use the mapped vendor category if it exists, otherwise use the
        -- categorisation macro
        min(
            coalesce(
                vc.category,
                {{ categorise_keywords('f.transaction_description') }}
            )
        ) as category
    from
        flagged as f
    left join
        {{ ref('vendor_categories') }} as vc
        on lower(f.transaction_description) like '%' || lower(vc.vendor) || '%'
    group by
        f.transaction_key,
        f.transaction_type,
        f.product,
        f.started_date,
        f.completed_date,
        f.transaction_description,
        f.amount,
        f.fee,
        f.currency,
        f.transaction_state,
        f.balance,
        f.is_transfer

)

select
    transaction_key,
    transaction_type,
    product,
    started_date,
    completed_date,
    transaction_description,
    amount,
    fee,
    currency,
    transaction_state,
    balance,
    is_transfer,
    category
from categorised
order by completed_date, product
