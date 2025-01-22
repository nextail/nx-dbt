import warnings

from dagster import Definitions, ExperimentalWarning

# from nx_dbt.dagster.jobs.say_hello import say_hello_job
# from nx_dbt.dagster.schedules.my_hourly_schedule import my_hourly_schedule
# from nx_dbt.dagster.sensors.my_sensor import my_sensor

# from nx_dbt.dagster.jobs.say_hello import daily_dbt_assets_schedule, dbt_project

from nx_dbt.dagster.jobs.definitions import defs

warnings.filterwarnings("ignore", category=ExperimentalWarning)

defs = defs

# defs = Definitions(
#     jobs=[],
#     schedules=[daily_dbt_assets_schedule],
#     sensors=[],
# )
