from dagster import schedule

from nx_dbt.dagster.jobs.say_hello import say_hello_job


@schedule(
    cron_schedule="0 * * * *",
    job=say_hello_job,
    execution_timezone="UTC",
    description="""
    A schedule definition. This example schedule runs once each hour.

    For more hints on running jobs with schedules in Dagster, see our documentation overview on
    schedules:
    https://docs.dagster.io/overview/schedules-sensors/schedules
    """,
)
def my_hourly_schedule(_context):
    run_config = {}
    return run_config
