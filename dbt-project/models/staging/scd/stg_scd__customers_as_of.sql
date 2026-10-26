-- The source system's customer table as it looked on var('scd_as_of'):
-- the latest real version of each customer effective on or before that date.
-- This is what a dbt snapshot would see if it ran on that day.
select
    customer_id,
    customer_name,
    city,
    cast(valid_from as timestamp) as updated_at
from (
    select
        v.*,
        row_number() over (partition by customer_id order by valid_from desc) as rn
    from {{ ref('int_scd__customer_versions') }} as v
    where valid_from <= cast('{{ var("scd_as_of") }}' as date)
) as latest
where rn = 1
