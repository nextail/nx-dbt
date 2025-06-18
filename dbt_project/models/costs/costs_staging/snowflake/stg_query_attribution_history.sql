{{
    config(
        materialized='incremental',
        unique_key=['query_id'],

        post_hook="alter table {{ this }} set change_tracking = true",

    )
}}

with
    source as (
        select
            *,
            -- for the old tags, extract the tenant value
            -- old queries have a structure like "app=mso-app;env=production;tenant=forevernew"
            SPLIT_PART(SPLIT_PART(query_tag, 'tenant=', 2), ';', 1) as tenant,
            SPLIT_PART(SPLIT_PART(query_tag, 'operation=', 2), ';', 1) as operation,
            split(warehouse_name, '_')[0] as tenant_wh_name,
            -- Ok, this is dirty.
            -- There are some services that are not going to be updated to the new tag format.
            -- This is a workaround: we are setting the tag according to the warehouse name.
            -- Yes, this is a workaround. Yes, this is dirty. Don't do this at home.
            -- In case the query_tag is a json, we don't want to override it; we only want to override it if it's a string.
            -- Thus, this should maintain the new json tags while it should override the old ones. Win-win.
            case
                when warehouse_name = 'ALLTENANTS_FIRSTALLOCATION_MSOAPPJOBS_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "first-allocation", "module": "first-allocation", "submodule": "msoapp-jobs", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name = 'ALLTENANTS_FIRSTALLOCATION_MSOAPPJOBS_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "first-allocation", "module": "first-allocation", "submodule": "msoapp-jobs", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name = 'ALLTENANTS_STORETRANSFERS_MSOAPPJOBS_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "storetransfers", "module": "storetransfers", "submodule": "msoapp-jobs", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name = 'ALLTENANTS_STORETRANSFERS_MSOAPPJOBS_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "storetransfers", "module": "storetransfers", "submodule": "msoapp-jobs", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name = 'ALLTENANTS_STORETRANSFERS_DATAPIPELINES_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "storetransfers", "module": "storetransfers", "submodule": "data-pipelines", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name = 'ALLTENANTS_STORETRANSFERS_DATAPIPELINES_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "storetransfers", "module": "storetransfers", "submodule": "data-pipelines", "environment": "sandbox", "hardcoded": "true"}')
                

                when warehouse_name = 'ALLTENANTS_GLOBALDOMAIN_MSOAPPMOBILE_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "app", "module": "backend", "submodule": "msoapp", "operation": "mobile", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name = 'ALLTENANTS_REPLENISHMENTS_MSOAPPJOBS_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "replenishments", "module": "replenishments", "submodule": "msoapp-jobs", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name = 'ALLTENANTS_REPLENISHMENTS_MSOAPPJOBS_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "replenishments", "module": "replenishments", "submodule": "msoapp-jobs", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name = 'ALLTENANTS_GLOBALDOMAIN_MSOAPPWEB_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "app", "module": "backend", "submodule": "msoapp", "operation": "desktop", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name = 'ALLTENANTS_GLOBALDOMAIN_MSOAPPWEB_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "app", "module": "backend", "submodule": "msoapp", "operation": "desktop", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name = 'ALLTENANTS_GLOBALDOMAIN_MSOAPPEVENTLISTENER_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "monitoring", "module": "kafka-listener", "submodule": "msoapp-events-listener", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name = 'ALLTENANTS_GLOBALDOMAIN_MSOAPPEVENTLISTENER_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "monitoring", "module": "kafka-listener", "submodule": "msoapp-events-listener", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name = 'ALLTENANTS_ADVANCEDANALYTICS_DIPAPAPI_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "advanced-analytics", "module": "dipap-api", "submodule": "desktop", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name = 'ALLTENANTS_ADVANCEDANALYTICS_DIPAPAPIMOBILE_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "advanced-analytics", "module": "dipap-api", "submodule": "mobile", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                
                when warehouse_name = 'ALLTENANTS_FIRSTALLOCATION_DATAPIPELINES_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "first-allocation", "module": "first-allocation", "submodule": "data-pipelines", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name = 'ALLTENANTS_FIRSTALLOCATION_DATAPIPELINES_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "first-allocation", "module": "first-allocation", "submodule": "data-pipelines", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name = 'BASE_ANYAPP_CICD_TEST_WH' and try_parse_json(query_tag) is null then concat('{"service": "internal", "module": "testing", "submodule": "cicd", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name = 'ALLTENANTS_REPLENISHMENTS_DATAPIPELINES_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "replenishments", "module": "replenishments", "submodule": "data-pipelines", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name = 'ALLTENANTS_REPLENISHMENTS_DATAPIPELINES_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "replenishments", "module": "replenishments", "submodule": "data-pipelines", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name = 'ALLTENANTS_MASTERS_DATASERVICES_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-services", "module": "data-api", "submodule": "masters", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name = 'ALLTENANTS_MASTERS_DATASERVICES_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-services", "module": "data-api", "submodule": "masters", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name ilike '%GLOBALDOMAIN_TEXTILSFMIGRATION_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "textil", "module": "textil", "submodule": "textil", "operation": "', operation, '", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name ilike '%GLOBALDOMAIN_TEXTILSFMIGRATION_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "textil", "module": "textil", "submodule": "textil", "operation": "', operation, '", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name ilike '%_REPLENISHMENTS_TEXTILMAIN_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "replenishments", "module": "replenishments", "submodule": "textil", "operation": "', operation, '", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name ilike '%_REPLENISHMENTS_TEXTILMAIN_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "replenishments", "module": "replenishments", "submodule": "textil", "operation": "', operation, '", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name ilike '%_FIRSTALLOCATION_TEXTILMAIN_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "first-allocation", "module": "first-allocation", "submodule": "textil", "operation": "', operation, '", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name ilike '%_FIRSTALLOCATION_TEXTILMAIN_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "first-allocation", "module": "first-allocation", "submodule": "textil", "operation": "', operation, '", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name ilike '%_STORETRANSFERS_TEXTILMAIN_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "storetransfers", "module": "storetransfers", "submodule": "textil", "operation": "', operation, '", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name ilike '%_STORETRANSFERS_TEXTILMAIN_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "storetransfers", "module": "storetransfers", "submodule": "textil", "operation": "', operation, '", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name ilike '%_ADVANCEDANALYTICS_BITABLESREFRESH_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "advanced-analytics", "module": "bi", "submodule": "internal_tables_refresh", "environment": "prod", "tenant": "', tenant_wh_name, '", "hardcoded": "true"}')
                when warehouse_name ilike '%_ADVANCEDANALYTICS_BITABLESREFRESH_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "advanced-analytics", "module": "bi", "submodule": "internal_tables_refresh", "environment": "sandbox", "tenant": "', tenant_wh_name, '", "hardcoded": "true"}')

                when warehouse_name ilike '%_INTEGRATIONS_MAIN_OPERATOR_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-integration", "module": "integrations", "submodule": "dio-daily", "operation": "old_integration", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name ilike '%_INTEGRATIONS_MAIN_OPERATOR_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-integration", "module": "integrations", "submodule": "dio-daily", "operation": "old_integration", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name ilike '%_INSIGHTS_WORKLOAD_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "advanced-analytics", "module": "insights", "submodule": "workload", "environment": "prod", "tenant": "', tenant_wh_name, '", "hardcoded": "true"}')
                when warehouse_name ilike '%_INSIGHTS_WORKLOAD_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "advanced-analytics", "module": "insights", "submodule": "workload", "environment": "sandbox", "tenant": "', tenant_wh_name, '", "hardcoded": "true"}')

                when warehouse_name ilike '%_INTEGRATIONS_DATATRANSFORMATION_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-integration", "module": "integrations", "submodule": "dio-daily", "operation": "data-transformation", "environment": "prod", "tenant": "', tenant_wh_name, '", "hardcoded": "true"}')
                when warehouse_name ilike '%_INTEGRATIONS_DATATRANSFORMATION_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-integration", "module": "integrations", "submodule": "dio-daily", "operation": "data-transformation", "environment": "sandbox", "tenant": "', tenant_wh_name, '", "hardcoded": "true"}')

                when warehouse_name ilike '%_INTEGRATIONS_DATAINGESTION_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-integration", "module": "integrations", "submodule": "dio-daily", "operation": "data-ingestion", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name ilike '%_INTEGRATIONS_DATAINGESTION_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-integration", "module": "integrations", "submodule": "dio-daily", "operation": "data-ingestion", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name ilike '%_GLOBALDOMAIN_PYLARMS_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "monitoring", "module": "backend", "submodule": "pylarms", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name ilike '%_GLOBALDOMAIN_PYLARMS_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "monitoring", "module": "backend", "submodule": "pylarms", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')

                when warehouse_name ilike 'ALLTENANTS_SIZECURVES_MAIN_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "forecast", "module": "size-curves", "submodule": "size-curves", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike 'ALLTENANTS_SIZECURVES_MAIN_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "forecast", "module": "size-curves", "submodule": "size-curves", "environment": "sandbox", "hardcoded": "true"}')

                when warehouse_name ilike 'ALLTENANTS_GLOBALDOMAIN_DATALLSERVICES_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-services", "module": "data-api", "submodule": "globaldomain", "environment": "prod", "tenant": "', tenant_wh_name, '", "hardcoded": "true"}')
                when warehouse_name ilike 'ALLTENANTS_GLOBALDOMAIN_DATALLSERVICES_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-services", "module": "data-api", "submodule": "globaldomain", "environment": "sandbox", "tenant": "', tenant_wh_name, '", "hardcoded": "true"}')

                when warehouse_name ilike 'ALLTENANTS_FORECAST_XSMALL_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "forecast", "module": "not_tagged", "submodule": "xsmall", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike 'ALLTENANTS_FORECAST_XSMALL_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "forecast", "module": "not_tagged", "submodule": "xsmall", "environment": "sandbox", "hardcoded": "true"}')

                when warehouse_name ilike 'ALLTENANTS_FORECAST_MEDIUM_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "forecast", "module": "not_tagged", "submodule": "medium", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike 'ALLTENANTS_FORECAST_MEDIUM_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "forecast", "module": "not_tagged", "submodule": "medium", "environment": "sandbox", "hardcoded": "true"}')
                
                when warehouse_name ilike 'ALLTENANTS_INSIGHTS_DATASERVICES_PROD_WH' and try_parse_json(query_tag) is null then concat('{"service": "advanced-analytics", "module": "data-api", "submodule": "data-api", "environment": "prod", "tenant": "', tenant, '", "hardcoded": "true"}')
                when warehouse_name ilike 'ALLTENANTS_INSIGHTS_DATASERVICES_SANDBOX_WH' and try_parse_json(query_tag) is null then concat('{"service": "advanced-analytics", "module": "data-api", "submodule": "data-api", "environment": "sandbox", "tenant": "', tenant, '", "hardcoded": "true"}')
                
                -- dev warehouses for the different teams
                when warehouse_name ilike '%_TESELA_%_DEV_WH' and try_parse_json(query_tag) is null then concat('{"service": "internal", "module": "dev", "submodule": "tesela", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike '%_INTEGRATIONS_%_DEV_WH' and try_parse_json(query_tag) is null then concat('{"service": "internal", "module": "dev", "submodule": "integrations", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike '%_FRONTEND_%_DEV_WH' and try_parse_json(query_tag) is null then concat('{"service": "internal", "module": "dev", "submodule": "frontend", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike '%_STAFF_%_DEV_WH' and try_parse_json(query_tag) is null then concat('{"service": "internal", "module": "dev", "submodule": "staff", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike '%_BI_%_DEV_WH' and try_parse_json(query_tag) is null then concat('{"service": "internal", "module": "dev", "submodule": "bi", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike '%_OPTIMUS_%_DEV_WH' and try_parse_json(query_tag) is null then concat('{"service": "internal", "module": "dev", "submodule": "optimus", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike '%_DATAPLATFORM_%_DEV_WH' and try_parse_json(query_tag) is null then concat('{"service": "internal", "module": "dev", "submodule": "dataplatform", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike '%_CUSTOMEREXPERIENCE_%_DEV_WH' and try_parse_json(query_tag) is null then concat('{"service": "internal", "module": "dev", "submodule": "customerexperience", "environment": "prod", "hardcoded": "true"}')
                when warehouse_name ilike '%_DATAOPS_%_DEV_WH' and try_parse_json(query_tag) is null then concat('{"service": "internal", "module": "dev", "submodule": "dataops", "environment": "prod", "hardcoded": "true"}')

                when warehouse_name ilike 'COMPUTE_WH' and try_parse_json(query_tag) is null then concat('{"service": "data-platform", "module": "dev", "submodule": "dev_tasks", "operation": "compute_wh_usage", "hardcoded": "true"}')

                else query_tag
            end as cleaned_query_tag,

        from {{ source('snowflake', 'query_attribution_history') }}
    )

select
    -- remove temp columns that we used to clean the query_tag
    * exclude (tenant, operation, query_tag, tenant_wh_name),
    cleaned_query_tag as query_tag
from source
-- configure the incremental model.
-- If it's a regular execution, we only want to pull the data that has been updated since the last run.
-- If it's a full refresh, we want to pull all the data from a certain date.

{% if is_incremental() %}
    where start_time > (select max(start_time) from {{ this }})
{% endif %}
{% if should_full_refresh() %}
    where start_time >= '2025-01-01'
{% endif %}