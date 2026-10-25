-- Link: order contains product, with line_id as dependent child key.
select distinct
    order_line_hk,
    order_hk,
    product_hk,
    line_id,
    load_dts,
    record_source
from {{ ref('stg_dv__order_lines') }}
{% if is_incremental() %}
where order_line_hk not in (select order_line_hk from {{ this }})
{% endif %}
