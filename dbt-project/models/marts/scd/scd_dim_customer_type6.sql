-- SCD Type 6: Type 2 versions plus the customer's current city on every version.
select
    v.*,
    cur.city as current_city
from {{ ref('scd_dim_customer_type2') }} as v
join {{ ref('scd_dim_customer_type2') }} as cur
  on cur.customer_id = v.customer_id
 and cur.is_current
