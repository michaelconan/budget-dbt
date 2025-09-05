select
    type,
    product,
    started_date,
    completed_date,
    description,
    amount,
    fee,
    currency,
    state,
    balance
from
    {% if target.name == 'local' %}
        {{ ref('raw_revolut__personal') }}
    {% else %}
        {{ source('revolut', 'raw_revolut__personal') }}
    {% endif %}

union all

select
    type,
    'Spouse' as product,
    started_date,
    completed_date,
    description,
    amount,
    fee,
    currency,
    state,
    balance
from
    {% if target.name == 'local' %}
        {{ ref('raw_revolut__spouse') }}
    {% else %}
        {{ source('revolut', 'raw_revolut__spouse') }}
    {% endif %}

union all

select
    type,
    'Joint' as product,
    started_date,
    completed_date,
    description,
    amount,
    fee,
    currency,
    state,
    balance
from
    {% if target.name == 'local' %}
        {{ ref('raw_revolut__joint') }}
    {% else %}
        {{ source('revolut', 'raw_revolut__joint') }}
    {% endif %}
