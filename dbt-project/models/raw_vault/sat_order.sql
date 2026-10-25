-- Satellite: descriptive attributes with full history. A row is inserted
-- only when hash_diff differs from the latest stored row for the same key.
with source as (
    select distinct
        order_hk,
        order_hash_diff as hash_diff,
        order_date, freight,
        load_dts,
        record_source
    from {{ ref('stg_dv__orders') }}
)

{% if is_incremental() %}
, latest as (
    select order_hk, hash_diff
    from (
        select
            order_hk,
            hash_diff,
            row_number() over (partition by order_hk order by load_dts desc) as rn
        from {{ this }}
    ) as ranked
    where rn = 1
)
{% endif %}

select source.*
from source
{% if is_incremental() %}
left join latest on latest.order_hk = source.order_hk
where latest.hash_diff is distinct from source.hash_diff
{% endif %}
