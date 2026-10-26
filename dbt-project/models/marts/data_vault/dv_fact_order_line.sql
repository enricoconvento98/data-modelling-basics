-- Grain: one row per order line.
with latest_sat as (
    select *
    from (
        select *, row_number() over (partition by order_line_hk order by load_dts desc) as rn
        from {{ ref('sat_order_line') }}
    ) as ranked
    where rn = 1
)

select lco.customer_hk, lol.product_hk, h.order_id, lol.line_id, s.amount
from {{ ref('link_order_line') }} as lol
join {{ ref('hub_order') }} as h on h.order_hk = lol.order_hk
join {{ ref('link_customer_order') }} as lco on lco.order_hk = lol.order_hk
join latest_sat as s on s.order_line_hk = lol.order_line_hk
