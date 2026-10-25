-- Current state: hub + latest satellite row.
with latest_sat as (
    select *
    from (
        select *, row_number() over (partition by customer_hk order by load_dts desc) as rn
        from {{ ref('sat_customer') }}
    ) as ranked
    where rn = 1
)

select h.customer_hk, h.customer_id, s.customer_name, s.city
from {{ ref('hub_customer') }} as h
join latest_sat as s on s.customer_hk = h.customer_hk
