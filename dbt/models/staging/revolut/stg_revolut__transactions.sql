-- 1. Load personal and joint transactions from Revolut

with personal as (

    select
        "type",
        product,
        substr(started_date, 1, 10) as started_date,
        substr(completed_date, 1, 10) as completed_date,
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
        substr(started_date, 1, 10) as started_date,
        substr(completed_date, 1, 10) as completed_date,
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

    select t1.transaction_key
    from
        keyed as t1
    inner join
        keyed as t2
        on
            t1.completed_date = t2.completed_date
            and t1.amount = -1 * t2.amount
            and t1.product != t2.product
            and t1.type = t2.type

)

-- 5. Select all transactions and indicate if they are transfers

select
    k.*,
    t.transaction_key is not null as is_transfer
from
    keyed as k
left join
    transfers as t
    on k.transaction_key = t.transaction_key
