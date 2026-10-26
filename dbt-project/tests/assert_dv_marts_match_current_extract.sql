-- The source sends full extracts, so after loading extract N the information
-- mart must report exactly the totals of extract N.
with mart as (
    select sum(freight) as freight, sum(amount) as amount
    from {{ ref('dv_customer_totals') }}
),

extract as (
    select
        (select sum(freight) from {{ ref('stg_dv__orders') }})      as freight,
        (select sum(amount)  from {{ ref('stg_dv__order_lines') }}) as amount
)

select *
from mart, extract
where mart.freight is distinct from extract.freight
   or mart.amount  is distinct from extract.amount
