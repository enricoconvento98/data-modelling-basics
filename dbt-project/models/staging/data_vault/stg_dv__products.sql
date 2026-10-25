select
    {{ hash_key(['p.product_id']) }}                      as product_hk,
    {{ hash_diff(['p.product_name']) }}                   as product_hash_diff,
    cast(p.product_id as integer)                         as product_id,
    cast(p.product_name as varchar)                       as product_name,
    cast(e.load_dts as timestamp)                         as load_dts,
    cast(e.record_source as varchar)                      as record_source
from {{ ref('dv_products') }} as p
join {{ ref('dv_extracts') }} as e on e.extract_no = p.extract_no
where p.extract_no = {{ var('extract_no') }}
