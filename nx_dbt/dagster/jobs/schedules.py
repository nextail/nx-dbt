"""
To add a daily schedule that materializes your dbt assets, uncomment the following lines.
"""
from dagster_dbt import build_schedule_from_dbt_selection

from .assets import nx_internal_reporting_full

schedules = [
    # docs https://docs.dagster.io/api/python-api/libraries/dagster-dbt#dagster_dbt.build_schedule_from_dbt_selection
    # parameters:
    #   job_name (str) – The name of the job to materialize the dbt resources.
    #   cron_schedule (str) – The cron schedule to define the schedule.
    #   dbt_select (str) – A dbt selection string to specify a set of dbt resources.
    #   dbt_exclude (Optional[str]) – A dbt selection string to exclude a set of dbt resources.
    #   schedule_name (Optional[str]) – The name of the dbt schedule to create.
    #   tags (Optional[Mapping[str, str]]) – A dictionary of tags (string key-value pairs) to attach to the scheduled runs.
    #   config (Optional[RunConfig]) – The config that parameterizes the execution of this schedule.
    #   execution_timezone (Optional[str]) – Timezone in which the schedule should run. Supported strings for timezones are the ones provided by the IANA time zone database <https://www.iana.org/time-zones> - e.g. “America/Los_Angeles”.
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="costs_materialization_job",
        # cron_schedule="0 */12 * * *", # every 12 hours starting at 00:00
        cron_schedule="10 * * * *", # every hour at minute 10
        execution_timezone="UTC",
        dbt_select="fqn:costs.*",
        schedule_name="costs_materialization_schedule",
    ),
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="internal_materialization_job",
        # cron_schedule="0 5 * * *", # daily at 05:00 UTC
        cron_schedule="*/10 * * * *", # every 10 minutes for testing
        execution_timezone="UTC",
        dbt_select="fqn:internal.*",
        schedule_name="internal_materialization_schedule",
    ),
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="snowflake_query_attribution_job",
        cron_schedule="0 */1 * * *", # each hour starting at 00:00
        execution_timezone="UTC",
        dbt_select="fqn:stg_query_attribution_history",
        schedule_name="snowflake_query_attribution_schedule",
    ),
]