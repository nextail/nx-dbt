"""
To add a daily schedule that materializes your dbt assets, uncomment the following lines.
"""
from dagster_dbt import build_schedule_from_dbt_selection
from dagster import DefaultScheduleStatus

from .assets import nx_internal_reporting_full

schedules = [
    # docs https://docs.dagster.io/api/python-api/libraries/dagster-dbt#dagster_dbt.build_schedule_from_dbt_selection
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="costs_materialization_job",
        cron_schedule="0 */12 * * *", # every 12 hours starting at 00:00
        # cron_schedule="10 * * * *", # every hour at minute 10
        execution_timezone="UTC",
        dbt_select="fqn:costs.*",
        schedule_name="costs_materialization_schedule",
        default_status=DefaultScheduleStatus.RUNNING
    ),
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="internal_materialization_job",
        cron_schedule="0 5 * * *", # daily at 05:00 UTC
        # cron_schedule="*/10 * * * *", # every 10 minutes for testing
        execution_timezone="UTC",
        dbt_select="fqn:internal.*",
        schedule_name="internal_materialization_schedule",
        default_status=DefaultScheduleStatus.RUNNING
    ),
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="snowflake_query_attribution_job",
        cron_schedule="5 */4 * * *", # each four hour starting at 00:05
        execution_timezone="UTC",
        dbt_select="fqn:stg_query_attribution_history",
        schedule_name="snowflake_query_attribution_schedule",
        default_status=DefaultScheduleStatus.RUNNING
    ),
]