-- Allocation must never create or lose money: per order, the allocated
-- shares add up to the order's freight exactly.
select o.order_id, o.freight, sum(a.freight_allocated) as allocated
from {{ ref('stg_shop__orders') }} as o
join {{ ref('int_order_lines__freight_allocated') }} as a on a.order_id = o.order_id
group by o.order_id, o.freight
having sum(a.freight_allocated) <> o.freight
