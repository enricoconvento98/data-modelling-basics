-- Grain: one row per order (same rule as the Kimball topic).
with latest_sat as (
    select *
    from (
        select *, row_number() over (partition by order_hk order by load_dts desc) as rn
        from {{ ref('sat_order') }}
    ) as ranked
    where rn = 1
)

select l.customer_hk, h.order_id, s.order_date, s.freight
from {{ ref('hub_order') }} as h
join {{ ref('link_customer_order') }} as l on l.order_hk = h.order_hk
join latest_sat as s on s.order_hk = h.order_hk
