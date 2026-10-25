select
    cast(order_id as integer)        as order_id,
    cast(customer_id as integer)     as customer_id,
    cast(order_date as date)         as order_date,
    cast(freight as decimal(10, 2))  as freight
from {{ ref('shop_orders') }}
