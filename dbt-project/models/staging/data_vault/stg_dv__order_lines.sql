select
    {{ hash_key(['l.order_id', 'l.product_id', 'l.line_id']) }} as order_line_hk,
    {{ hash_key(['l.order_id']) }}                        as order_hk,
    {{ hash_key(['l.product_id']) }}                      as product_hk,
    {{ hash_diff(['l.amount']) }}                         as order_line_hash_diff,
    cast(l.line_id as integer)                            as line_id,
    cast(l.order_id as integer)                           as order_id,
    cast(l.product_id as integer)                         as product_id,
    cast(l.amount as decimal(10, 2))                      as amount,
    cast(e.load_dts as timestamp)                         as load_dts,
    cast(e.record_source as varchar)                      as record_source
from {{ ref('dv_order_lines') }} as l
join {{ ref('dv_extracts') }} as e on e.extract_no = l.extract_no
where l.extract_no = {{ var('extract_no') }}
