-- Generate full range of dates as Google Finance skips certain dates
{% set current_date = modules.datetime.date.today().isoformat() %}

with date_scaffold as (
    select
        date_day
    from
        {{ lite_date_spine(
            start_date="2023-01-01",
            end_date=current_date
        ) }}
),

rate_data as (
    select 
        ds.date_day as "date",
        gf."Close" as rate
    from date_scaffold ds
    left join {{ ref('google_finance__eur_usd') }} gf
    on ds.date_day = gf."Date"
),

-- Create groups for consecutive NULL values
with_groups as (
    select 
        "date",
        rate,
        sum(case when rate is not null then 1 else 0 end) over (
            order by "date" rows between unbounded preceding and current row
        ) as group_id
    from rate_data
),

-- Fill NULLs with the last known value within each group
filled_rates as (
    select 
        "date",
        coalesce(
            rate,
            first_value(rate) over (
                partition by group_id 
                order by "date" 
                rows between unbounded preceding and current row
            )
        ) as rate
    from with_groups
)

select * from filled_rates
