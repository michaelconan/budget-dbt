with revolut as (

    select
        transaction_key,
        'IE' as country,
        'revolut' as source,
        'Revolut' as bank,
        'Bank' as account_type,
        product as account,
        completed_date as "date",
        "description",
        category,
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
        'US' as country,
        'bofa' as source,
        bank_name as bank,
        account_type,
        account_name as account,
        "date",
        coalesce(simple_description, original_description) as "description",
        category,
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
        cm.type as category_type,
        case
            when c.currency = 'EUR'
                then
                    gf.rate
            else 1
        end as fx_rate,
        case
            when c.currency = 'EUR'
                then
                    c.amount * gf.rate
            else c.amount
        end as amount_usd
    from
        combined as c
    left join
        {{ ref('fx_rates') }} as gf
        on
            c.currency = 'EUR'
            and c."date" = gf."date"
    left join
        {{ ref('category_mapping') }} as cm
        on c.category = case
            when c.source = 'revolut'
                then cm.revolut
            when c.source = 'bofa'
                then cm.bofa
        end

)

select *
from translated
