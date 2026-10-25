-- Grain: one row per shipment.
select
    d.date_key,
    c.customer_key,
    s.shipment_id,              -- degenerate dimension
    s.ship_cost
from {{ ref('stg_shop__shipments') }} as s
join {{ ref('dim_customer') }} as c on c.customer_id = s.customer_id
join {{ ref('dim_date') }}     as d on d.full_date   = s.ship_date
