{#-
  Fails for every pair of rows of the same entity whose half-open intervals
  [valid_from, valid_to) overlap. A NULL valid_to means "open-ended".
-#}
{% test no_overlapping_intervals(model, partition_by, valid_from, valid_to) %}

with rows_ as (
    select
        {{ partition_by }} as entity,
        {{ valid_from }}   as vf,
        coalesce({{ valid_to }}, cast('9999-12-31' as timestamp)) as vt,
        row_number() over () as row_id
    from {{ model }}
)

select a.entity, a.vf as a_from, a.vt as a_to, b.vf as b_from, b.vt as b_to
from rows_ as a
join rows_ as b
  on a.entity = b.entity
 and a.row_id < b.row_id
 and a.vf < b.vt
 and b.vf < a.vt

{% endtest %}
