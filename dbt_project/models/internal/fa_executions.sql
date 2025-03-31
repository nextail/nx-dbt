{{
    config(
        materialized = 'incremental',
        unique_key = ['id', 'tenant']
    )
}}
-- database names: aristocrazy_main_prod_db, suarez_main_prod_db

{% for tenant in var('all_tenants') %}

select
    *,
    '{{ tenant }}' as tenant
from {{ source(tenant + '_globaldomain_public', 'first_allocation_execution') }}

-- incremental logic
{% if is_incremental() %}
where updated_at > (select max(updated_at) from {{ this }}) and tenant = '{{ tenant }}'
{% endif %}

    {% if not loop.last and var('all_tenants') | length > 1 %}
    -- will append the next tenant if there are more than one tenant
    union all
    {% endif %}

{% endfor %}

