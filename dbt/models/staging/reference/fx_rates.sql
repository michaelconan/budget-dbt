-- Generate full range of dates as Google Finance skips certain dates
{% set current_date = modules.datetime.date.today().isoformat() %}
{% set tomorrow = (modules.datetime.date.today() + modules.datetime.timedelta(days=1)).isoformat() %}

with date_scaffold as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2023-01-01' as date)",
        end_date="cast('" + tomorrow + "' as date)"
       )
    }}),

rate_data as (
    select
        ds.date_day as date,
        gf.close as rate
    from date_scaffold as ds
    left join
        {% if target.name == 'local' %}
            {{ ref('google_finance__eur_usd__local') }}
        {% else %}
            {{ ref('google_finance__eur_usd') }}
        {% endif %}
        as gf
        on ds.date_day = gf.date
),

-- Create groups for consecutive NULL values
with_groups as (
    select
        date,
        rate,
        sum(case when rate is not null then 1 else 0 end) over (
            order by date rows between unbounded preceding and current row
        ) as group_id
    from rate_data
),

-- Fill NULLs with the last known value within each group
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
