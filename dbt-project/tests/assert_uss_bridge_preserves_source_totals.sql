-- The bridge must hold every measure exactly once: its totals equal the
-- totals of the source tables. Returns a row (= failure) on any mismatch.
with bridge as (
    select sum(freight) as freight, sum(amount) as amount, sum(ship_cost) as ship_cost
    from {{ ref('uss_bridge') }}
),

source as (
    select
        (select sum(freight)   from {{ ref('stg_shop__orders') }})      as freight,
        (select sum(amount)    from {{ ref('stg_shop__order_lines') }}) as amount,
        (select sum(ship_cost) from {{ ref('stg_shop__shipments') }})   as ship_cost
)

select *
from bridge, source
where bridge.freight   is distinct from source.freight
   or bridge.amount    is distinct from source.amount
   or bridge.ship_cost is distinct from source.ship_cost
