{{
    config(
        materialized = 'incremental',
        unique_key = ['store_id', 'sku_id', 'date', 'tenant'],
        incremental_strategy = 'merge',
        on_schema_change = 'sync_all_columns',
        cluster_by = ['tenant'],
    )
}}

{% for tenant in var('all_tenants') %}

select
    *,
    '{{ tenant }}' as tenant,
from {{ source(tenant + '_globaldomain_public', 'sales') }}

    {% if is_incremental() %}
        where date >= (select max(date) from {{ this }}) and tenant = '{{ tenant }}'
    {% endif %}
    {% if should_full_refresh() %}
        -- uncomment this to remove the limit of the full refresh to a certain date
        where date >= '{{ var("full_refresh_start_date") }}'
    {% endif %}

    {% if not loop.last and var('all_tenants') | length > 1 %}
    -- will append the next tenant if there are more than one tenant
    union all
    {% endif %}

{% endfor %} 