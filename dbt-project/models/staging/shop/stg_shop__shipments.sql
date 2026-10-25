select
    cast(shipment_id as integer)       as shipment_id,
    cast(customer_id as integer)       as customer_id,
    cast(ship_date as date)            as ship_date,
    cast(ship_cost as decimal(10, 2))  as ship_cost
from {{ ref('shop_shipments') }}
