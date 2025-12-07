-- Adapter-aware macro to load the live or mock source based on target name 
-- Usage: {{ make_seed('my_seed') }}
--
{% macro make_seed(seed_name) -%}
    {% if target.name == 'local' %}
        {{ ref('mock_' ~ seed_name) }}
    {% else %}
        {{ ref(seed_name) }}
    {% endif %}
{%- endmacro %}