-- dbt_utils date_spine does not support SQLite
{% macro lite_date_spine(start_date, end_date) %}

    (
        WITH RECURSIVE date_series(date_day) AS (
            -- Anchor member: Start with the minimum date
            SELECT DATE('{{ start_date }}')
            UNION ALL
            -- Recursive member: Add one day until the max_date is reached
            SELECT DATE(date_day, '+1 day')
            FROM date_series
            WHERE date_day < DATE('{{ end_date }}')
        )
        SELECT date_day
        FROM date_series
    )

{% endmacro %}