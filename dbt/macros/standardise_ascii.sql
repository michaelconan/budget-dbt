{% macro standardise_ascii(column_name) %}
    replace(
        replace(
            replace(
                replace(
                    {{ column_name }},
                    '‘', ''''
                ),
                '’', ''''
            ),
            '“', '"'
        ),
        '”', '"'
    )
{% endmacro %}
