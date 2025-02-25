{% macro set_query_tag() -%}
    {% do return(dbt_snowflake_query_tags.set_query_tag(
        extra={

            'service': 'data_platform',
            'module': 'internal_reporting',
            'submodule': 'dbt_execution',
            'operation': None,
            'tenant': var('tenant', 'default_tenant'),
            'environment': 'sandbox',
            'correlation_id': None,
            'execution_id': None,

            'dbt_specific': {
                'invocation_id': invocation_id,
                'model_database': model.database,
                'model_schema': model.schema,
                'model_name': model.name,
                'model_resource_type': model.resource_type,
                'model_package_name': model.package_name,
                'model_path': model.path,
                'model_original_file_path': model.original_file_path,
                'model_unique_id': model.unique_id,
                'model_fqn': model.fqn,
                'model_alias': model.alias,
                'model_checksum': model.checksum,
                'model_config': model.config,
                
                'model_tags': model.tags or None,
                'model_description': model.description or None,
                'model_columns': model.columns or None,
                'model_meta': model.meta or None,
                'model_group': model.group or None,
                
                
                
                'model_docs': model.docs or None,
                'model_patch_path': model.patch_path or None,
                'model_build_path': model.build_path or None,

                'model_created_at': model.created_at or None,
                'model_root_path': model.root_path or None
            }            
        }
    )) %}
{% endmacro %}

{% macro unset_query_tag(original_query_tag) -%}
    {% do return(dbt_snowflake_query_tags.unset_query_tag(original_query_tag)) %}
{% endmacro %}