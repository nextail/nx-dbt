{{
    config(
        materialized='incremental',
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

    -- official labels
    pod_labels_json:service::TEXT as label_service,
    pod_labels_json:module::TEXT as label_module,
    pod_labels_json:submodule::TEXT as label_submodule,
    pod_labels_json:operation::TEXT as label_operation,
    pod_labels_json:tenant::TEXT as label_tenant,
    pod_labels_json:environment::TEXT as label_environment,
    pod_labels_json:correlation_id::TEXT as label_correlation_id,
    pod_labels_json:execution_id::TEXT as label_execution_id,
    
    -- deprecated labels
    pod_labels_json:controller_uid::TEXT as label_controller_uid,
    pod_labels_json:batch_kubernetes_io_job_name::TEXT as label_batch_kubernetes_io_job_name,
    pod_labels_json:job_name::TEXT as label_job_name,
    pod_labels_json:batch_kubernetes_io_controller_uid::TEXT as label_batch_kubernetes_io_controller_uid,
    pod_labels_json:client::TEXT as label_client,
    pod_labels_json:scheduled_by_phoenix::TEXT as label_scheduled_by_phoenix,
    pod_labels_json:phoenix_queue::TEXT as label_phoenix_queue,
    pod_labels_json:phoenix_id::TEXT as label_phoenix_id,
    pod_labels_json:app_kubernetes_io_instance::TEXT as label_app_kubernetes_io_instance,
    pod_labels_json:app_kubernetes_io_name::TEXT as label_app_kubernetes_io_name,
    pod_labels_json:app_kubernetes_io_version::TEXT as label_app_kubernetes_io_version,
    pod_labels_json:dagster_job::TEXT as label_dagster_job,
    pod_labels_json:app_kubernetes_io_component::TEXT as label_app_kubernetes_io_component,
    pod_labels_json:app_kubernetes_io_part_of::TEXT as label_app_kubernetes_io_part_of,
    pod_labels_json:dagster_run_id::TEXT as label_dagster_run_id,
    pod_labels_json:dagster_code_location::TEXT as label_dagster_code_location,
    pod_labels_json:cron::TEXT as label_cron,
    pod_labels_json:"app"::TEXT as label_app,
    pod_labels_json:dagster_op::TEXT as label_dagster_op,
    pod_labels_json:kind::TEXT as label_kind,
    pod_labels_json:release::TEXT as label_release,
    pod_labels_json:app_kubernetes_io_managed_by::TEXT as label_app_kubernetes_io_managed_by,
    pod_labels_json:helm_sh_chart::TEXT as label_helm_sh_chart,
from {{ source('completed_jobs', 'completed_jobs_prod')}}
-- configure the incremental model.
-- If it's a regular execution, we only want to pull the data that has been updated since the last run.
-- If it's a full refresh, we want to pull all the data from a certain date.

{% if is_incremental() %}
    where start_time_utc > (select max(start_time_utc) from {{ this }})
{% endif %}
{% if should_full_refresh() %}
    where start_time_utc >= '2025-02-01'
{% endif %}