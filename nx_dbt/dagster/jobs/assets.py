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
def nx_internal_reporting_full(context: AssetExecutionContext, dbt: DbtCliResource):
    # dbt_parse_invocation = dbt.cli(["parse"], context=context)
    # print(dbt_parse_invocation)
    # yield from dbt.cli(["debug"]).stream()
    yield from dbt.cli(["run"], context=context).stream()
