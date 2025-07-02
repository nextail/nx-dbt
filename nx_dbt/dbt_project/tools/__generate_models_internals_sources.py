#!/usr/bin/env python3

"""
This script generates dbt source YAML files for internal models by reading configuration from a predefined structure.
It's designed to automate the creation of source definitions for multiple databases and schemas, making it easier
to maintain and update dbt source configurations across different environments. The script reads tenant information
from dbt_project.yml and generates corresponding source definitions for each tenant's database.

The script uses a predefined SOURCE_CONFIG structure that defines schemas and their tables, along with descriptions.
For each tenant in dbt_project.yml, it generates a source definition that includes:
- A unique source name combining tenant and schema
- Database and schema information
- Table definitions with descriptions

The generated YAML file is saved to models/internal/__sources.yml and follows dbt's source specification format.

To modify the source configuration, edit the SOURCE_CONFIG dictionary directly. Future versions will use an external json file.

It must be executed manually from the root of the dbt project.

Execute this script by running:
python3 tools/__generate_models_internals_sources.py
"""

import yaml
from typing import List, Dict, Any

class IndentDumper(yaml.SafeDumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(IndentDumper, self).increase_indent(flow, False)

# Define the source configuration structure
SOURCE_CONFIG = {
    "schemas": {
        "globaldomain_public": {
            "description": "Raw data sources from our data warehouse",
            "tables": {
                "first_allocation_execution": {
                    "description": "first allocation execution"
                },
                "category": {
                    "description": "category table"
                },
                "category_item_included": {
                    "description": "category item included table"
                },
                "products": {
                    "description": "products table"
                },
                "product_history": {
                    "description": "product history table"
                },
                "stores": {
                    "description": "stores table"
                },
                "families": {
                    "description": "families table"
                },
                "cron": {
                    "description": "cron table"
                },
                "buy_execution": {
                    "description": "buy execution table"
                },
                "dio_execution_selected": {
                    "description": "dio execution selected table"
                },
                "engine_executions": {
                    "description": "engine executions table"
                },
                "first_allocation_execution": {
                    "description": "first allocation execution table"
                },
                "preconfigured_execution": {
                    "description": "preconfigured execution table"
                },
                "reorder_execution": {
                    "description": "reorder execution table"
                },
                "replenishment_executions": {
                    "description": "replenishment executions table"
                },
                "store_transfers_executions": {
                    "description": "store transfers executions table"
                },
                "store_transfers_execution_aggregates": {
                    "description": "store transfers execution aggregates table"
                },
                "store_stock_items": {
                    "description": "store stock items table"
                },
                "scenario": {
                    "description": "scenarios table"
                },
                "warehouses": {
                    "description": "warehouses table"
                },
                "skus": {
                    "description": "skus table"
                },
                "seasons": {
                    "description": "seasons table"
                },
                "sales": {
                    "description": "sales table"
                },
                "warehouse_stock_items": {
                    "description": "warehouse stock items table"
                },
                "databasechangelog": {
                    "description": "liquibase database changelog table"
                }
            }
        }
    }
}

def generate_source_yaml(
    database_names: List[str],
    source_config: Dict[str, Any],
    output_file: str
) -> None:
    """
    Generate a dbt source YAML file based on a configuration structure.
    
    Args:
        database_names: List of database names to generate sources for
        source_config: Dictionary containing the source configuration structure
        output_file: Path to the output YAML file
    """
    sources = []
    
    for db_name in database_names:
        for schema_name, schema_config in source_config["schemas"].items():
            source = {
                "name": f"{db_name}_{schema_name}",
                "description": schema_config["description"],
                "database": f"{db_name}_main_prod_db",
                "schema": schema_name,
                "tables": [
                    {
                        "name": table_name,
                        "description": table_config["description"]
                    }
                    for table_name, table_config in schema_config["tables"].items()
                ]
            }
            sources.append(source)
    
    yaml_content = {
        "version": 2,
        "sources": sources
    }
    
    with open(output_file, 'w') as f:
        yaml.dump(yaml_content, f, sort_keys=False, default_flow_style=False, indent=2, Dumper=IndentDumper)

def add_schema(
    config: Dict[str, Any],
    schema_name: str,
    description: str,
    tables: Dict[str, Dict[str, str]]
) -> None:
    """
    Add a new schema configuration to the source config.
    
    Args:
        config: The source configuration dictionary
        schema_name: Name of the schema to add
        description: Description of the schema
        tables: Dictionary of table configurations
    """
    config["schemas"][schema_name] = {
        "description": description,
        "tables": tables
    }

def add_table(
    config: Dict[str, Any],
    schema_name: str,
    table_name: str,
    description: str
) -> None:
    """
    Add a new table to an existing schema configuration.
    
    Args:
        config: The source configuration dictionary
        schema_name: Name of the schema to add the table to
        table_name: Name of the table to add
        description: Description of the table
    """
    if schema_name not in config["schemas"]:
        raise ValueError(f"Schema {schema_name} does not exist in configuration")
    
    config["schemas"][schema_name]["tables"][table_name] = {
        "description": description
    }

if __name__ == "__main__":
    # Get the databases list from the dbt_project.yml file
    with open("dbt_project.yml", "r") as f:
        dbt_project = yaml.safe_load(f)
    databases = dbt_project["vars"]["all_tenants"]
    
    
    # Example of how to modify the configuration
    # Create a new configuration
    new_config = {"schemas": {}}
    
    # apply the source config to the new config
    for schema_name, schema_config in SOURCE_CONFIG["schemas"].items():
        add_schema(new_config, schema_name, schema_config["description"], schema_config["tables"])

    # add the tables to the new config
    for schema_name, schema_config in SOURCE_CONFIG["schemas"].items():
        for table_name, table_config in schema_config["tables"].items():
            add_table(new_config, schema_name, table_name, table_config["description"])
    
    output_path = "models/internal/__sources.yml"
    generate_source_yaml(databases, new_config, output_path)
    print(f"Generated source YAML file at: {output_path}")