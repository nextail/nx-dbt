{{
    config(
        materialized='incremental',
        unique_key=["pod_id", "start_date"],

        post_hook="alter table {{ this }} set change_tracking = true",
    )
}}

select
    pod as pod_id,
    
    'SANDBOX' as k8s_environment,
    
    start_time_utc::DATE as start_date,
    start_time_utc,
    end_time_utc,
    datediff('seconds', start_time_utc, end_time_utc) as pod_duration_seconds,
    
    image,
    max_memory_usage_bytes,
    max_cpu_usage,
    configured_memory_limit_bytes,
    configured_cpu_limit,
    configured_memory_request_bytes,
    configured_cpu_request,
    termination_reason,
    duration_seconds,

    -- official labels.
    -- Replace hyphens with underscores and lowercase the text.
    -- If the label is string 'null', we want to return sql null.
    nullif(replace(lower(pod_labels_json:service::TEXT), '-', '_'), 'null') as label_service,
    nullif(replace(lower(pod_labels_json:module::TEXT), '-', '_'), 'null') as label_module,
    nullif(replace(lower(pod_labels_json:submodule::TEXT), '-', '_'), 'null') as label_submodule,
    nullif(replace(lower(pod_labels_json:operation::TEXT), '-', '_'), 'null') as label_operation,
    nullif(replace(lower(pod_labels_json:tenant::TEXT), '-', '_'), 'null') as label_tenant,
    nullif(replace(lower(pod_labels_json:environment::TEXT), '-', '_'), 'null') as label_environment,
    nullif(lower(pod_labels_json:correlation_id::TEXT), 'null') as label_correlation_id,
    nullif(lower(pod_labels_json:execution_id::TEXT), 'null') as label_execution_id,
    
    -- deprecated labels
    nullif(pod_labels_json:controller_uid::TEXT, 'null') as label_controller_uid,
    nullif(pod_labels_json:batch_kubernetes_io_job_name::TEXT, 'null') as label_batch_kubernetes_io_job_name,
    nullif(pod_labels_json:job_name::TEXT, 'null') as label_job_name,
    nullif(pod_labels_json:batch_kubernetes_io_controller_uid::TEXT, 'null') as label_batch_kubernetes_io_controller_uid,
    nullif(pod_labels_json:client::TEXT, 'null') as label_client,
    nullif(pod_labels_json:scheduled_by_phoenix::TEXT, 'null') as label_scheduled_by_phoenix,
    nullif(pod_labels_json:phoenix_queue::TEXT, 'null') as label_phoenix_queue,
    nullif(pod_labels_json:phoenix_id::TEXT, 'null') as label_phoenix_id,
    nullif(pod_labels_json:app_kubernetes_io_instance::TEXT, 'null') as label_app_kubernetes_io_instance,
    nullif(pod_labels_json:app_kubernetes_io_name::TEXT, 'null') as label_app_kubernetes_io_name,
    nullif(pod_labels_json:app_kubernetes_io_version::TEXT, 'null') as label_app_kubernetes_io_version,
    nullif(pod_labels_json:dagster_job::TEXT, 'null') as label_dagster_job,
    nullif(pod_labels_json:app_kubernetes_io_component::TEXT, 'null') as label_app_kubernetes_io_component,
    nullif(pod_labels_json:app_kubernetes_io_part_of::TEXT, 'null') as label_app_kubernetes_io_part_of,
    nullif(pod_labels_json:dagster_run_id::TEXT, 'null') as label_dagster_run_id,
    nullif(pod_labels_json:dagster_code_location::TEXT, 'null') as label_dagster_code_location,
    nullif(pod_labels_json:cron::TEXT, 'null') as label_cron,
    nullif(pod_labels_json:"app"::TEXT, 'null') as label_app,
    nullif(pod_labels_json:dagster_op::TEXT, 'null') as label_dagster_op,
    nullif(pod_labels_json:kind::TEXT, 'null') as label_kind,
    nullif(pod_labels_json:release::TEXT, 'null') as label_release,
    nullif(pod_labels_json:app_kubernetes_io_managed_by::TEXT, 'null') as label_app_kubernetes_io_managed_by,
    nullif(pod_labels_json:helm_sh_chart::TEXT, 'null') as label_helm_sh_chart,
from {{ source('completed_jobs', 'completed_jobs_sandbox')}}
-- configure the incremental model.
-- If it's a regular execution, we only want to pull the data that has been updated since the last run.
-- If it's a full refresh, we want to pull all the data from a certain date.

{% if is_incremental() %}
    where start_time_utc > (select max(start_time_utc) from {{ this }})
{% endif %}
-- uncomment this to limit the full refresh to a certain date
-- {% if should_full_refresh() %}
--     where start_time_utc >= '{{ var("full_refresh_start_date") }}'
-- {% endif %}