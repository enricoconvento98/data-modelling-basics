select
    cast(product_id as integer)      as product_id,
    cast(product_name as varchar)    as product_name
from {{ ref('shop_products') }}
