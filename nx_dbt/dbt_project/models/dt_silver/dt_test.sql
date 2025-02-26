
{{ config
    (
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag="1 day",
        snowflake_warehouse="COMPUTE_WH",
        refresh_mode="INCREMENTAL",
        initialize="ON_SCHEDULE",
        enabled=false
    )
}}

select
    date_trunc('hour', start_time) as hour,
    service,
    module,
    submodule,
    operation,
    tenant,
    environment,
    correlation_id,
    execution_id,
    sum(credits_attributed_compute) as sum_credits_attributed_compute
from {{ ref('snowflake_costs') }}   
group by hour, service, module, submodule, operation, tenant, environment, correlation_id, execution_id