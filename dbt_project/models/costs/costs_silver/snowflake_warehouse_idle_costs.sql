{{
    config(
        materialized='incremental',
        unique_key=['warehouse_name', 'query_date'],
        incremental_strategy='merge',
        enabled=false,
        cluster_by=['query_date', 'warehouse_name']
    )
}}

WITH
-- Get all query execution records
query_executions AS (
    SELECT 
        WAREHOUSE_NAME,
        START_TIME,
        END_TIME,
        TOTAL_ELAPSED_TIME,
        START_TIME::DATE as query_date
    FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
    {% if should_full_refresh() %}
        where START_TIME >= '2025-04-10'
    {% endif %}
    {% if is_incremental() %}
        -- Only get new data since the last run
        WHERE START_TIME::DATE > (select max(query_date) from {{ this }})
    {% endif %}
),

-- Get initial "turned off" state for all warehouses
initial_states AS (
    SELECT 
        WAREHOUSE_NAME,
        query_date,
        query_date as time_point,
        'turn_off' AS state_change
    FROM (SELECT DISTINCT WAREHOUSE_NAME, query_date FROM query_executions)
),

-- Get query start points (warehouse starts running)
start_running_states AS (
    SELECT 
        WAREHOUSE_NAME,
        query_date,
        START_TIME AS time_point,
        'start_running' AS state_change
    FROM query_executions
),

-- Get query end points (warehouse becomes idle)
start_idle_states AS (
    SELECT 
        WAREHOUSE_NAME,
        query_date,
        END_TIME AS time_point,
        'start_idle' AS state_change
    FROM query_executions
),

-- Get idle end points (warehouse turns off)
turn_off_states AS (
    SELECT 
        WAREHOUSE_NAME,
        query_date,
        DATEADD(seconds, 60, END_TIME) AS time_point,
        'turn_off' AS state_change
    FROM query_executions
),

-- Combine all state changes
state_changes AS (
    SELECT * FROM initial_states
    UNION ALL
    SELECT * FROM start_running_states
    UNION ALL
    SELECT * FROM start_idle_states
    UNION ALL
    SELECT * FROM turn_off_states
),

-- Calculate time spent in each state
state_durations AS (
    SELECT 
        WAREHOUSE_NAME,
        query_date,
        time_point,
        state_change,
        LEAST(
            LEAD(time_point) OVER (
                PARTITION BY WAREHOUSE_NAME, query_date
                ORDER BY time_point
            ),
            DATEADD(day, 1, query_date)
        ) AS next_time_point
    FROM state_changes
),

-- Calculate final metrics with safeguards against negative time periods
final_metrics as (
    SELECT 
        WAREHOUSE_NAME,
        query_date,
        SUM(CASE 
            WHEN state_change = 'start_running' 
            AND DATEDIFF(seconds, time_point, COALESCE(next_time_point, DATEADD(day, 1, query_date))) > 0
            THEN DATEDIFF(seconds, time_point, COALESCE(next_time_point, DATEADD(day, 1, query_date)))
            ELSE 0 
        END) AS running_seconds,
        SUM(CASE 
            WHEN state_change = 'start_idle' 
            AND DATEDIFF(seconds, time_point, COALESCE(next_time_point, DATEADD(day, 1, query_date))) > 0
            THEN DATEDIFF(seconds, time_point, COALESCE(next_time_point, DATEADD(day, 1, query_date)))
            ELSE 0 
        END) AS idle_seconds,
        running_seconds + idle_seconds as turned_on_seconds,
        SUM(CASE 
            WHEN state_change = 'turn_off' 
            AND DATEDIFF(seconds, time_point, COALESCE(next_time_point, DATEADD(day, 1, query_date))) > 0
            THEN DATEDIFF(seconds, time_point, COALESCE(next_time_point, DATEADD(day, 1, query_date)))
            ELSE 0 
        END) AS turned_off_seconds,
        (running_seconds + idle_seconds + turned_off_seconds) / 60.0 / 60.0 as total_time_hours,
        CASE 
            WHEN turned_on_seconds > 0 
            THEN running_seconds / turned_on_seconds * 100 
            ELSE 0 
        END as running_ratio
    FROM state_durations
    GROUP BY WAREHOUSE_NAME, query_date
    ORDER BY WAREHOUSE_NAME, query_date
)

select * from final_metrics