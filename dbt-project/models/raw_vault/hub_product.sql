with keys as (
    select product_hk, product_id, load_dts, record_source from {{ ref('stg_dv__products') }}
    union all
    select product_hk, product_id, load_dts, record_source from {{ ref('stg_dv__order_lines') }}
)

select
    product_hk,
    min(product_id)    as product_id,
    min(load_dts)      as load_dts,
    min(record_source) as record_source
from keys
{% if is_incremental() %}
where product_hk not in (select product_hk from {{ this }})
{% endif %}
group by product_hk
