-- Every customer has exactly one current version, in the SCD Type 2 model
-- and in the dbt snapshot.
select 'scd_dim_customer_type2' as model, customer_id, count(*) as current_versions
from {{ ref('scd_dim_customer_type2') }}
where is_current
group by customer_id
having count(*) <> 1

union all

select 'snp_scd_customer', customer_id, count(*)
from {{ ref('snp_scd_customer') }}
where dbt_valid_to is null
group by customer_id
having count(*) <> 1
