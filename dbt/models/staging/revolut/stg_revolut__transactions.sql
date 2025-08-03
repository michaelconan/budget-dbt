-- 1. Load personal and joint transactions from Revolut

with personal as (

    select
        type,
        product,
        started_date,
        completed_date,
        description,
        -- Parse amount from string
        CASE 
            WHEN amount = '' OR amount IS NULL THEN 0.0
            ELSE CAST(amount AS DOUBLE)
        END as amount,
        -- Parse fee from string
        CASE 
            WHEN fee = '' OR fee IS NULL THEN 0.0
            ELSE CAST(fee AS DOUBLE)
        END as fee,
        currency,
        state,
        -- Parse balance from string
        CASE 
            WHEN balance = '' OR balance IS NULL THEN 0.0
            ELSE CAST(balance AS DOUBLE)
        END as balance
    from
        {{ source('revolut', 'personal') }}

),

spouse as (

    select
        type,
        'Spouse' as product,
        started_date,
        completed_date,
        description,
        -- Parse amount from string
        CASE 
            WHEN amount = '' OR amount IS NULL THEN 0.0
            ELSE CAST(amount AS DOUBLE)
        END as amount,
        -- Parse fee from string
        CASE 
            WHEN fee = '' OR fee IS NULL THEN 0.0
            ELSE CAST(fee AS DOUBLE)
        END as fee,
        currency,
        state,
        -- Parse balance from string
        CASE 
            WHEN balance = '' OR balance IS NULL THEN 0.0
            ELSE CAST(balance AS DOUBLE)
        END as balance
    from
        {{ source('revolut', 'spouse') }}

),

joint as (

    select
        type,
        'Joint' as product,
        started_date,
        completed_date,
        description,
        -- Parse amount from string
        CASE 
            WHEN amount = '' OR amount IS NULL THEN 0.0
            ELSE CAST(amount AS DOUBLE)
        END as amount,
        -- Parse fee from string
        CASE 
            WHEN fee = '' OR fee IS NULL THEN 0.0
            ELSE CAST(fee AS DOUBLE)
        END as fee,
        currency,
        state,
        -- Parse balance from string
        CASE 
            WHEN balance = '' OR balance IS NULL THEN 0.0
            ELSE CAST(balance AS DOUBLE)
        END as balance
    from
        {{ source('revolut', 'joint') }}

),

-- 2. Combine personal and joint transactions into a single table

combined as (

    select *
    from personal
    union all
    select *
    from spouse
    union all
    select *
    from joint

),

-- 3. Create a surrogate key for each transaction

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(
                ['product', 'completed_date', 'description', 'amount', 'balance']
            )
        }}
            as transaction_key,
        *
    from
        combined
    -- only include completed transactions (exclude pending or reverted)
    where
        state = 'COMPLETED'

),

-- 4. Identify transfers between accounts

transfers as (

    {{
        get_transfer_transactions(
            'keyed', 'completed_date', 'product', 'amount'
        )
    }}

),

-- 5. Select all transactions and indicate if they are transfers
flagged as (

    select
        cast(k.transaction_key as varchar) as transaction_key,
        k.type,
        cast(k.product as varchar) as product,
        cast(substr(k.started_date, 1, 10) as date) as started_date,
        cast(substr(k.completed_date, 1, 10) as date) as completed_date,
        k.description,
        k.amount,
        k.fee,
        k.currency,
        k.state,
        k.balance,
        (t.transaction_key is not null) as is_transfer
    from
        keyed as k
    left join
        transfers as t
        on k.transaction_key = t.transaction_key

),

categorised as (

    select
        f.transaction_key,
        f.type,
        f.product,
        f.started_date,
        f.completed_date,
        f.description,
        f.amount,
        f.fee,
        f.currency,
        f.state,
        f.balance,
        f.is_transfer,
        -- use the mapped vendor category if it exists, otherwise use the
        -- categorisation macro
        min(
            coalesce(
                vc.category,
                {{ categorise_keywords('f.description') }}
            )
        ) as category
    from
        flagged as f
    left join
        {{ ref('vendor_categories') }} as vc
        on lower(f.description) like '%' || lower(vc.vendor) || '%'
    group by
        f.transaction_key,
        f.type,
        f.product,
        f.started_date,
        f.completed_date,
        f.description,
        f.amount,
        f.fee,
        f.currency,
        f.state,
        f.balance,
        f.is_transfer
)

select *
from categorised
order by completed_date, product
