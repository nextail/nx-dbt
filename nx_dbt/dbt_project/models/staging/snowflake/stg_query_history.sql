{{
    config(
        materialized='incremental',
        unique_key='query_id',
        cluster_by=['query_tag'],
        enabled=false
    )
}}

with
    source as (
        select * from {{ source('snowflake', 'query_history') }}
    )

select * from source
{% if is_incremental() %}
where start_time > (select max(start_time) from {{ this }})
{% endif %}
{% if should_full_refresh() %}
where start_time >= '2025-02-01'
{% endif %}