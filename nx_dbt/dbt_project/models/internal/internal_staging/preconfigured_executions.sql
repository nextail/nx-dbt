{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'tenant'],
        incremental_strategy = 'merge',
        on_schema_change = 'sync_all_columns',
        cluster_by = ['tenant']
    )
}}
-- database names: aristocrazy_main_prod_db, suarez_main_prod_db

{% for tenant in var('all_tenants') %}

select
    *,
    '{{ tenant }}' as tenant,
from {{ source(tenant + '_globaldomain_public', 'preconfigured_execution') }}

{% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }}) and tenant = '{{ tenant }}'
{% endif %}

    {% if not loop.last and var('all_tenants') | length > 1 %}
    -- will append the next tenant if there are more than one tenant
    union all
    {% endif %}

{% endfor %} 