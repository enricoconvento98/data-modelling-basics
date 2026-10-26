select
    cast(customer_id as integer)     as customer_id,
    cast(customer_name as varchar)   as customer_name
from {{ ref('shop_customers') }}
