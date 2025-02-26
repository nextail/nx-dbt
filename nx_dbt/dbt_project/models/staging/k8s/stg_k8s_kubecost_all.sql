{{ config
    (
        materialized="incremental",
        unique_key=["pod_id", "start_date", "k8s_environment"],
    )
}}

with
    completed_jobs_prod as (
        select * from {{ ref('stg_k8s_kubecost_prod') }}
        {% if is_incremental() %}
        where
            start_date > (select max(start_date) from {{ this }})
            and k8s_environment = 'PROD'
        {% endif %}
    ),
    completed_jobs_sandbox as (
        select * from {{ ref('stg_k8s_kubecost_sandbox') }}
        {% if is_incremental() %}
        where
            start_date > (select max(start_date) from {{ this }})
            and k8s_environment = 'SANDBOX'
        {% endif %}
    )

select * from completed_jobs_prod
union all
select * from completed_jobs_sandbox