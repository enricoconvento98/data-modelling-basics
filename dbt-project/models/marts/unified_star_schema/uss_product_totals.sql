-- Totals by product. Freight and ship_cost cannot be attributed to a product,
-- so they land on the NULL product row instead of being duplicated.
select
    p.product_id,
    coalesce(p.product_name, '(no product)') as product_name,
    coalesce(sum(b.amount), 0)    as amount,
    coalesce(sum(b.freight), 0)   as freight,
    coalesce(sum(b.ship_cost), 0) as ship_cost
from {{ ref('uss_bridge') }} as b
left join {{ ref('stg_shop__products') }} as p on p.product_id = b._key_product
group by p.product_id, p.product_name
