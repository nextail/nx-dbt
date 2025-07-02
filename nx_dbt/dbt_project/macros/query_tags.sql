{% macro set_query_tag() -%}
    {% do return(dbt_snowflake_query_tags.set_query_tag(
        extra={

            'service': 'data_platform',
            'module': 'internal_reporting',
            'submodule': 'dbt_execution',
            'operation': ' '.join(invocation_args_dict['invocation_command'].split()[:2]) if invocation_args_dict['invocation_command'] else None,
            'tenant': var('tenant', 'default_tenant'),
            'environment': env_var('NX_ENVIRONMENT', 'development'),
            'correlation_id': None,
            'execution_id': None,

            'dbt_specific': {
                'invocation_id': invocation_id,
                'model_database': model.database,
                'model_schema': model.schema,
                'model_name': model.name,
                'model_original_file_path': model.original_file_path,
                'model_alias': model.alias,
                'model_config': model.config,
                
                'model_tags': model.tags or None,

                'model_created_at': model.created_at or None,
            }            
        }
    )) %}
{% endmacro %}

{% macro unset_query_tag(original_query_tag) -%}
    {% do return(dbt_snowflake_query_tags.unset_query_tag(original_query_tag)) %}
{% endmacro %}