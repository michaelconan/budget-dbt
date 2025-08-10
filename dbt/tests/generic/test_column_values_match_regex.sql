{% test column_values_match_regex(model, column_name, pattern) %}

    select *
    from {{ model }}
    where not regexp_matches({{ column_name }}, '{{ pattern }}')

{% endtest %}