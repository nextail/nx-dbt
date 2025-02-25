
{{
    config(
        materialized='incremental'
    )
}}

select
    * exclude value
from {{ source('kubecost', 'kubecost_cumulative_cost_by_pod_pro')}}
-- configure the incremental model.
-- If it's a regular execution, we only want to pull the data that has been updated since the last run.
-- If it's a full refresh, we want to pull all the data from a certain date.

{% if is_incremental() %}
    where date > (select max(date) from {{ this }})
{% endif %}
{% if should_full_refresh() %}
    where date >= '2025-02-01'
{% endif %}