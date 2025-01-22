# # from dagster import MetadataValue, job

# # from nx_dbt.dagster.ops.hello import hello


# # @job(
# #     name="_say_hello_job",
# #     metadata={
# #         "owner": "nextail-squad",  # will be converted to MetadataValue.text
# #         "tenant": "nextail-tenant",  # will be converted to MetadataValue.text
# #         "domain": "nextail-domain",  # will be converted to MetadataValue.text
# #         "repository": MetadataValue.url("https://github.com/nextail/dagster-template/"),
# #         "procedures": MetadataValue.url(
# #             "https://engineering-portal.nextail.co/docs/platform-architecture/for_developers/orchestration/dagster/"
# #         ),
# #     },
# #     tags={
# #         "dagster-k8s/config": {
# #             "pod_template_spec_metadata": {
# #                 "labels": {"client": "client-name", "module": "module-name", "operation": "module-operation"}
# #             },
# #         },
# #         "owner": "nextail-squad",
# #         "tenant": "nextail-tenant",
# #         "domain": "nextail-domain",
# #         "version": "v0.0.1",
# #     },
# #     description="""
# #     A job definition. This example job has a single op.

# #     For more hints on writing Dagster jobs, see our documentation overview on Jobs:
# #     https://docs.dagster.io/concepts/ops-jobs-graphs/jobs-graphs
# #     """,
# # )
# # def say_hello_job():
# #     hello()


# from pathlib import Path

# from dagster import AssetExecutionContext, Definitions

# from dagster_dbt import (
#     DbtCliResource,
#     DbtProject,
#     build_schedule_from_dbt_selection,
#     dbt_assets,
# )


# # RELATIVE_PATH_TO_MY_DBT_PROJECT = "./my_dbt_project"
# RELATIVE_PATH_TO_MY_DBT_PROJECT = "./../../dbt_project"

# dbt_project = DbtProject(
#     project_dir=Path(__file__)
#     .joinpath("..", RELATIVE_PATH_TO_MY_DBT_PROJECT)
#     .resolve(),
# )
# dbt_project.prepare_if_dev()

# @dbt_assets(manifest=dbt_project.manifest_path)
# def my_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
#     for asset_key in dbt.cli(["build"], context=context).stream():
#         print(asset_key)  # Print the asset keys
#         yield asset_key


# daily_dbt_assets_schedule = build_schedule_from_dbt_selection(
#     [my_dbt_assets],
#     job_name="my_dbt_assets",
#     cron_schedule="*/5 * * * *",
#     dbt_select="fqn:*",
# )


# # dbt_schedule = build_schedule_from_dbt_selection(
# #     [my_dbt_assets],
# #     job_name="materialize_dbt_models",
# #     cron_schedule="*/5 * * * *",
# #     dbt_select="fqn:*",
# # )



# # defs = Definitions(
# #     assets=[my_dbt_assets],
# #     schedules=[dbt_schedule],
# #     resources={
# #         "dbt": DbtCliResource(project_dir=my_project),
# #     },
# # )


