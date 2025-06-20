#!/usr/bin/env python3

import yaml
from typing import List, Dict, Any

# Define the source configuration structure
SOURCE_CONFIG = {
    "schemas": {
        "globaldomain_public": {
            "description": "Raw data sources from our data warehouse",
            "tables": {
                "first_allocation_execution": {
                    "description": "first allocation execution"
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
        yaml.dump(yaml_content, f, sort_keys=False, default_flow_style=False)

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
    # Example usage with the default configuration
    databases = [
        "aristocrazy",
        "suarez",
        "flyingtiger",
        "riverisland"
    ]
    
    # Example of how to modify the configuration
    # Create a new configuration
    new_config = {"schemas": {}}
    
    # Add a new schema
    add_schema(
        new_config,
        "globaldomain_public",
        "Raw data sources from our data warehouse",
        {
            "first_allocation_execution": {
                "description": "first allocation execution"
            }
        }
    )
    
    # Add another table to the schema
    add_table(
        new_config,
        "globaldomain_public",
        "another_table",
        "Another table description"
    )
    
    output_path = "models/internal/first_allocation/__sources.yml"
    generate_source_yaml(databases, new_config, output_path)
    print(f"Generated source YAML file at: {output_path}") 