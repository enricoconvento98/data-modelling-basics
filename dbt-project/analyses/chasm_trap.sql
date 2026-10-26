-- Chasm trap: shipments *--1 customers 1--* orders 1--* order_lines.
-- 3 lines x 2 shipments = 6 rows: freight 60, amount 200, ship_cost 36.
-- Run with: dbt show --select chasm_trap
select
    sum(o.freight)   as freight,
    sum(l.amount)    as amount,
    sum(s.ship_cost) as ship_cost
from {{ ref('stg_shop__customers') }} as c
join {{ ref('stg_shop__orders') }}      as o on o.customer_id = c.customer_id
join {{ ref('stg_shop__order_lines') }} as l on l.order_id    = o.order_id
join {{ ref('stg_shop__shipments') }}   as s on s.customer_id = c.customer_id
