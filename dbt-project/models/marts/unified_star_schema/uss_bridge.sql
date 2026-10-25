-- The Puppini Bridge: one UNION ALL stage per table. Each row carries its own
-- key, every key reachable through many-to-one links, and only its own measures.
{{ config(alias='_bridge') }}

select
    'customers'                 as stage,
    customer_id                 as _key_customer,
    cast(null as integer)       as _key_order,
    cast(null as integer)       as _key_line,
    cast(null as integer)       as _key_product,
    cast(null as integer)       as _key_shipment,
    cast(null as decimal(10,2)) as freight,
    cast(null as decimal(10,2)) as amount,
    cast(null as decimal(10,2)) as ship_cost
from {{ ref('stg_shop__customers') }}

union all

select 'orders', customer_id, order_id, null, null, null, freight, null, null
from {{ ref('stg_shop__orders') }}

union all

select 'order_lines', o.customer_id, l.order_id, l.line_id, l.product_id, null, null, l.amount, null
from {{ ref('stg_shop__order_lines') }} as l
join {{ ref('stg_shop__orders') }} as o on o.order_id = l.order_id

union all

select 'products', null, null, null, product_id, null, null, null, null
from {{ ref('stg_shop__products') }}

union all

select 'shipments', customer_id, null, null, null, shipment_id, null, null, ship_cost
from {{ ref('stg_shop__shipments') }}
