select
    cast(customer_id as integer)     as customer_id,
    cast(customer_name as varchar)   as customer_name,
    cast(city as varchar)            as city,
    cast(effective_date as date)     as effective_date
from {{ ref('scd_customer_changes') }}
