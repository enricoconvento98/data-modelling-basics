-- SCD Type 1: one row per customer, latest values only. History is lost.
select customer_id, customer_name, city
from (
    select
        *,
        row_number() over (partition by customer_id order by valid_from desc) as rn
    from {{ ref('int_scd__customer_versions') }}
) as latest
where rn = 1
