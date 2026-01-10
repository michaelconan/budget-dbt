-- =============================================================================
-- MART: All Transactions
-- =============================================================================
-- Purpose:
-- This is the main transactions fact table. It unifies data from BofA and Revolut,
-- standardizes column names, converts currencies to USD, and applies category mappings.
--
-- 1. Standardization: Revolut
--    Project Revolut fields to the target schema.
with revolut as (

    select
        transaction_key,
        'IE' as country,
        'revolut' as source,
        'Revolut' as bank,
        'Bank' as account_type,
        product as account_name,
        completed_date as transaction_date,
        transaction_description,
        category,
        amount + fee as amount,
        currency,
        transaction_state as transaction_status,
        is_transfer
    from
        {{ ref('stg_revolut__transactions') }}

),

-- 2. Standardization: Bank of America
--    Project BofA fields to the target schema.

bofa as (

    select
        transaction_key,
        'US' as country,
        'bofa' as source,
        bank_name as bank,
        account_type,
        account_name,
        transaction_date,
        coalesce(simple_description, original_description)
            as transaction_description,
        category,
        amount,
        currency,
        status as transaction_status,
        is_transfer
    from
        {{ ref('stg_bofa__transactions') }}

),

-- 3. Union Sources
--    Combine the standardized datasets into one stream.

combined as (

    select *
    from revolut
    union all
    select *
    from bofa

),

-- 4. Translation & Enrichment
--    - Convert non-USD amounts to USD using the FX rate.
--    - Map source-specific categories to the unified high-level categories.

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
        round(
            case
                when c.currency = 'EUR'
                    then
                        c.amount * gf.rate
                else c.amount
            end,
            2
        ) as amount_usd
    from
        combined as c
    left join
        {{ ref('fx_rates') }} as gf
        on
            c.currency = 'EUR'
            and c.transaction_date = gf.transaction_date
    left join
        {{ make_seed('category_mapping') }}
            as cm
        on c.category = case
            when c.source = 'revolut'
                then cm.revolut
            when c.source = 'bofa'
                then cm.bofa
        end

)

select
    transaction_key,
    country,
    source,
    bank,
    account_type,
    account_name,
    transaction_date,
    transaction_description,
    category,
    amount,
    currency,
    transaction_status,
    is_transfer,
    category_type,
    fx_rate,
    amount_usd
from translated
