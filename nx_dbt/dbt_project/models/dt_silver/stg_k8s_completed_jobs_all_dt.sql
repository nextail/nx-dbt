{{ config
    (
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag="8 hours",
        snowflake_warehouse="COMPUTE_WH",
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",

        unique_key=["pod_id", "date", "k8s_environment"],
    )
}}

with
    completed_jobs_prod as (
        select * from {{ ref('stg_k8s_completed_jobs_prod') }}
    ),
    completed_jobs_sandbox as (
        select * from {{ ref('stg_k8s_completed_jobs_sandbox') }}
    )

select * from completed_jobs_prod
union all
select * from completed_jobs_sandbox