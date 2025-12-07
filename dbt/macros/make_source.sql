-- Adapter-aware macro to load the live or mock source based on target name 
-- Usage: {{ make_source('my_source', 'my_relation') }}
--
{% macro make_source(source_name, relation) -%}
    {% set ref_name = source_name ~ '__' ~ relation %}
    {% if target.name == 'local' %}
        {{ ref('mock_raw_' ~ ref_name) }}
    {% else %}
        {{ source(source_name, relation) }}
    {% endif %}
{%- endmacro %}