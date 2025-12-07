-- =============================================================================
-- REFERENCE: FX Rates (EUR to USD)
-- =============================================================================
-- Purpose:
-- This model generates a daily exchange rate table for EUR to USD.
-- It handles missing data points (e.g. weekends/holidays) by forward-filling
-- the last known rate.
--
-- 1. Generate full range of dates as Google Finance skips certain dates

{% set current_date = modules.datetime.date.today().isoformat() %}
{% set tomorrow = (modules.datetime.date.today() + modules.datetime.timedelta(days=1)).isoformat() %}

with date_scaffold as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2023-01-01' as date)",
        end_date="cast('" + tomorrow + "' as date)"
       )
    }}),

-- 2. Join the date spine with the raw Google Finance data
--    This leaves NULLs for days where no stock market data exists.

rate_data as (
    select
        ds.date_day as date,
        gf.close as rate
    from date_scaffold as ds
    left join
        {{ make_seed('google_finance__eur_usd') }} as gf
        on ds.date_day = gf.date
),

-- 3. Create groups for consecutive NULL values
--    This technique assigns a group_id to each run of NULLs,
--    associating them with the preceding non-NULL value.

with_groups as (
    select
        date,
        rate,
        sum(case when rate is not null then 1 else 0 end) over (
            order by date rows between unbounded preceding and current row
        ) as group_id
    from rate_data
),

-- 4. Fill NULLs with the last known value within each group
--    Forward-fill the rate using the group_id window.

filled_rates as (
    select
        date,
        coalesce(
            rate,
            first_value(rate) over (
                partition by group_id
                order by date
                rows between unbounded preceding and current row
            )
        ) as rate
    from with_groups
)

select * from filled_rates
