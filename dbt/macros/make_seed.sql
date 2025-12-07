-- Adapter-aware macro to load the live or mock source based on target name 
-- Usage: {{ make_seed('my_seed') }}
--
{% macro make_seed(seed_name) -%}
    {% if target.name == 'local' %}
        {{ ref(seed_name ~ '__local') }}
    {% else %}
        {{ ref(seed_name) }}
    {% endif %}
{%- endmacro %}