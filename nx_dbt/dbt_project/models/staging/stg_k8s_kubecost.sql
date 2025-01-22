{{
    config(
        materialized='incremental'
    )
}}

select
    start_time_utc,
    end_time_utc,
    pod,
    image,
    max_memory_usage_bytes,
    max_cpu_usage,
    configured_memory_limit_bytes,
    configured_cpu_limit,
    configured_memory_request_bytes,
    configured_cpu_request,
    termination_reason,
    duration_seconds,
    pod_labels_json:app::TEXT as app,
    pod_labels_json:app_kubernetes_io_component::TEXT as app_kubernetes_io_component,
    pod_labels_json:app_kubernetes_io_instance::TEXT as app_kubernetes_io_instance,
    pod_labels_json:app_kubernetes_io_managed_by::TEXT as app_kubernetes_io_managed_by,
    pod_labels_json:app_kubernetes_io_name::TEXT as app_kubernetes_io_name,
    pod_labels_json:app_kubernetes_io_part_of::TEXT as app_kubernetes_io_part_of,
    pod_labels_json:app_kubernetes_io_version::TEXT as app_kubernetes_io_version,
    pod_labels_json:batch_kubernetes_io_controller_uid::TEXT as batch_kubernetes_io_controller_uid,
    pod_labels_json:batch_kubernetes_io_job_name::TEXT as batch_kubernetes_io_job_name,
    pod_labels_json:client::TEXT as client,
    pod_labels_json:controller_uid::TEXT as controller_uid,
    pod_labels_json:correlation_id::TEXT as correlation_id,
    pod_labels_json:cron::TEXT as cron,
    pod_labels_json:dagster_code_location::TEXT as dagster_code_location,
    pod_labels_json:dagster_job::TEXT as dagster_job,
    pod_labels_json:dagster_op::TEXT as dagster_op,
    pod_labels_json:dagster_run_id::TEXT as dagster_run_id,
    pod_labels_json:helm_sh_chart::TEXT as helm_sh_chart,
    pod_labels_json:job_name::TEXT as job_name,
    pod_labels_json:kind::TEXT as kind,
    pod_labels_json:module::TEXT as module,
    pod_labels_json:operation::TEXT as operation,
    pod_labels_json:phoenix_id::TEXT as phoenix_id,
    pod_labels_json:phoenix_queue::TEXT as phoenix_queue,
    pod_labels_json:release::TEXT as release,
    pod_labels_json:scheduled_by_phoenix::TEXT as scheduled_by_phoenix,
from {{ source('kubecost', 'completed_jobs_prod')}}
where
    start_time_utc >= dateadd('day', -3, current_date())
    {% if is_incremental() %}
    and start_time_utc > (select max(start_time_utc) from {{ this }})
    {% endif %}