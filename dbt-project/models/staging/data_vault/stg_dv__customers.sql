-- One full extract of customers, selected by var('extract_no'), with the
-- Data Vault hash key, hash diff and load metadata computed once, here.
select
    {{ hash_key(['c.customer_id']) }}                     as customer_hk,
    {{ hash_diff(['c.customer_name', 'c.city']) }}        as customer_hash_diff,
    cast(c.customer_id as integer)                        as customer_id,
    cast(c.customer_name as varchar)                      as customer_name,
    cast(c.city as varchar)                               as city,
    cast(e.load_dts as timestamp)                         as load_dts,
    cast(e.record_source as varchar)                      as record_source
from {{ ref('dv_customers') }} as c
join {{ ref('dv_extracts') }} as e on e.extract_no = c.extract_no
where c.extract_no = {{ var('extract_no') }}
