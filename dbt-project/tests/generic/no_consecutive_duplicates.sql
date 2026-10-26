{#-
  Fails when two consecutive rows of the same entity carry the same value.
  On a satellite this means a row was inserted although nothing changed.
-#}
{% test no_consecutive_duplicates(model, partition_by, order_by, column) %}

select *
from (
    select
        {{ partition_by }} as entity,
        {{ order_by }}     as position,
        {{ column }}       as value,
        lag({{ column }}) over (partition by {{ partition_by }} order by {{ order_by }}) as previous_value
    from {{ model }}
) as ordered
where value = previous_value

{% endtest %}
