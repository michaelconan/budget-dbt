select *
from
{% if target.name == 'local' %}
        {{ ref('vendor_category_mapping__local') }}
    {% else %}
        {{ ref('vendor_category_mapping') }}
{% endif %}
