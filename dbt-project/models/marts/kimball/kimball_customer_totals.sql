-- Drill-across: aggregate each fact table on its own to the conformed
-- customer dimension, then join the one-row-per-customer results.
with lines as (
    select customer_key, sum(amount) as amount, sum(freight_allocated) as freight_allocated
    from {{ ref('fact_order_line') }}
    group by customer_key
),

orders as (
    select customer_key, sum(freight) as freight
    from {{ ref('fact_order') }}
    group by customer_key
),

shipments as (
    select customer_key, sum(ship_cost) as ship_cost
    from {{ ref('fact_shipment') }}
    group by customer_key
)

select
    c.customer_id,
    c.customer_name,
    o.freight,
    l.freight_allocated,
    l.amount,
    s.ship_cost
from {{ ref('dim_customer') }} as c
left join lines     as l on l.customer_key = c.customer_key
left join orders    as o on o.customer_key = c.customer_key
left join shipments as s on s.customer_key = c.customer_key
