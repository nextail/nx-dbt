{{
    config
    (
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='downstream',
        snowflake_warehouse="COMPUTE_WH",
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",
        
        unique_key=["k8s_environment", "start_date", "service", "module", "submodule", "operation", "tenant", "environment", "correlation_id", "execution_id"],
    )
}}

select
    k8s_environment,
    start_date,
    -- min(end_date) as min_end_date,
    -- max(end_date) as max_end_date,
    
    sum(SUM_TOTAL_COST) as total_cost,

    -- official labels
    coalesce(label_service, 'NA') as service,
    coalesce(label_module, 'NA') as module,
    coalesce(label_submodule, 'NA') as submodule,
    coalesce(label_operation, 'NA') as operation,
    coalesce(label_tenant, 'NA') as tenant,
    coalesce(label_environment, 'NA') as environment,
    coalesce(label_correlation_id, 'NA') as correlation_id,
    coalesce(label_execution_id, 'NA') as execution_id,

    -- others
    count(pod_id) as no_pod_ids,
    count(distinct image) as no_unique_images,
    sum(pod_duration_seconds) as total_pods_duration_seconds,
    count_if(termination_reason = 'Completed') as no_completed_pods,
    count_if(termination_reason = 'Error') as no_error_pods,
    count_if(termination_reason = 'OOMKilled') as no_killed_pods,
    
from {{ ref('stg_k8s_costs') }}
{% if is_incremental() %}
    where
        start_date >= (select max(start_date) from {{ this }})
{% endif %}
group by k8s_environment, start_date, service, module, submodule, operation, tenant, environment, correlation_id, execution_id