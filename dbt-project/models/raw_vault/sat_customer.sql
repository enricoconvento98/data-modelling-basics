-- Satellite: descriptive attributes with full history. A row is inserted
-- only when hash_diff differs from the latest stored row for the same key.
with source as (
    select distinct
        customer_hk,
        customer_hash_diff as hash_diff,
        customer_name, city,
        load_dts,
        record_source
    from {{ ref('stg_dv__customers') }}
)

{% if is_incremental() %}
, latest as (
    select customer_hk, hash_diff
    from (
        select
            customer_hk,
            hash_diff,
            row_number() over (partition by customer_hk order by load_dts desc) as rn
        from {{ this }}
    ) as ranked
    where rn = 1
)
{% endif %}

select source.*
from source
{% if is_incremental() %}
left join latest on latest.customer_hk = source.customer_hk
where latest.hash_diff is distinct from source.hash_diff
{% endif %}
