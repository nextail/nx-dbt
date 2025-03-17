"""
To add a daily schedule that materializes your dbt assets, uncomment the following lines.
"""
from dagster_dbt import build_schedule_from_dbt_selection

from .assets import nx_internal_reporting_full

schedules = [
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="materialize_all",
        cron_schedule="0 */4 * * *", # every 4 hours starting at 00:00
        # dbt_select="+context.selected_asset_keys+",
        dbt_select="fqn:*"
    ),
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="materialize_snowflake",
        cron_schedule="*/5 * * * *", # every 5 minutes
        # dbt_select="+context.selected_asset_keys+",
        dbt_select="fqn:+staging.snowflake+"
    ),
]