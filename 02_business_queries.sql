-- ============================================================
-- Nassau Candy Distributor — Business Analysis Queries
-- Section A: Exploratory / Descriptive Analytics
-- ============================================================

-- A1. Overall business snapshot
SELECT
    COUNT(DISTINCT order_id)            AS total_orders,
    COUNT(*)                            AS total_line_items,
    SUM(units)                          AS total_units,
    ROUND(SUM(sales),2)                 AS total_sales,
    ROUND(SUM(gross_profit),2)          AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS gross_margin_pct
FROM orders;

-- A2. Sales & profit by factory
SELECT
    factory,
    COUNT(*)                       AS line_items,
    ROUND(SUM(sales),2)            AS total_sales,
    ROUND(SUM(gross_profit),2)     AS total_gross_profit,
    ROUND(AVG(lead_time_days),2)   AS avg_lead_time_days,
    ROUND(AVG(distance_miles),1)   AS avg_distance_miles
FROM orders
GROUP BY factory
ORDER BY total_sales DESC;

-- A3. Sales & lead time by region
SELECT
    region,
    COUNT(*)                       AS line_items,
    ROUND(SUM(sales),2)            AS total_sales,
    ROUND(AVG(lead_time_days),2)   AS avg_lead_time_days,
    ROUND(AVG(distance_miles),1)   AS avg_distance_miles
FROM orders
GROUP BY region
ORDER BY avg_lead_time_days DESC;

-- A4. Ship mode performance
SELECT
    ship_mode,
    COUNT(*)                       AS line_items,
    ROUND(AVG(lead_time_days),2)   AS avg_lead_time_days,
    ROUND(AVG(gross_profit),2)     AS avg_gross_profit
FROM orders
GROUP BY ship_mode
ORDER BY avg_lead_time_days;

-- A5. Top 10 products by gross profit
SELECT
    product_name,
    division,
    factory,
    ROUND(SUM(gross_profit),2) AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS margin_pct
FROM orders
GROUP BY product_name, division, factory
ORDER BY total_gross_profit DESC
LIMIT 10;

-- ============================================================
-- Section B: Shipping Efficiency & Route Diagnostics
-- ============================================================

-- B1. Factory x Region matrix: avg lead time & distance
-- (identifies which factory-region pairs are inefficient)
SELECT
    factory,
    region,
    COUNT(*)                       AS orders,
    ROUND(AVG(lead_time_days),2)   AS avg_lead_time,
    ROUND(AVG(distance_miles),1)   AS avg_distance,
    ROUND(AVG(gross_profit),2)     AS avg_gross_profit
FROM orders
GROUP BY factory, region
ORDER BY avg_lead_time DESC;

-- B2. Consistently slow routes (avg lead time > overall avg + 1 std dev)
WITH route_stats AS (
    SELECT
        factory, region,
        AVG(lead_time_days) AS avg_lt,
        COUNT(*) AS n
    FROM orders
    GROUP BY factory, region
),
overall AS (
    SELECT AVG(lead_time_days) AS mean_lt,
           -- population std dev, portable formula
           SQRT(AVG(lead_time_days*lead_time_days) - AVG(lead_time_days)*AVG(lead_time_days)) AS std_lt
    FROM orders
)
SELECT r.factory, r.region, ROUND(r.avg_lt,2) AS avg_lead_time, r.n AS order_count
FROM route_stats r, overall o
WHERE r.avg_lt > o.mean_lt + o.std_lt
ORDER BY r.avg_lt DESC;

-- B3. Congested region-product combinations (high volume + high lead time)
SELECT
    region,
    product_name,
    COUNT(*)                     AS order_count,
    ROUND(AVG(lead_time_days),2) AS avg_lead_time
FROM orders
GROUP BY region, product_name
HAVING order_count > (SELECT AVG(cnt) FROM (
        SELECT COUNT(*) AS cnt FROM orders GROUP BY region, product_name
    ) t)
   AND avg_lead_time > (SELECT AVG(lead_time_days) FROM orders)
ORDER BY avg_lead_time DESC, order_count DESC;

-- B4. Distance vs. lead time correlation check (binned)
SELECT
    CASE
        WHEN distance_miles < 500  THEN '0-500 mi'
        WHEN distance_miles < 1000 THEN '500-1000 mi'
        WHEN distance_miles < 1500 THEN '1000-1500 mi'
        WHEN distance_miles < 2000 THEN '1500-2000 mi'
        ELSE '2000+ mi'
    END AS distance_band,
    COUNT(*) AS orders,
    ROUND(AVG(lead_time_days),2) AS avg_lead_time
FROM orders
GROUP BY distance_band
ORDER BY MIN(distance_miles);

-- ============================================================
-- Section C: Profitability & Margin Erosion Analysis
-- ============================================================

-- C1. Margin erosion by distance band (tests "long-haul kills margin")
SELECT
    CASE
        WHEN distance_miles < 500  THEN '0-500 mi'
        WHEN distance_miles < 1000 THEN '500-1000 mi'
        WHEN distance_miles < 1500 THEN '1000-1500 mi'
        WHEN distance_miles < 2000 THEN '1500-2000 mi'
        ELSE '2000+ mi'
    END AS distance_band,
    ROUND(AVG(gross_profit / NULLIF(sales,0)) * 100, 2) AS avg_margin_pct,
    ROUND(AVG(lead_time_days),2) AS avg_lead_time,
    COUNT(*) AS orders
FROM orders
GROUP BY distance_band
ORDER BY MIN(distance_miles);

-- C2. Product-level profitability ranked within each factory
-- (window function: RANK)
SELECT
    factory,
    product_name,
    ROUND(SUM(gross_profit),2) AS total_gross_profit,
    RANK() OVER (PARTITION BY factory ORDER BY SUM(gross_profit) DESC) AS profit_rank
FROM orders
GROUP BY factory, product_name
ORDER BY factory, profit_rank;

-- C3. Month-over-month sales trend per factory (window function: LAG)
SELECT
    factory,
    strftime('%Y-%m', order_date) AS order_month,
    ROUND(SUM(sales),2) AS monthly_sales,
    ROUND(SUM(sales) - LAG(SUM(sales)) OVER (
        PARTITION BY factory ORDER BY strftime('%Y-%m', order_date)
    ), 2) AS mom_change
FROM orders
GROUP BY factory, order_month
ORDER BY factory, order_month;

-- ============================================================
-- Section D: KPI Views (for the Streamlit dashboard)
-- ============================================================

DROP VIEW IF EXISTS vw_factory_region_kpi;
CREATE VIEW vw_factory_region_kpi AS
SELECT
    factory,
    region,
    COUNT(*)                          AS order_count,
    ROUND(AVG(lead_time_days),2)      AS avg_lead_time,
    ROUND(AVG(distance_miles),1)      AS avg_distance,
    ROUND(SUM(gross_profit),2)        AS total_gross_profit,
    ROUND(AVG(gross_profit/NULLIF(sales,0))*100,2) AS avg_margin_pct
FROM orders
GROUP BY factory, region;

DROP VIEW IF EXISTS vw_product_current_performance;
CREATE VIEW vw_product_current_performance AS
SELECT
    o.product_id,
    o.product_name,
    o.division,
    o.factory AS current_factory,
    COUNT(*)                          AS order_count,
    ROUND(AVG(o.lead_time_days),2)    AS avg_lead_time,
    ROUND(AVG(o.distance_miles),1)    AS avg_distance,
    ROUND(SUM(o.gross_profit),2)      AS total_gross_profit,
    ROUND(AVG(o.gross_profit/NULLIF(o.sales,0))*100,2) AS avg_margin_pct
FROM orders o
GROUP BY o.product_id, o.product_name, o.division, o.factory;
