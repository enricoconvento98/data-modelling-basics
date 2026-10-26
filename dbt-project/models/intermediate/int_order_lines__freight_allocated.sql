-- Allocates order-level freight down to order lines, in proportion to amount.
-- Each share is rounded to cents; the rounding remainder goes to the largest
-- line (ties: lowest line_id) so the shares always add up to the order freight.
with lines as (
    select
        l.line_id,
        l.order_id,
        l.product_id,
        o.customer_id,
        o.order_date,
        l.amount,
        o.freight,
        round(o.freight * l.amount / nullif(sum(l.amount) over (partition by l.order_id), 0), 2)
            as freight_share_rounded,
        row_number() over (partition by l.order_id order by l.amount desc, l.line_id)
            as amount_rank
    from {{ ref('stg_shop__order_lines') }} as l
    join {{ ref('stg_shop__orders') }} as o on o.order_id = l.order_id
)

select
    line_id,
    order_id,
    product_id,
    customer_id,
    order_date,
    amount,
    cast(
        freight_share_rounded
        + case
            when amount_rank = 1
                then freight - sum(freight_share_rounded) over (partition by order_id)
            else 0
          end
        as decimal(10, 2)
    ) as freight_allocated
from lines
