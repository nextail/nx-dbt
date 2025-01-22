with
    base as (
        select 
            query_id,
            start_time,
            end_time,
            datediff('milliseconds', start_time, end_time) as total_elapsed_time,
            lag(start_time, -1) over (order by start_time) as next_start_time,
            timediff('seconds', end_time, next_start_time) as tdiff,
            case when next_start_time > timeadd('seconds', 60, end_time) then TRUE else FALSE end as adds_idle_wh,
            case when adds_idle_wh then 1/60 else 0 end as extra_idle_cost,    
            -- lag(end_time, 1) over (order by start_time) as previous_end_time,
            -- timeadd('seconds', 60, previous_end_time) as previous_end_time_plus_60s,
            -- case when start_time > previous_end_time_plus_60s then true else false end as initialises_wh,
            credits_attributed_compute,
            user_name,
            parent_query_id,
            root_query_id,
            query_hash,
            query_parameterized_hash,
            lower(replace(query_tag, ',', ';')) as query_tag_aux,
            warehouse_name,
            
            SPLIT_PART(SPLIT_PART(replace(query_tag_aux, ',', ';'), 'app=', 2), ';', 1) AS app,
            SPLIT_PART(SPLIT_PART(replace(query_tag_aux, ',', ';'), 'tenant=', 2), ';', 1) AS tenant,
            SPLIT_PART(SPLIT_PART(replace(query_tag_aux, ',', ';'), 'env=', 2), ';', 1) AS env,
            SPLIT_PART(SPLIT_PART(replace(query_tag_aux, ',', ';'), 'func=', 2), ';', 1) AS func,
            SPLIT_PART(SPLIT_PART(replace(query_tag_aux, ',', ';'), 'execution_id=', 2), ';', 1) AS execution_id,
            SPLIT_PART(SPLIT_PART(replace(query_tag_aux, ',', ';'), 'correlation_id=', 2), ';', 1) AS correlation_id,
        from {{ ref('stg_query_attribution_history')}}
        -- where
            -- warehouse_name = 'ALLTENANTS_TESELA_MEDIUM_DEV_WH'
        -- where USER_NAME = 'NX_PABLOESPESO_USER'
        -- start_time::DATE >= '2025-01-18'
        order by start_time    
    ),
    agg_attributed_compute as (
        select
            start_time::DATE as dt,
            app,
            tenant,
            env,
            func,
            execution_id,
            correlation_id,
            sum(extra_idle_cost) + sum(credits_attributed_compute) as credits_compute,
        from base
        group by dt, app, tenant, env, func, execution_id, correlation_id
    ),
    cloud_credits_base as (
        select
            start_time::DATE as dt,
            -- warehouse_name,
            lower(replace(query_tag, ',', ';')) as query_tag_aux,
            credits_used_cloud_services,
        from {{ ref('stg_query_history') }}
        -- where start_time >= '2025-01-18'
        -- group by dt, app, tenant, env, func    
    ),
    cloud_credits_agg as (
        select
            dt,
            -- warehouse_name, 
            SPLIT_PART(SPLIT_PART(query_tag_aux, 'app=', 2), ';', 1) AS app,
            SPLIT_PART(SPLIT_PART(query_tag_aux, 'tenant=', 2), ';', 1) AS tenant,
            SPLIT_PART(SPLIT_PART(query_tag_aux, 'env=', 2), ';', 1) AS env,
            SPLIT_PART(SPLIT_PART(query_tag_aux, 'func=', 2), ';', 1) AS func,
            SPLIT_PART(SPLIT_PART(query_tag_aux, 'execution_id=', 2), ';', 1) AS execution_id,
            SPLIT_PART(SPLIT_PART(query_tag_aux, 'correlation_id=', 2), ';', 1) AS correlation_id,
            sum(CREDITS_USED_CLOUD_SERVICES) as sum_credits_cloud_services
        from cloud_credits_base
        -- where start_time >= '2025-01-01'
        group by dt, app, tenant, env, func, execution_id, correlation_id  
    )

select
    dt,
    app,
    tenant,
    env,
    func,
    execution_id,
    correlation_id,    
    credits_compute + sum_credits_cloud_services as total_credits
from agg_attributed_compute
left join cloud_credits_agg
    using (dt, app, tenant, env, func, execution_id, correlation_id)
-- is incremental clause
order by total_credits desc
