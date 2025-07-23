{% macro categorise_keywords(description_column) %}

    case
    {% set categories = var('categories', {}) %}
    {% for category, keywords in categories.items() %}
        {% for keyword in keywords %}
            when lower({{ description_column }}) like '%{{ keyword|lower }}%' then '{{ category }}'
        {% endfor %}
    {% endfor %}
    end

{% endmacro %}