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
        job_name="costs_materialization",
        cron_schedule="0 */1 * * *", # every 1 hour starting at 00:00
        dbt_select="fqn:costs.*",
        schedule_name="costs_materialization",
    ),
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="materialize_snowflake",
        cron_schedule="*/30 * * * *", # every 30 minutes starting at 00:00
        dbt_select="fqn:staging.snowflake.stg_query_attribution_history+",
        schedule_name="materialize_snowflake",
    ),
]