with transactions as (

    select
        "status",
        -- convert date from US to ISO format
        category,
        currency,
        amount,
        account_name,
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

)

select *
from transactions
