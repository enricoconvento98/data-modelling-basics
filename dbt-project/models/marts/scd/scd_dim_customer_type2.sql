-- SCD Type 2: one row per version, half-open validity interval [valid_from, valid_to).
-- The surrogate key is a hash of (customer_id, valid_from), so it is stable
-- across rebuilds.
select
    {{ hash_key(['customer_id', 'valid_from']) }} as customer_sk,
    customer_id,
    customer_name,
    city,
    valid_from,
    coalesce(
        lead(valid_from) over (partition by customer_id order by valid_from),
        cast('9999-12-31' as date)
    ) as valid_to,
    lead(valid_from) over (partition by customer_id order by valid_from) is null as is_current
from {{ ref('int_scd__customer_versions') }}
