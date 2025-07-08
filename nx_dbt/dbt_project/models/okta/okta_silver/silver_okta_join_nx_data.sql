{{
    config(
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='downstream',
        snowflake_warehouse=var("DBT_WAREHOUSE"),
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",

        unique_key=['email'],
    )
}}

select
    split(split(email, '@')[1], '.')[0]::TEXT as domain_name,
    *,
from {{ ref('silver_okta_first_last_logins') }}
left join {{ ref('users_unique') }} using (email)