{{ config(
    materialized='incremental',
    unique_key=['tenant', 'year', 'store_id', 'product_id'],
    cluster_by=['tenant', 'year'],
    incremental_strategy='merge',
    enabled=false
) }}

{% if is_incremental() %}
    {% set min_date = "SELECT DATEADD(YEAR, -1, MAX(date)) FROM " ~ this %}
{% else %}
    {% set min_date = "SELECT MIN(date) FROM " ~ ref('sales') %}
{% endif %}

WITH sales_with_skus AS (
    SELECT 
        sk.tenant,
        sl.store_id,
        sk.product_id,
        sl.date,
        YEAR(sl.date) AS year,
        sl.quantity AS sales_quantity
    FROM {{ ref('sales') }} sl
    JOIN {{ ref('skus') }} sk 
        ON sk.id = sl.sku_id
        AND sk.tenant = sl.tenant
    {% if is_incremental() %}
    WHERE sl.date >= ({{ min_date }})
    {% endif %}
),

stocks_aggregated AS (
    SELECT 
        sk.tenant,
        ssi.store_id,
        ssi.sku_id,
        ssi.date,
        SUM(ssi.stock_commercial) AS stock_quantity
    FROM {{ ref('store_stock_items') }} ssi
    JOIN {{ ref('skus') }} sk ON sk.id = ssi.sku_id
        AND sk.tenant = ssi.tenant
    {% if is_incremental() %}
    WHERE ssi.date >= ({{ min_date }})
    {% endif %}
    GROUP BY sk.tenant, ssi.store_id, ssi.sku_id, ssi.date
),

warehouse_aggregated AS (
    SELECT 
        sk.tenant,
        wsi.sku_id,
        wsi.date,
        SUM(wsi.quantity) AS warehouse_quantity
    FROM {{ ref('warehouse_stock_items') }} wsi
    JOIN {{ ref('skus') }} sk ON sk.id = wsi.sku_id
        AND sk.tenant = wsi.tenant
    {% if is_incremental() %}
    WHERE wsi.date >= ({{ min_date }})
    {% endif %}
    GROUP BY sk.tenant, wsi.sku_id, wsi.date
),

base_metrics AS (
    SELECT 
        s.tenant,
        s.store_id,
        s.product_id,
        s.date,
        s.year,
        s.sales_quantity,
        COALESCE(sa.stock_quantity, 0) AS stock_quantity,
        COALESCE(wa.warehouse_quantity, 0) AS warehouse_quantity
    FROM sales_with_skus s
    LEFT JOIN stocks_aggregated sa
        ON sa.tenant = s.tenant
        AND sa.store_id = s.store_id
        AND sa.sku_id = s.sku_id
        AND sa.date = s.date
    LEFT JOIN warehouse_aggregated wa
        ON wa.tenant = s.tenant
        AND wa.sku_id = s.sku_id
        AND wa.date = s.date
),

metrics_by_period AS (
    SELECT 
        tenant,
        store_id,
        product_id,
        year,
        SUM(sales_quantity) AS total_sales,
        ROUND(AVG(stock_quantity), 0) AS avg_stocks,
        LAST_VALUE(stock_quantity) OVER (
            PARTITION BY tenant, store_id, product_id, year
            ORDER BY date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS end_stocks,
        SUM(warehouse_quantity) AS warehouse_stocks,
        SUM(sales_quantity) AS product_sales
    FROM base_metrics
    GROUP BY tenant, store_id, product_id, year, stock_quantity, date
),

final_metrics AS (
    SELECT 
        tenant,
        year,
        store_id,
        product_id,
        total_sales AS total_sales_in_units,
        avg_stocks AS avg_daily_stocks,
        end_stocks,
        warehouse_stocks AS end_warehouse_stocks,
        total_sales + end_stocks + warehouse_stocks AS buy,
        CASE 
            WHEN product_sales >= 500 THEN 500
            WHEN product_sales >= 200 THEN 200
            WHEN product_sales >= 100 THEN 100
            WHEN product_sales >= 50 THEN 50
            WHEN product_sales >= 20 THEN 20
            WHEN product_sales >= 10 THEN 10
            WHEN product_sales >= 5 THEN 5
            WHEN product_sales >= 1 THEN 1
            ELSE 0
        END AS active_threshold
    FROM metrics_by_period
)

SELECT 
    tenant,
    year,
    store_id,
    product_id,
    total_sales_in_units,
    avg_daily_stocks,
    end_stocks,
    end_warehouse_stocks,
    buy,
    ROUND(100 * total_sales_in_units / NULLIF(total_sales_in_units + end_stocks, 0), 2) || '%' AS sell_through,
    ROUND(100 * total_sales_in_units / NULLIF(total_sales_in_units + avg_daily_stocks, 0), 2) || '%' AS avg_sell_through,
    ROUND(100 * total_sales_in_units / NULLIF(total_sales_in_units + end_stocks + end_warehouse_stocks, 0), 2) || '%' AS sell_out,
    active_threshold
FROM final_metrics
ORDER BY tenant, year, store_id, product_id