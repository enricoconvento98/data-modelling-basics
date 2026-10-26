select
    cast(line_id as integer)         as line_id,
    cast(order_id as integer)        as order_id,
    cast(product_id as integer)      as product_id,
    cast(amount as decimal(10, 2))   as amount
from {{ ref('shop_order_lines') }}
