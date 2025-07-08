{{
    config(
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='24 hours',
        snowflake_warehouse=var("DBT_WAREHOUSE"),
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",

        unique_key=['user', 'datetime'],
    )
}}

select
    *
from {{ ref('silver_okta_login_events') }}
