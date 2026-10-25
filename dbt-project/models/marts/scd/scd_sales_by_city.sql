-- Same facts, two perspectives (needs Type 6):
--   historical: city at the time of the sale
--   current   : city the customer is in now
select 'historical' as perspective, d.city as city, sum(f.amount) as amount
from {{ ref('scd_fact_sales') }} as f
join {{ ref('scd_dim_customer_type6') }} as d on d.customer_sk = f.customer_sk
group by d.city

union all

select 'current', d.current_city, sum(f.amount)
from {{ ref('scd_fact_sales') }} as f
join {{ ref('scd_dim_customer_type6') }} as d on d.customer_sk = f.customer_sk
group by d.current_city
