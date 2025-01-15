import warnings

from dagster import Definitions, ExperimentalWarning

from nx_dbt.dagster.jobs.say_hello import say_hello_job
from nx_dbt.dagster.schedules.my_hourly_schedule import my_hourly_schedule
from nx_dbt.dagster.sensors.my_sensor import my_sensor

warnings.filterwarnings("ignore", category=ExperimentalWarning)

defs = Definitions(
    jobs=[say_hello_job],
    schedules=[my_hourly_schedule],
    sensors=[my_sensor],
)
