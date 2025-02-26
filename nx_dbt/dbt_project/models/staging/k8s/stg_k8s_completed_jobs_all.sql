{{ config
    (
        materialized="incremental",
        unique_key=["pod_id", "start_date", "k8s_environment"],
    )
}}

with
    completed_jobs_prod as (
        select * from {{ ref('stg_k8s_completed_jobs_prod') }}
        {% if is_incremental() %}
        where
            start_time_utc > (select max(start_time_utc) from {{ this }})
            and k8s_environment = 'PROD'
        {% endif %}
    ),
    completed_jobs_sandbox as (
        select * from {{ ref('stg_k8s_completed_jobs_sandbox') }}
        {% if is_incremental() %}
        where
            start_time_utc > (select max(start_time_utc) from {{ this }})
            and k8s_environment = 'SANDBOX'
        {% endif %}
    )

select * from completed_jobs_prod
union all
select * from completed_jobs_sandbox