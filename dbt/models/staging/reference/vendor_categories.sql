select *
from
    {% if target.name == 'local' %}
        {{ ref('vendor_categories__local') }}
    {% else %}
        {{ ref('vendor_categories') }}
    {% endif %}