import os

from dagster import Definitions
from dagster_dbt import DbtCliResource

from .assets import nextail_internal_reporting
from .constants import dbt_project_dir
from .schedules import schedules

defs = Definitions(
    assets=[nextail_internal_reporting],
    schedules=schedules,
    resources={
        "dbt": DbtCliResource(project_dir=os.fspath(dbt_project_dir)),
    },
)