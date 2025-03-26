from dagster import Definitions

from dagster_template.dagster.jobs.say_hello import say_hello_job
from dagster_template.dagster.schedules.my_hourly_schedule import my_hourly_schedule
from dagster_template.dagster.sensors.my_sensor import my_sensor

defs = Definitions(
    jobs=[say_hello_job],
    schedules=[my_hourly_schedule],
    sensors=[my_sensor],
)
