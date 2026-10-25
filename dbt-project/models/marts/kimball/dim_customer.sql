select
    {{ hash_key(['customer_id']) }} as customer_key,
    customer_id,
    customer_name
from {{ ref('stg_shop__customers') }}
