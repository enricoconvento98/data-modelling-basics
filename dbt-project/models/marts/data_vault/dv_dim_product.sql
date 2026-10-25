with latest_sat as (
    select *
    from (
        select *, row_number() over (partition by product_hk order by load_dts desc) as rn
        from {{ ref('sat_product') }}
    ) as ranked
    where rn = 1
)

select h.product_hk, h.product_id, s.product_name
from {{ ref('hub_product') }} as h
join latest_sat as s on s.product_hk = h.product_hk
