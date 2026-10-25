-- Hub: one row per customer business key, ever. Fed by every staging model
-- that carries the key, so an order for an unknown customer still lands here.
with keys as (
    select customer_hk, customer_id, load_dts, record_source from {{ ref('stg_dv__customers') }}
    union all
    select customer_hk, customer_id, load_dts, record_source from {{ ref('stg_dv__orders') }}
)

select
    customer_hk,
    min(customer_id)   as customer_id,
    min(load_dts)      as load_dts,
    min(record_source) as record_source
from keys
{% if is_incremental() %}
where customer_hk not in (select customer_hk from {{ this }})
{% endif %}
group by customer_hk
