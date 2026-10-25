-- Satellite: descriptive attributes with full history. A row is inserted
-- only when hash_diff differs from the latest stored row for the same key.
with source as (
    select distinct
        product_hk,
        product_hash_diff as hash_diff,
        product_name,
        load_dts,
        record_source
    from {{ ref('stg_dv__products') }}
)

{% if is_incremental() %}
, latest as (
    select product_hk, hash_diff
    from (
        select
            product_hk,
            hash_diff,
            row_number() over (partition by product_hk order by load_dts desc) as rn
        from {{ this }}
    ) as ranked
    where rn = 1
)
{% endif %}

select source.*
from source
{% if is_incremental() %}
left join latest on latest.product_hk = source.product_hk
where latest.hash_diff is distinct from source.hash_diff
{% endif %}
