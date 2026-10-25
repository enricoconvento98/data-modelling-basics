-- Drill-across by month through the conformed date dimension. Orders use
-- order date, shipments use ship date: each fact brings its own date key.
with lines as (
    select d.year_month, sum(f.amount) as amount
    from {{ ref('fact_order_line') }} as f
    join {{ ref('dim_date') }} as d on d.date_key = f.date_key
    group by d.year_month
),

orders as (
    select d.year_month, sum(f.freight) as freight
    from {{ ref('fact_order') }} as f
    join {{ ref('dim_date') }} as d on d.date_key = f.date_key
    group by d.year_month
),

shipments as (
    select d.year_month, sum(f.ship_cost) as ship_cost
    from {{ ref('fact_shipment') }} as f
    join {{ ref('dim_date') }} as d on d.date_key = f.date_key
    group by d.year_month
),

months as (
    select year_month from lines
    union
    select year_month from orders
    union
    select year_month from shipments
)

select
    m.year_month,
    o.freight,
    l.amount,
    s.ship_cost
from months as m
left join lines     as l on l.year_month = m.year_month
left join orders    as o on o.year_month = m.year_month
left join shipments as s on s.year_month = m.year_month
