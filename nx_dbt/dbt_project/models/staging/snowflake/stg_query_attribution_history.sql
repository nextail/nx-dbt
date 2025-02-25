{{
    config(
        materialized='incremental',
        unique_key='query_id'
    )
}}

with
    source as (
        select
            *
        from {{ source('snowflake', 'query_attribution_history') }}
    )

select * from source
-- configure the incremental model.
-- If it's a regular execution, we only want to pull the data that has been updated since the last run.
-- If it's a full refresh, we want to pull all the data from a certain date.

{% if is_incremental() %}
    where start_time > (select max(start_time) from {{ this }})
{% endif %}
{% if should_full_refresh() %}
    where start_time >= '2025-02-01'
{% endif %}