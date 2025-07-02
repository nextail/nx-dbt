{{
    config(
        materialized='table',
        enabled=false
    )
}}
WITH selected_date AS (
    SELECT max(date) as end_date
    FROM GINATRICOT_MAIN_PROD_DB.GLOBALDOMAIN_PUBLIC.sales
    WHERE date >= '2025-04-01'
),

monthly_sales_data AS (
    SELECT 
        sk.product_id as prod, 
        month(sl.date) as month, 
        sum(sl.quantity) as monthly_sales, 
        round(avg(sum(sl.quantity)) OVER (PARTITION BY sk.product_id), 1) as avg_monthly_sales
    FROM GINATRICOT_MAIN_PROD_DB.GLOBALDOMAIN_PUBLIC.sales sl
    JOIN GINATRICOT_MAIN_PROD_DB.GLOBALDOMAIN_PUBLIC.skus sk ON sk.id = sl.sku_id
    JOIN selected_date sd ON 1 = 1
    WHERE date BETWEEN dateadd(YEAR, -1, sd.end_date) AND sd.end_date
    AND sk.product_id IN (
        SELECT DISTINCT sk.product_id 
        FROM GINATRICOT_MAIN_PROD_DB.GLOBALDOMAIN_PUBLIC.sales sl 
        JOIN GINATRICOT_MAIN_PROD_DB.GLOBALDOMAIN_PUBLIC.skus sk ON sk.id = sl.sku_id 
        WHERE date >= '2025-04-01'
    )
    GROUP BY prod, month
),

product_sales_summary AS (
    SELECT 
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
    JOIN GINATRICOT_MAIN_PROD_DB.GLOBALDOMAIN_PUBLIC.products pr ON pr.id = msd.prod
    JOIN GINATRICOT_MAIN_PROD_DB.GLOBALDOMAIN_PUBLIC.seasons ss ON ss.id = pr.season_id
    JOIN GINATRICOT_MAIN_PROD_DB.GLOBALDOMAIN_PUBLIC.families fm ON fm.id = pr.family_id
    GROUP BY msd.prod, prod_reference, prod_name, family, season, msd.avg_monthly_sales
)

SELECT 
    prod_reference,
    prod_name,
    family,
    season,
    count_month_with_sales,
    count_month_sales_more_than_avg,
    total_sales,
    avg_monthly_sales
FROM product_sales_summary
ORDER BY family, prod_reference, count_month_with_sales, count_month_sales_more_than_avg DESC