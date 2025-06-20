{{ config
    (
        materialized="dynamic_table",
        on_configuration_change="apply",
        target_lag='2 hours',
        snowflake_warehouse="COMPUTE_WH",
        refresh_mode="INCREMENTAL",
        initialize="ON_CREATE",

        unique_key=["tenant", "prod_reference", "month"],
        cluster_by=["tenant"],
        enabled=false
    )
}}

WITH selected_date AS (
    SELECT max(date) as end_date
    FROM {{ ref('sales') }}
),

relevant_products AS (
    SELECT DISTINCT 
        sl.tenant,
        sk.product_id
    FROM {{ ref('sales') }} sl 
    JOIN {{ ref('skus') }} sk ON sk.id = sl.sku_id AND sk.tenant = sl.tenant
),

monthly_sales_data AS (
    SELECT 
        sl.tenant,
        sk.product_id as prod, 
        month(sl.date) as month, 
        sum(sl.quantity) as monthly_sales, 
        round(avg(sum(sl.quantity)) OVER (PARTITION BY sl.tenant, sk.product_id), 1) as avg_monthly_sales
    FROM {{ ref('sales') }} sl
    JOIN {{ ref('skus') }} sk ON sk.id = sl.sku_id AND sk.tenant = sl.tenant
    JOIN selected_date sd ON 1 = 1
    JOIN relevant_products rp ON rp.tenant = sl.tenant AND rp.product_id = sk.product_id
    WHERE sl.date BETWEEN dateadd(YEAR, -1, sd.end_date) AND sd.end_date
    GROUP BY sl.tenant, prod, month
),

product_sales_summary AS (
    SELECT 
        msd.tenant,
        msd.prod,
        pr.ref as prod_reference,
        pr.name as prod_name,
        fm.name as family,
        ss.name as season,
        count(msd.month) as count_month_with_sales,
        sum(CASE WHEN msd.monthly_sales >= msd.avg_monthly_sales THEN 1 END) as count_month_sales_more_than_avg,
        sum(msd.monthly_sales) as total_sales,
        msd.avg_monthly_sales
    FROM monthly_sales_data msd
    JOIN {{ ref('products') }} pr ON pr.id = msd.prod AND pr.tenant = msd.tenant
    JOIN {{ ref('seasons') }} ss ON ss.id = pr.season_id AND ss.tenant = msd.tenant
    JOIN {{ ref('families') }} fm ON fm.id = pr.family_id AND fm.tenant = msd.tenant
    GROUP BY msd.tenant, msd.prod, prod_reference, prod_name, family, season, msd.avg_monthly_sales
)

SELECT 
    tenant,
    prod_reference,
    prod_name,
    family,
    season,
    count_month_with_sales,
    count_month_sales_more_than_avg,
    total_sales,
    avg_monthly_sales
FROM product_sales_summary