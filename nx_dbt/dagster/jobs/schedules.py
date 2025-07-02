import os

from dagster import DefaultScheduleStatus
from dagster_dbt import build_schedule_from_dbt_selection

from .assets import nx_internal_reporting_full

# Base tags configuration
base_tags = {
    "dagster-k8s/config": {
        "pod_template_spec_metadata": {
            "labels": {
                "service": "data-platform",
                "module": "internal-reporting",
                "submodule": "dbt_execution",
                "tenant": "nextail",
                "operation": None,
                "environment": os.getenv("NX_ENVIRONMENT"),
            }
        },
    },
    "owner": "data-platform",
    "tenant": "nextail",
    "domain": "data-reporting",
    "environment": os.getenv("NX_ENVIRONMENT"),
}


def get_tags_with_operation(operation: str) -> dict:
    """Helper function to create tags with a specific operation."""
    tags = base_tags.copy()
    tags["dagster-k8s/config"]["pod_template_spec_metadata"]["labels"]["operation"] = operation
    return tags


schedules = [
    # docs https://docs.dagster.io/api/python-api/libraries/dagster-dbt#dagster_dbt.build_schedule_from_dbt_selection
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="dbt_costs_materialization_job",
        cron_schedule="0 */12 * * *",  # every 12 hours starting at 00:00
        # cron_schedule="10 * * * *", # every hour at minute 10
        execution_timezone="UTC",
        dbt_select="fqn:costs.*",
        schedule_name="dbt_costs_materialization_schedule",
        default_status=DefaultScheduleStatus.RUNNING,
        tags=get_tags_with_operation("costs_materialization"),
    ),
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="dbt_internal_materialization_job",
        cron_schedule="0 5 * * *",  # daily at 05:00 UTC
        # cron_schedule="*/10 * * * *", # every 10 minutes for testing
        execution_timezone="UTC",
        dbt_select="fqn:internal.*",
        schedule_name="dbt_internal_materialization_schedule",
        default_status=DefaultScheduleStatus.RUNNING,
        tags=get_tags_with_operation("internal_materialization"),
    ),
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="dbt_snowflake_query_attribution_job",
        cron_schedule="5 */4 * * *",  # each four hour starting at 00:05
        execution_timezone="UTC",
        dbt_select="fqn:stg_query_attribution_history",
        schedule_name="dbt_snowflake_query_attribution_schedule",
        default_status=DefaultScheduleStatus.RUNNING,
        tags=get_tags_with_operation("snowflake_query_attribution"),
    ),
]
