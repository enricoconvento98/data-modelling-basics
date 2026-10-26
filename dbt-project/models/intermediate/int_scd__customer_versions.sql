-- Real versions of each customer: change-log rows that do not change any
-- tracked attribute (city, customer_name) are dropped, so they cannot create
-- a new SCD Type 2 version.
with ordered as (
    select
        *,
        lag(city)          over w as previous_city,
        lag(customer_name) over w as previous_name
    from {{ ref('stg_scd__customer_changes') }}
    window w as (partition by customer_id order by effective_date)
)

select
    customer_id,
    customer_name,
    city,
    effective_date as valid_from
from ordered
where city is distinct from previous_city
   or customer_name is distinct from previous_name
