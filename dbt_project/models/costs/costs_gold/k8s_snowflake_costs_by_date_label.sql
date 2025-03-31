{{
    config
    (
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='2 hours',
        snowflake_warehouse="COMPUTE_WH",
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
        from {{ ref('snowflake_grouped_labels_per_date_dt') }} snowflake
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
    )

select * from sf_costs
full outer join k8s_costs
    using (start_date, service, module, submodule, operation, tenant, environment, correlation_id, execution_id)