-- Grain: one row per order line.
select
    d.date_key,
    c.customer_key,
    p.product_key,
    a.order_id,                 -- degenerate dimension
    a.line_id,
    a.amount,
    a.freight_allocated
from {{ ref('int_order_lines__freight_allocated') }} as a
join {{ ref('dim_customer') }} as c on c.customer_id = a.customer_id
join {{ ref('dim_product') }}  as p on p.product_id  = a.product_id
join {{ ref('dim_date') }}     as d on d.full_date   = a.order_date
