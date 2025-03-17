{{
    config(
        materialized='incremental',
        strategy='microbatch',
        unique_key=['query_id'],
        
        post_hook="alter table {{ this }} set change_tracking = true",
    )
}}

with
    base as (
        select
            query_id,
            try_parse_json(query_tag) as parsed_query_tag,


            lower(parsed_query_tag:service::TEXT) as service,
            lower(parsed_query_tag:module::TEXT) as module,
            lower(parsed_query_tag:submodule::TEXT) as submodule,
            lower(parsed_query_tag:operation::TEXT) as operation,
            lower(parsed_query_tag:tenant::TEXT) as tenant,
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
{% if is_incremental() %}
    where
        start_time >= (select max(start_time) from {{ this }})
{% endif %}