{{
    config(
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='downstream',
        snowflake_warehouse=var("DBT_WAREHOUSE"),
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",
    )
}}

select
    email,
    tenant,
    sum(sign_in_count) as sum_sign_in_count,
    min(created_at) as min_created_at,
    max(last_sign_in_at) as max_sign_in_at,
    max(updated_at) as max_updated_at,
    BOOLOR_AGG(super_admin) as is_super_admin,
    BOOLOR_AGG(can_change_store) as can_change_store,
    BOOLOR_AGG(is_active) as is_active,
    BOOLOR_AGG(staff) as is_staff,
    BOOLOR_AGG(support) as is_support,
    BOOLOR_AGG(infrastructure) as is_infrastructure,
from {{ ref('admin_users') }}
group by email, tenant