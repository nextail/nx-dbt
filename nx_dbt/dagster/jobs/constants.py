import os
from pathlib import Path

from dagster_dbt import DbtCliResource

RELATIVE_PATH_TO_MY_DBT_PROJECT = "./../../dbt_project"
dbt_project_dir = Path(__file__).joinpath("..", RELATIVE_PATH_TO_MY_DBT_PROJECT).resolve()
dbt = DbtCliResource(project_dir=dbt_project_dir)

# If DAGSTER_DBT_PARSE_PROJECT_ON_LOAD is set, a manifest will be created at run time.
# Otherwise, we expect a manifest to be present in the project's target directory.
if os.getenv("DAGSTER_DBT_PARSE_PROJECT_ON_LOAD"):
    # create manifest file
    dbt_manifest_path = (
        dbt.cli(
            ["--quiet", "parse"],
            target_path=Path("target"),
        )
        .wait()
        .target_path.joinpath("manifest.json")
    )
else:
    # set manifest path
    dbt_manifest_path = dbt_project_dir.joinpath("target", "manifest.json")
