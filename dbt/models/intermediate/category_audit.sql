select *
from {{ ref('vendor_categories') }}
union all
select
    'TBD'as category,
    description as vendor
from {{ ref('transactions') }}
where category is null
