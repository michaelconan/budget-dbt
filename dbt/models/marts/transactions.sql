with revolut as (

    select
        transaction_key,
        'us' as country,
        'revolut' as source,
        product as account,
        completed_date as "date",
        "description",
        amount,
        currency,
        "state" as "status",
        is_transfer
    from
        {{ ref('stg_revolut__transactions') }}

),

bofa as (

    select
        transaction_key,
        'ie' as country,
        'bofa' as source,
        account_name as account,
        "date",
        coalesce(simple_description, original_description) as "description",
        amount,
        currency,
        "status",
        is_transfer
    from
        {{ ref('stg_bofa__transactions') }}
),

combined as (

    select *
    from revolut
    union all
    select *
    from bofa

),

translated as (

    select
        c.*,
        case
            when c.currency = 'EUR'
                then
                    gf.close
            else 1
        end as fx_rate,
        case
            when c.currency = 'EUR'
                then
                    c.amount * gf.close
            else c.amount
        end as amount_usd
    from
        combined as c
    left join
        {{ ref('google_finance__eur_usd') }} as gf
        on
            c.currency = 'EUR'
            and c."date" = gf."date"

)

select *
from translated
