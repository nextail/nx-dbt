{{
    config(
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='downstream',
        snowflake_warehouse=var("DBT_WAREHOUSE"),
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",
        
        unique_key=['user'],
    )
}}

select 
    email,
    user_name,
    count(distinct ip) as unique_ip_count,
    array_agg(distinct country) as countries,
    array_agg(distinct device) as devices,
    min(datetime) as first_login_datetime,
    max(datetime) as last_login_datetime,
    count(distinct datetime) as login_count,
    array_agg(user_agent) within group (order by datetime desc)[0]::TEXT as last_user_agent
from {{ ref('stg_okta_login_events') }}
group by email, user_name