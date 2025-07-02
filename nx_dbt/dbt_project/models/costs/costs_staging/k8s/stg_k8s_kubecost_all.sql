{{ config
    (
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='downstream',
        snowflake_warehouse=var("DBT_WAREHOUSE"),
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",

        unique_key=["pod_id", "date", "k8s_environment"],
    )
}}

with
    completed_jobs_prod as (
        select * from {{ ref('stg_k8s_kubecost_prod') }}
    ),
    completed_jobs_sandbox as (
        select * from {{ ref('stg_k8s_kubecost_sandbox') }}
    )

select * from completed_jobs_prod
union all
select * from completed_jobs_sandbox