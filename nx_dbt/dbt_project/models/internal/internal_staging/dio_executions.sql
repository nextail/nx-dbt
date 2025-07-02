{{
    config(
        materialized = 'table',
        unique_key = ['id', 'tenant'],
        cluster_by = ['tenant']
    )
}}
-- database names: aristocrazy_main_prod_db, suarez_main_prod_db

{% for tenant in var('all_tenants') %}

select
    *,
    '{{ tenant }}' as tenant
from {{ source(tenant + '_globaldomain_public', 'dio_execution_selected') }}

-- can't use incremental logic here because the dio_execution_selected table does not use a timestamp to track changes

    {% if not loop.last and var('all_tenants') | length > 1 %}
    -- will append the next tenant if there are more than one tenant
    union all
    {% endif %}

{% endfor %} 