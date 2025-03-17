import os

from dagster import Definitions
from dagster_dbt import DbtCliResource

from .assets import nx_internal_reporting_full
from .constants import dbt_project_dir
from .schedules import schedules

defs = Definitions(
    assets=[nx_internal_reporting_full],
    schedules=schedules,
    resources={
        "dbt": DbtCliResource(project_dir=os.fspath(dbt_project_dir)),
    },
)
