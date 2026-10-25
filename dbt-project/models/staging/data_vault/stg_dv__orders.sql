select
    {{ hash_key(['o.order_id']) }}                        as order_hk,
    {{ hash_key(['o.customer_id']) }}                     as customer_hk,
    {{ hash_key(['o.customer_id', 'o.order_id']) }}       as customer_order_hk,
    {{ hash_diff(['o.order_date', 'o.freight']) }}        as order_hash_diff,
    cast(o.order_id as integer)                           as order_id,
    cast(o.customer_id as integer)                        as customer_id,
    cast(o.order_date as date)                            as order_date,
    cast(o.freight as decimal(10, 2))                     as freight,
    cast(e.load_dts as timestamp)                         as load_dts,
    cast(e.record_source as varchar)                      as record_source
from {{ ref('dv_orders') }} as o
join {{ ref('dv_extracts') }} as e on e.extract_no = o.extract_no
where o.extract_no = {{ var('extract_no') }}
