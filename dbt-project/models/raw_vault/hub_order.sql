with keys as (
    select order_hk, order_id, load_dts, record_source from {{ ref('stg_dv__orders') }}
    union all
    select order_hk, order_id, load_dts, record_source from {{ ref('stg_dv__order_lines') }}
)

select
    order_hk,
    min(order_id)      as order_id,
    min(load_dts)      as load_dts,
    min(record_source) as record_source
from keys
{% if is_incremental() %}
where order_hk not in (select order_hk from {{ this }})
{% endif %}
group by order_hk
