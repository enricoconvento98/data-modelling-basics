-- Two different models, one answer: per customer, the Unified Star Schema and
-- the Kimball drill-across must report identical freight, amount and ship_cost,
-- and both must match totals computed straight from the source tables.
with source as (
    select
        c.customer_id,
        (select sum(freight)   from {{ ref('stg_shop__orders') }}      as o where o.customer_id = c.customer_id) as freight,
        (select sum(l.amount)  from {{ ref('stg_shop__order_lines') }} as l
                               join {{ ref('stg_shop__orders') }} as o on o.order_id = l.order_id
                               where o.customer_id = c.customer_id) as amount,
        (select sum(ship_cost) from {{ ref('stg_shop__shipments') }}   as s where s.customer_id = c.customer_id) as ship_cost
    from {{ ref('stg_shop__customers') }} as c
)

select s.customer_id, s.freight, s.amount, s.ship_cost,
       u.freight as uss_freight, u.amount as uss_amount, u.ship_cost as uss_ship_cost,
       k.freight as kimball_freight, k.freight_allocated as kimball_freight_allocated,
       k.amount as kimball_amount, k.ship_cost as kimball_ship_cost
from source as s
left join {{ ref('uss_customer_totals') }}     as u on u.customer_id = s.customer_id
left join {{ ref('kimball_customer_totals') }} as k on k.customer_id = s.customer_id
where s.freight   is distinct from u.freight
   or s.amount    is distinct from u.amount
   or s.ship_cost is distinct from u.ship_cost
   or s.freight   is distinct from k.freight
   or s.freight   is distinct from k.freight_allocated
   or s.amount    is distinct from k.amount
   or s.ship_cost is distinct from k.ship_cost
