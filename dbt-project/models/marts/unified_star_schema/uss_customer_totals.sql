-- Totals by customer through the bridge: bridge LEFT JOIN table, nothing else.
select
    c.customer_id,
    c.customer_name,
    sum(b.freight)   as freight,
    sum(b.amount)    as amount,
    sum(b.ship_cost) as ship_cost
from {{ ref('uss_bridge') }} as b
left join {{ ref('stg_shop__customers') }} as c on c.customer_id = b._key_customer
where c.customer_id is not null
group by c.customer_id, c.customer_name
