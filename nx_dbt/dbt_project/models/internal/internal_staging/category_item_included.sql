{{
    config(
        materialized = 'table',
        unique_key = ['category_id', 'item_id', 'tenant'],
        on_schema_change = 'sync_all_columns',
        cluster_by = ['tenant'],
    )
}}

{% for tenant in var('all_tenants') %}

select
    *,
    '{{ tenant }}' as tenant,
from {{ source(tenant + '_globaldomain_public', 'category_item_included') }}

    {% if not loop.last and var('all_tenants') | length > 1 %}
    -- will append the next tenant if there are more than one tenant
    union all
    {% endif %}

{% endfor %} 