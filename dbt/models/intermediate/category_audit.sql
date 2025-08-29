with existing_vendors as (
    select distinct
        category,
        vendor
    from {{ ref('vendor_categories') }}
),

new_uncategorized as (
    select distinct
        'TBD' as category,
        description as vendor
    from {{ ref('transactions') }}
    where
        category is null
        and description not in (select vendor from existing_vendors)
)

select
    category,
    vendor
from existing_vendors
union all
select
    category,
    vendor
from new_uncategorized
