select
    {{ hash_key(['product_id']) }} as product_key,
    product_id,
    product_name
from {{ ref('stg_shop__products') }}
