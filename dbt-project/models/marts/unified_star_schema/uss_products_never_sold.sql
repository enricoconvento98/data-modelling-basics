-- Every product has a row on the 'products' stage, so unsold products are
-- in the bridge too: they just have no line key.
select
    p.product_id,
    p.product_name
from {{ ref('uss_bridge') }} as b
join {{ ref('stg_shop__products') }} as p on p.product_id = b._key_product
group by p.product_id, p.product_name
having count(b._key_line) = 0
