-- The satellite already is a Type 2 history; valid_to is derived, never stored.
select
    h.customer_id,
    s.customer_name,
    s.city,
    s.load_dts as valid_from,
    lead(s.load_dts) over (partition by s.customer_hk order by s.load_dts) as valid_to,
    s.record_source
from {{ ref('sat_customer') }} as s
join {{ ref('hub_customer') }} as h on h.customer_hk = s.customer_hk
