-- Satellite: descriptive attributes with full history. A row is inserted
-- only when hash_diff differs from the latest stored row for the same key.
with source as (
    select distinct
        order_line_hk,
        order_line_hash_diff as hash_diff,
        amount,
        load_dts,
        record_source
    from {{ ref('stg_dv__order_lines') }}
)

{% if is_incremental() %}
, latest as (
    select order_line_hk, hash_diff
    from (
        select
            order_line_hk,
            hash_diff,
            row_number() over (partition by order_line_hk order by load_dts desc) as rn
        from {{ this }}
    ) as ranked
    where rn = 1
)
{% endif %}

select source.*
from source
{% if is_incremental() %}
left join latest on latest.order_line_hk = source.order_line_hk
where latest.hash_diff is distinct from source.hash_diff
{% endif %}
