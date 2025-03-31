{{
    config(
        materialized = 'table',
        unique_key = ['id', 'tenant']
    )
}}
-- database names: aristocrazy_main_prod_db, suarez_main_prod_db

{% for tenant in var('all_tenants') %}

select
    *,
    '{{ tenant }}' as tenant
from {{ source(tenant + '_globaldomain_public', 'cron') }}

-- can't use incremental logic here because the category table does not use a timestamp to track changes

    {% if not loop.last and var('all_tenants') | length > 1 %}
    -- will append the next tenant if there are more than one tenant
    union all
    {% endif %}

{% endfor %}

