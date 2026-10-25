-- Grain: one row per order.
select
    d.date_key,
    c.customer_key,
    o.order_id,                 -- degenerate dimension
    o.freight
from {{ ref('stg_shop__orders') }} as o
join {{ ref('dim_customer') }} as c on c.customer_id = o.customer_id
join {{ ref('dim_date') }}     as d on d.full_date   = o.order_date
