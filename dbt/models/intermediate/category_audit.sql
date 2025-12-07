-- =============================================================================
-- INTERMEDIATE: Category Audit
-- =============================================================================
-- Purpose:
-- This model identifies vendors in the current transaction data that have NOT
-- yet been mapped to a category in `vendor_categories`.
-- It is used to generate a list of 'TBD' vendors for manual or AI classification.
--
-- 1. Get list of already categorized vendors

with existing_vendors as (
    select distinct
        category,
        vendor
    from
        {{ ref('vendor_categories') }}
),

-- 2. Find transactions with NULL categories and new vendors
--    Select distinct descriptions that are not in the existing list.

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
