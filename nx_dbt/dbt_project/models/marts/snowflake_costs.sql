with
    base as (
        select
            * exclude query_tag,
            try_parse_json(lower(query_tag)) as parsed_query_tag
        from {{ ref('stg_query_attribution_history') }}
        where parsed_query_tag is not null
    ),
    k8s as (
        select
            *
        from {{ ref('stg_k8s_kubecost') }}
    )

select
    query_id,
    parsed_query_tag,
    warehouse_name,
    user_name,
    start_time,
    credits_attributed_compute,
    parsed_query_tag:service::TEXT as service,
    parsed_query_tag:module::TEXT as module,
    parsed_query_tag:submodule::TEXT as submodule,
    parsed_query_tag:operation::TEXT as operation,
    parsed_query_tag:tenant::TEXT as tenant,
    parsed_query_tag:environment::TEXT as environment,
    parsed_query_tag:correlation_id::TEXT as correlation_id,
    parsed_query_tag:execution_id::TEXT as execution_id
from base

