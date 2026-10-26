-- The point-in-time lookup must neither drop sales (gap in the intervals)
-- nor duplicate them (overlap).
select
    (select count(*) from {{ ref('stg_scd__sales') }}) as source_sales,
    (select count(*) from {{ ref('scd_fact_sales') }}) as fact_sales
where (select count(*) from {{ ref('stg_scd__sales') }})
   <> (select count(*) from {{ ref('scd_fact_sales') }})
