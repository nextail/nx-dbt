-- this notebook is used to check the data quality of the costs initiative data,
-- including both k8s and snowflake costs.
-- it mainly focuses on ensuring the dbt incremental models are working as expected.

-- check that the k8s_completed_jobs table is complete
with 
    raw_k8s_completed_jobs_prod as (
        select
            start_time_utc::DATE as start_date,
            count(*) as completed_jobs,
            count(distinct pod) as no_distinct_pod_id,
            'PROD' as k8s_environment
        from ALLTENANTS_COSTMONITOR_ALLENVS_DB.K8S_PRIVATE.COMPLETED_JOBS_PROD
        group by start_date
        order by start_date
    ),
    raw_k8s_completed_jobs_sandbox as (
        select
            start_time_utc::DATE as start_date,
            count(*) as completed_jobs,
            count(distinct pod) as no_distinct_pod_id,
            'SANDBOX' as k8s_environment
        from ALLTENANTS_COSTMONITOR_ALLENVS_DB.K8S_PRIVATE.COMPLETED_JOBS_SANDBOX
        group by start_date
        order by start_date
    ),
    all_dates as (
        select
            distinct start_date,
            k8s_environment
        from raw_k8s_completed_jobs_prod
        union
        select
            distinct start_date,
            k8s_environment
        from raw_k8s_completed_jobs_sandbox
    ),
    stg_k8s_completed_jobs as (
        select
            start_date,
            k8s_environment,
            count(*) as completed_jobs_from_all,
            count(distinct pod_id) as no_distinct_pod_id_from_all
        from NEXTAIL_INTERNALS_SANDBOX_DB.DBT_NX_BRONZE.STG_K8S_COMPLETED_JOBS_ALL
        group by start_date, k8s_environment
    ),
    final as (
        select
            ad.start_date,
            ad.k8s_environment,
            case when k8s_environment = 'PROD' then rkcp.completed_jobs else rkcs.completed_jobs end as completed_jobs,
            case when k8s_environment = 'PROD' then rkcp.no_distinct_pod_id else rkcs.no_distinct_pod_id end as no_distinct_pod_id,
            completed_jobs_from_all,
            no_distinct_pod_id_from_all
        from all_dates ad
        left join raw_k8s_completed_jobs_prod rkcp
            using (start_date, k8s_environment)
        left join raw_k8s_completed_jobs_sandbox rkcs
            using (start_date, k8s_environment)
        left join stg_k8s_completed_jobs skcj
            using (start_date, k8s_environment)
        where ad.start_date >= '2025-02-01'
        order by start_date, k8s_environment
    )
select *
from final
where completed_jobs <> completed_jobs_from_all
    or no_distinct_pod_id <> no_distinct_pod_id_from_all
;

select * from alltenants_costmonitor_allenvs_db.k8s_private.completed_jobs_sandbox
where start_time_utc::DATE = '2025-03-06'
    and pod not in (select pod_id from nextail_internals_sandbox_db.dbt_nx_bronze.stg_k8s_completed_jobs_all
                    where start_date = '2025-03-06'
                        and k8s_environment = 'SANDBOX')
;

select * from nextail_internals_sandbox_db.dbt_nx_bronze.stg_k8s_completed_jobs_all
where start_date = '2025-03-06'
    and k8s_environment = 'SANDBOX'
;


select * from nextail_internals_sandbox_db.dbt_nx_bronze.stg_query_attribution_history
where query_id not in (select query_id from snowflake.account_usage.query_attribution_history where start_time >= '2025-03-01')
 and start_time >= '2025-03-01'
;
