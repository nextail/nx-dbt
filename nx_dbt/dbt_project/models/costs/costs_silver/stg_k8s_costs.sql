{{ config
    (
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='downstream',
        snowflake_warehouse=var("DBT_WAREHOUSE"),
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",

        unique_key = 'pod_id'
    )
}}

select
    *
from {{ ref('stg_k8s_completed_jobs_all') }} cjs
left join {{ ref('stg_k8s_kubecost_all') }} ka
    using (pod_id, k8s_environment, start_date)