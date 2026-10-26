-- Each sale points to the customer version valid on the sale date.
select
    s.sale_id,
    d.customer_sk,
    s.sale_date,
    s.amount
from {{ ref('stg_scd__sales') }} as s
join {{ ref('scd_dim_customer_type2') }} as d
  on d.customer_id = s.customer_id
 and s.sale_date >= d.valid_from
 and s.sale_date <  d.valid_to
