"""
To add a daily schedule that materializes your dbt assets, uncomment the following lines.
"""
from dagster_dbt import build_schedule_from_dbt_selection

from .assets import nx_internal_reporting_full

schedules = [
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="materialize_all",
        cron_schedule="0 */1 * * *", # every 1 hour starting at 00:00
        # dbt_select="+context.selected_asset_keys+",
        dbt_select="fqn:*"
    ),
    build_schedule_from_dbt_selection(
        [nx_internal_reporting_full],
        job_name="materialize_snowflake",
        cron_schedule="*/30 * * * *", # every 30 minutes starting at 00:00
        # dbt_select="+context.selected_asset_keys+",
        dbt_select="fqn:staging.snowflake.stg_query_attribution_history"
        # dbt_select="source:snowflake+"
    ),
]