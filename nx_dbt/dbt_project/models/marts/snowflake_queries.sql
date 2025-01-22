{{
    config(
        materialized='incremental',
        unique_key='query_id'
    )
}}

with
    qh as (
        select
            *
        from {{ ref('stg_query_history') }}
    ),
    qah as (
        select
            query_id,
            parent_query_id,
            root_query_id,
            warehouse_id as warehouse_id_qah,
            warehouse_name as warehouse_name_qah,
            query_hash as query_hash_qah,
            query_parameterized_hash as query_parameterized_hash_qah,
            query_tag as query_tag_qah,
            user_name as user_name_qah,
            credits_attributed_compute as credits_attributed_compute_qah,
            credits_used_query_acceleration as credits_used_query_acceleration_qah,
        from {{ ref('stg_query_attribution_history') }}
    )

select * from qh
left join qah
    using (query_id)
{% if is_incremental() %}
where start_time > (select max(start_time) from {{ this }})
{% endif %}

