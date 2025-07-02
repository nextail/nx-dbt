# from dagster import Definitions

# from dagster_template.dagster.jobs.say_hello import say_hello_job
# from dagster_template.dagster.schedules.my_hourly_schedule import my_hourly_schedule
# from dagster_template.dagster.sensors.my_sensor import my_sensor

from nx_dbt.dagster.jobs.definitions import defs

defs = defs

# defs = Definitions(
#     jobs=[],
#     schedules=[daily_dbt_assets_schedule],
#     sensors=[],
# )
