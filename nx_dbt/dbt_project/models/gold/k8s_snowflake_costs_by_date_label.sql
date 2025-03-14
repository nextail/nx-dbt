{{
    config(
        materialized='incremental',
        strategy='microbatch',
        unique_key=['start_date', 'service', 'module', 'submodule', 'operation', 'tenant', 'environment', 'correlation_id', 'execution_id'],
        sort='start_date',
        tags=['costs', 'k8s', 'snowflake']
    )
}}

with
    sf_costs as (
        select
            start_date,
            coalesce(service, 'NA') as service,
            coalesce(module, 'NA') as module, 
            coalesce(submodule, 'NA') as submodule,
            coalesce(operation, 'NA') as operation,
            coalesce(tenant, 'NA') as tenant,
            coalesce(environment, 'NA') as environment,
            coalesce(correlation_id, 'NA') as correlation_id,
            coalesce(execution_id, 'NA') as execution_id,
            coalesce(no_queries, 0) as snowflake_no_queries,
            coalesce(sum_query_duration_ms, 0) as snowflake_total_query_duration_ms,
            coalesce(sum_credits_attributed_compute, 0) as snowflake_total_credits
        from {{ ref('snowflake_grouped_labels_per_date') }} snowflake
    ),
    k8s_costs as (
        select
            start_date,
            coalesce(service, 'NA') as service,
            coalesce(module, 'NA') as module,
            coalesce(submodule, 'NA') as submodule,
            coalesce(operation, 'NA') as operation,
            coalesce(tenant, 'NA') as tenant,
            coalesce(environment, 'NA') as environment,
            coalesce(correlation_id, 'NA') as correlation_id,
            coalesce(execution_id, 'NA') as execution_id,
            coalesce(no_pod_ids, 0) as k8s_no_pod_ids,
            coalesce(total_pods_duration_seconds, 0) as k8s_total_pods_duration_s,
            coalesce(total_cost, 0) as k8s_total_cost
        from {{ ref('k8s_grouped_labels_per_date')}}
    ),
    final as (
        select
            coalesce(sf.start_date, k.start_date) as start_date,
            coalesce(sf.service, k.service) as service,
            coalesce(sf.module, k.module) as module,
            coalesce(sf.submodule, k.submodule) as submodule,
            coalesce(sf.operation, k.operation) as operation,
            coalesce(sf.tenant, k.tenant) as tenant,
            coalesce(sf.environment, k.environment) as environment,
            coalesce(sf.correlation_id, k.correlation_id) as correlation_id,
            coalesce(sf.execution_id, k.execution_id) as execution_id,
            coalesce(sf.snowflake_no_queries, 0) as snowflake_no_queries,
            coalesce(sf.snowflake_total_query_duration_ms, 0) as snowflake_total_query_duration_ms,
            coalesce(sf.snowflake_total_credits, 0) as snowflake_total_credits,
            coalesce(k.k8s_no_pod_ids, 0) as k8s_no_pod_ids,
            coalesce(k.k8s_total_pods_duration_s, 0) as k8s_total_pods_duration_s,
            coalesce(k.k8s_total_cost, 0) as k8s_total_cost,
            coalesce(sf.snowflake_total_credits, 0) + coalesce(k.k8s_total_cost, 0) as total_cost
        from sf_costs sf
        full outer join k8s_costs k
            using (start_date, service, module, submodule, operation, tenant, environment, correlation_id, execution_id)
    )

select * from final
{% if is_incremental() %}
where start_date > (select max(start_date) from {{ this }})
{% endif %}