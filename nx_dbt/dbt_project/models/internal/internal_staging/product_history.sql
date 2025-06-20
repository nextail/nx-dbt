{{
    config(
        materialized = 'incremental',
        unique_key = ['date', 'product_id', 'tenant'],
        incremental_strategy = 'merge',
        on_schema_change = 'sync_all_columns',
        cluster_by = ['tenant', 'product_id']
    )
}}
-- database names: aristocrazy_main_prod_db, suarez_main_prod_db

{% for tenant in var('all_tenants') %}

select
    *,
    '{{ tenant }}' as tenant,
from {{ source(tenant + '_globaldomain_public', 'product_history') }}

{% if is_incremental() %}
    where date > (select max(date) from {{ this }}) and tenant = '{{ tenant }}'
{% endif %}

{% if should_full_refresh() %}
        -- uncomment this to remove the limit of the full refresh to a certain date
    where date >= '2025-01-01'
{% endif %}

{% if not loop.last and var('all_tenants') | length > 1 %}
    -- will append the next tenant if there are more than one tenant
    union all
{% endif %}

{% endfor %}