-- Fan trap: orders 1--* order_lines. freight is counted once per line (30, not 10).
-- Run with: dbt show --select fan_trap
select
    sum(o.freight) as freight,
    sum(l.amount)  as amount
from {{ ref('stg_shop__orders') }} as o
join {{ ref('stg_shop__order_lines') }} as l on l.order_id = o.order_id
