-- Drill-across over the two fact grains.
with orders as (
    select customer_hk, sum(freight) as freight
    from {{ ref('dv_fact_order') }}
    group by customer_hk
),

lines as (
    select customer_hk, sum(amount) as amount
    from {{ ref('dv_fact_order_line') }}
    group by customer_hk
)

select c.customer_id, c.customer_name, c.city, o.freight, l.amount
from {{ ref('dv_dim_customer') }} as c
left join orders as o on o.customer_hk = c.customer_hk
left join lines  as l on l.customer_hk = c.customer_hk
