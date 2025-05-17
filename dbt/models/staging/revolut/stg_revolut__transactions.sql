-- 1. Load personal and joint transactions from Revolut

with personal as (

    select
        "type",
        product,
        started_date,
        completed_date,
        "description",
        amount,
        fee,
        currency,
        "state",
        balance
    from
        {{ source('revolut', 'personal') }}

),

joint as (

    select
        "type",
        'Joint' as product,
        started_date,
        completed_date,
        "description",
        amount,
        fee,
        currency,
        "state",
        balance
    from
        {{ source('revolut', 'joint') }}

),

-- 2. Combine personal and joint transactions into a single table

combined as (

    select *
    from personal
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

),

-- 4. Identify transfers between accounts

transfers as (

    {{ get_transfer_transactions('keyed', 'completed_date', 'product', 'amount') }}

),

-- 5. Select all transactions and indicate if they are transfers
flagged as (

    select
        cast(k.transaction_key as text) as transaction_key,
        "type",
        cast(product as text) as product,
        cast(substr(started_date, 1, 10) as text) as started_date,
        cast(substr(completed_date, 1, 10) as text) as completed_date,
        "description",
        amount,
        fee,
        currency,
        "state",
        balance,
        (t.transaction_key is not null) as is_transfer
    from
        keyed as k
    left join
        transfers as t
        on k.transaction_key = t.transaction_key

)

select *
from flagged