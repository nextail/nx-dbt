{{
    config
    (
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='8 hours',
        snowflake_warehouse=var("DBT_WAREHOUSE"),
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",

        unique_key=['start_date', 'service', 'module', 'submodule', 'operation', 'tenant', 'environment', 'correlation_id', 'execution_id'],
    )
}}

with
    sf_costs as (
        select
            start_date,
            service,
            module,
            submodule,
            operation,
            tenant,
            environment,
            correlation_id,
            execution_id,
            no_queries as snowflake_no_queries,
            sum_query_duration_ms as snowflake_total_query_duration_ms,
            sum_credits_attributed_compute as snowflake_total_credits,
        from {{ ref('snowflake_grouped_labels_per_date') }} snowflake
    ),
    k8s_costs as (
        select
            start_date,
            service,
            module,
            submodule,
            operation,
            tenant,
            environment,
            correlation_id,
            execution_id,
            no_pod_ids as k8s_no_pod_ids,
            total_pods_duration_seconds as k8s_total_pods_duration_s,
            total_cost as k8s_total_cost,
        from {{ ref('k8s_grouped_labels_per_date')}}
    ),
    j as (
        select
            *
        from sf_costs
        full outer join k8s_costs
            using (start_date, service, module, submodule, operation, tenant, environment, correlation_id, execution_id)
        
    ),
    coalesce_nulls as (
        select
            start_date,
            service,
            module,
            submodule,
            operation,
            tenant,
            environment,
            correlation_id,
            execution_id,
            coalesce(snowflake_no_queries, 0) as snowflake_no_queries,
            coalesce(snowflake_total_query_duration_ms, 0) as snowflake_total_query_duration_ms,
            coalesce(snowflake_total_credits, 0) as snowflake_total_credits,
            coalesce(k8s_no_pod_ids, 0) as k8s_no_pod_ids,
            coalesce(k8s_total_pods_duration_s, 0) as k8s_total_pods_duration_s,
            coalesce(k8s_total_cost, 0) as k8s_total_cost,
        from j
    )

select
    start_date,
    service,
    module,
    submodule,
    operation,
    tenant,
    environment,
    correlation_id,
    execution_id,
    snowflake_no_queries,
    snowflake_total_query_duration_ms,
    snowflake_total_credits,
    k8s_no_pod_ids,
    k8s_total_pods_duration_s,
    k8s_total_cost,
    snowflake_total_credits * 3.3 + k8s_total_cost as total_cost_usd,
    -- true if service AND module AND submodule are not "NA"; otherwise false
    case
        when service <> 'NA' and module <> 'NA' and submodule <> 'NA' then true
        else false
    end as is_service_module_submodule_valid,

    case
        when is_service_module_submodule_valid then concat_ws('-', service, module)
        else 'NA'
    end as service_module,
    case
        when is_service_module_submodule_valid then concat_ws('-', service, module, submodule)
        else 'NA'
    end as service_module_submodule,
    case
        when is_service_module_submodule_valid then concat_ws('-', service, module, submodule, operation)
        else 'NA'
    end as service_module_submodule_operation,
    case
        when is_service_module_submodule_valid then concat_ws('-', service, module, submodule, operation, tenant)
        else 'NA'
    end as service_module_submodule_operation_tenant,
    case
        when is_service_module_submodule_valid then concat_ws('-', service, module, submodule, operation, tenant, environment)
        else 'NA'
    end as service_module_submodule_operation_tenant_environment
from coalesce_nulls
