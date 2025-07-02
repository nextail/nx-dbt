# 🥪 Nextail's Costs dbt Project

This project is based on the [dbt Labs' Jaffle Shop](https://github.com/dbt-labs/jaffle-shop) that serves as a template for creating a custom dbt project. You may find certain configurations that are related to this Jaffle Shop, but should not be required when running this project at Nextail.

This project started as a sandbox project for exploring how to create a simple ELT pipeline to ingest costs-related information at Nextail, and show the results in a dashboard. For further details, please refer to the [📚 README.md](https://github.com/nextail/nx-dbt/blob/sandbox/docs/README.md) file.

## Current versions

(Depicted in the `pyproject.toml` file)

- dbt-core: 1.9.8
- dbt-snowflake: 1.9.4

Package versions are included in the `packages.yml` file.

## Key files and folders

- `dbt_project/`, root of the dbt project.
- `dbt_project/models/`, folder containing the dbt models and dbt tests.
- `dbt_project.yml`, dbt project configuration file.
- `packages.yml`, dbt packages configuration file.
- `profiles.yml`, dbt profiles configuration file.
- `macros/query_tags.sql`, macro for setting the Snowflake query tags.

## Key dbt commands

- `dbt run`, run the dbt models.
- `dbt test`, run the dbt tests.
- `dbt build`, run the dbt models and tests.
- `dbt docs generate`, generate the dbt documentation (not set up at this moment).
- `dbt debug`, debug the dbt connection is properly set up.
- `dbt deps`, install the dbt packages (should not be needed since they are included in the `dbt_packages` folder).

## Recommended documentation

- [dbt Docs](https://docs.getdbt.com/docs/introduction)
- [dbt Labs' Jaffle Shop](https://github.com/dbt-labs/jaffle-shop)
- [dbt models](https://docs.getdbt.com/docs/build/models)
- [dbt tests](https://docs.getdbt.com/docs/build/tests)
- [dbt documentation](https://docs.getdbt.com/docs/build/documentation)
- [Snowflake's Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-about)
- [Snowflake's Query Attribution History View](https://docs.snowflake.com/en/sql-reference/account-usage/query_attribution_history)
