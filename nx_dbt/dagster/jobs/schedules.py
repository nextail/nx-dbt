"""
To add a daily schedule that materializes your dbt assets, uncomment the following lines.
"""
from dagster_dbt import build_schedule_from_dbt_selection

from .assets import nextail_internal_reporting

schedules = [
    build_schedule_from_dbt_selection(
        [nextail_internal_reporting],
        job_name="materialize_dbt_models",
        cron_schedule="0 0 * * *",
        # dbt_select="+context.selected_asset_keys+",
        dbt_select="fqn:*"
    ),
]