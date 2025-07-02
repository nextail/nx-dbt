{{ config
    (
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='downstream',
        snowflake_warehouse=var("DBT_WAREHOUSE"),
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",

        unique_key=['query_id'],

    )
}}

with
    base as (
        select
            query_id,
            try_parse_json(query_tag) as parsed_query_tag,


            replace(replace(lower(parsed_query_tag:service::TEXT), ' ', '_'), '-', '_') as service,
            replace(replace(lower(parsed_query_tag:module::TEXT), ' ', '_'), '-', '_') as module,
            replace(replace(lower(parsed_query_tag:submodule::TEXT), ' ', '_'), '-', '_') as submodule,
            replace(replace(lower(parsed_query_tag:operation::TEXT), ' ', '_'), '-', '_') as operation,
            replace(replace(lower(parsed_query_tag:tenant::TEXT), ' ', '_'), '-', '_') as tenant,
            case
                when parsed_query_tag:environment::TEXT ilike 'prod' then 'production'
                else lower(parsed_query_tag:environment::TEXT)
            end as environment,
            lower(parsed_query_tag:correlation_id::TEXT) as correlation_id,
            lower(parsed_query_tag:execution_id::TEXT) as execution_id,
            lower(parse_json(parsed_query_tag:dbt_specific)) as dbt_specific,

            warehouse_name,
            user_name,
            start_time::DATE as start_date,
            start_time,
            end_time,
            datediff('millisecond', start_time, end_time) as query_duration_ms,
            credits_attributed_compute,
            credits_used_query_acceleration,
        from {{ ref('stg_query_attribution_history') }} sf
    )

select
    * exclude parsed_query_tag
from base