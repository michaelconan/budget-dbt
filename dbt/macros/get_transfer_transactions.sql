{% macro get_transfer_transactions(table_name, date_column, account_column, amount_column) %}

    select
        t1.transaction_key
    from
        {{ table_name }} as t1
    inner join
        {{ table_name }} as t2
        on
            t1.{{ date_column }} = t2.{{ date_column }}
            and cast(t1.{{ amount_column }} as double) = -1 * cast(t2.{{ amount_column }} as double)
            and t1.{{ account_column }} != t2.{{ account_column }}
    group by 
        t1.transaction_key

{% endmacro %}