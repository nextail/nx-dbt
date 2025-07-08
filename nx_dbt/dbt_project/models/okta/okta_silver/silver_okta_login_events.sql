{{
    config(
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='downstream',
        snowflake_warehouse=var("DBT_WAREHOUSE"),
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",
        
        unique_key=['user', 'datetime'],
    )
}}

select 
    *,
    row_number() over (partition by user order by datetime desc) as login_event_number
from {{ ref('stg_okta_login_events') }}