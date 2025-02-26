{{ config
    (
        materialized="incremental",
        strategy="microbatch",
        unique_key="pod_id",
    )
}}

select
    *
from {{ ref('stg_k8s_completed_jobs_all') }} cjs
left join {{ ref('stg_k8s_kubecost_all') }} ka
    using (pod_id, k8s_environment, start_date)
{% if is_incremental() %}
    where start_time_utc > (select max(start_time_utc) from {{ this }})
{% endif %}