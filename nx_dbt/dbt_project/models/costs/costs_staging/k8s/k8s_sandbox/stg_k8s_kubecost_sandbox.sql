
{{
    config(
        materialized='incremental',
        unique_key=['pod_id'],

        post_hook="alter table {{ this }} set change_tracking = true",
    )
}}

select
    'SANDBOX' as k8s_environment,
    name as pod_id,
    avg(cpu) as avg_cpu,
    avg(gpu) as avg_gpu,
    avg(ram) as avg_ram,
    avg(pv) as avg_pv,
    avg(network) as avg_network,
    avg(loadbalancer) as avg_loadbalancer,
    avg(external) as avg_external,
    avg(shared) as avg_shared,
    avg(efficiency) as avg_efficiency,
    sum(total) as sum_total_cost,
    min(date) as start_date,
    max(date) as end_date,
from {{ source('kubecost', 'kubecost_cumulative_cost_by_pod_sandbox')}}

-- configure the incremental model.
-- If it's a regular execution, we only want to pull the data that has been updated since the last run.
-- If it's a full refresh, we want to pull all the data from a certain date.

{% if is_incremental() %}
    where date > (select max(start_date) from {{ this }})
{% endif %}
-- uncomment this to limit the full refresh to a certain date
-- {% if should_full_refresh() %}
--     where date >= '{{ var("full_refresh_start_date") }}'
-- {% endif %}

group by k8s_environment, pod_id