-- One row per day between var('date_spine_start') and var('date_spine_end').
with days as (
    select cast(g as date) as full_date
    from generate_series(
        cast('{{ var("date_spine_start") }}' as timestamp),
        cast('{{ var("date_spine_end") }}' as timestamp),
        interval 1 day
    ) as t(g)
)

select
    cast(strftime(full_date, '%Y%m%d') as integer) as date_key,
    full_date,
    year(full_date)                                 as year,
    month(full_date)                                as month,
    strftime(full_date, '%Y-%m')                    as year_month,
    dayname(full_date)                              as day_name
from days
