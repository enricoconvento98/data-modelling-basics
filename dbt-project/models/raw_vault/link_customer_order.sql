-- Link: one row per (customer, order) relationship, ever.
select distinct
    customer_order_hk,
    customer_hk,
    order_hk,
    load_dts,
    record_source
from {{ ref('stg_dv__orders') }}
{% if is_incremental() %}
where customer_order_hk not in (select customer_order_hk from {{ this }})
{% endif %}
