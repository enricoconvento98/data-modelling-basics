select
    cast(sale_id as integer)         as sale_id,
    cast(customer_id as integer)     as customer_id,
    cast(sale_date as date)          as sale_date,
    cast(amount as decimal(10, 2))   as amount
from {{ ref('scd_sales') }}
