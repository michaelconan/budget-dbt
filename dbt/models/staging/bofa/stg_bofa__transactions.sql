-- 1. Load transactions from Bank of America

with transactions as (

    select
        "status",
        currency,
        amount,
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
            substr("date", 7, 4), '-',
            substr("date", 1, 2), '-',
            substr("date", 4, 2)
        ) as "date",
        trim(original_description) as original_description,
        nullif(trim(split_type), '') as split_type,
        nullif(trim(user_description), '') as user_description,
        nullif(trim(memo), '') as memo,
        nullif(trim(classification), '') as classification,
        nullif(trim(simple_description), '') as simple_description
    from
        {{ source('bofa', 'activity') }}

),

-- 2. Create a surrogate key for each transaction

keyed as (

    select
        {{ dbt_utils.generate_surrogate_key(
                ['account_name', 'date', 'original_description', 'amount']
            )
        }}
            as transaction_key,
        *
    from
        transactions

),

-- 3. Identify transfers between accounts

transfers as (

    {{ get_transfer_transactions('keyed', 'date', 'account_name', 'amount') }}),

-- 4. Flag transactions that are transfers

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
        cast(k.date as text) as "date",
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
