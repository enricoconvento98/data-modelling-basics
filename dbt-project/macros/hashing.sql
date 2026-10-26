{#-
  Data Vault hashing helpers.

  hash_key  : MD5 of one or more business keys, normalised (trimmed, upper-cased,
              NULL -> '') so that ' acme ' and 'ACME' map to the same hub row.
  hash_diff : MD5 of descriptive attributes, NOT upper-cased, so that a change
              in case is still detected as a change.
-#}

{% macro hash_key(columns) -%}
    md5(
    {%- for col in columns -%}
        upper(trim(coalesce(cast({{ col }} as varchar), '')))
        {%- if not loop.last %} || '||' || {% endif -%}
    {%- endfor -%}
    )
{%- endmacro %}

{% macro hash_diff(columns) -%}
    md5(
    {%- for col in columns -%}
        coalesce(cast({{ col }} as varchar), '')
        {%- if not loop.last %} || '||' || {% endif -%}
    {%- endfor -%}
    )
{%- endmacro %}
