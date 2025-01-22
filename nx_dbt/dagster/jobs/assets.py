from pathlib import Path

from dagster import AssetExecutionContext

from dagster_dbt import (
    DbtCliResource,
    DbtProject,
    build_schedule_from_dbt_selection,
    dbt_assets,
)

from .constants import dbt_manifest_path

RELATIVE_PATH_TO_MY_DBT_PROJECT = "./../../dbt_project"

dbt_project = DbtProject(
    project_dir=Path(__file__)
    .joinpath("..", RELATIVE_PATH_TO_MY_DBT_PROJECT)
    .resolve(),
)
dbt_project.prepare_if_dev()

@dbt_assets(manifest=dbt_project.manifest_path)
def nextail_internal_reporting(context: AssetExecutionContext, dbt: DbtCliResource):
    print('Hello!')
    print(context)
    yield from dbt.cli(["build"], context=context).stream()

