{{
    config
    (
        materialized="incremental",
        strategy="microbatch",
        unique_key=["start_date", "service", "module", "submodule", "operation", "tenant", "environment", "correlation_id", "execution_id"],
    )
}}


select
    start_date,
    min(start_time) as min_start_time,
    coalesce(service, 'NA') as service,
    coalesce(module, 'NA') as module,
    coalesce(submodule, 'NA') as submodule,
    coalesce(operation, 'NA') as operation,
    coalesce(tenant, 'NA') as tenant,
    coalesce(environment, 'NA') as environment,
    coalesce(correlation_id, 'NA') as correlation_id,
    coalesce(execution_id, 'NA') as execution_id,
    
    count(distinct query_id) as no_queries,
    sum(query_duration_ms) as sum_query_duration_ms,
    sum(credits_attributed_compute) as sum_credits_attributed_compute,
    sum(credits_used_query_acceleration) as sum_credits_used_query_acceleration

from {{ ref('stg_snowflake_costs') }}
{% if is_incremental() %}
    where
        start_time >= (select max(min_start_time) from {{ this }})
{% endif %}
group by start_date, service, module, submodule, operation, tenant, environment, correlation_id, execution_id