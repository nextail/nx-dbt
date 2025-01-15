from dagster import RunRequest, sensor

from dagster_template.dagster.jobs.say_hello import say_hello_job


@sensor(
    job=say_hello_job,
    description="""
    A sensor definition. This example sensor always requests a run at each sensor tick.

    For more hints on running jobs with sensors in Dagster, see our documentation overview on
    sensors:
    https://docs.dagster.io/overview/schedules-sensors/sensors
    """,
)
def my_sensor(_context):
    should_run = True
    if should_run:
        yield RunRequest(run_key=None, run_config={})