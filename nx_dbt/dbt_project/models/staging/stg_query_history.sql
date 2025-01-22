{{
    config(
        materialized='incremental',
        unique_key='query_id',
        cluster_by=['query_tag']
    )
}}

with
    source as (
        select * from {{ source('snowflake', 'query_history') }}
        -- where start_time = last 3 days
        -- where start_time >= dateadd('day', -3, current_date())
    )

select * from source
{% if is_incremental() %}
where start_time > (select max(start_time) from {{ this }})
{% endif %}
{% if should_full_refresh() %}
where start_time >= '2025-01-01'
{% endif %}