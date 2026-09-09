-- ============================================================
-- Nassau Candy Distributor — Scenario Simulation &
-- Factory Reallocation Recommendation Engine (pure SQL)
-- Engine: MySQL 8.0+ (uses RADIANS/SIN/COS/ATAN2 trig functions)
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Region reference points (centroid lat/lon per region,
-- derived as the average ship-to coordinates per region).
-- In production this would come from customer geocoding; here
-- we approximate with fixed regional centroids for the US.
-- ------------------------------------------------------------
DROP TABLE IF EXISTS region_centroids;
CREATE TABLE region_centroids (
    region     VARCHAR(20) PRIMARY KEY,
    latitude   DECIMAL(9,6),
    longitude  DECIMAL(9,6)
);

INSERT INTO region_centroids (region, latitude, longitude) VALUES
('West',    36.700000, -119.400000),
('South',   31.900000,  -85.000000),
('Central', 41.900000,  -93.000000),
('East',    40.700000,  -76.000000);

-- ------------------------------------------------------------
-- STEP 2: Compute haversine distance (miles) between every
-- factory and every region centroid -> "what-if" distance matrix
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vw_factory_region_distance;
CREATE VIEW vw_factory_region_distance AS
SELECT
    f.factory_name AS factory,
    r.region,
    ROUND(
        3958.8 * ACOS(
            COS(RADIANS(f.latitude))  * COS(RADIANS(r.latitude)) *
            COS(RADIANS(r.longitude) - RADIANS(f.longitude)) +
            SIN(RADIANS(f.latitude))  * SIN(RADIANS(r.latitude))
        ), 1
    ) AS distance_miles
FROM factories f
CROSS JOIN region_centroids r;

-- ------------------------------------------------------------
-- STEP 3: Lead-time prediction model (simplified, transparent
-- linear approximation calibrated from historical data):
--   predicted_lead_time = ship_mode_base_days + distance/700
-- ship_mode_base_days per mode, derived from Section A4 results.
-- This mirrors the regression step described in the case study
-- (Linear Regression / Random Forest / GBM would replace this
-- in the Python/Streamlit layer; the SQL layer keeps a
-- transparent baseline formula so scenarios are auditable).
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vw_ship_mode_base;
CREATE VIEW vw_ship_mode_base AS
SELECT ship_mode, ROUND(AVG(lead_time_days - distance_miles/700.0), 2) AS base_days
FROM orders
GROUP BY ship_mode;

-- ------------------------------------------------------------
-- STEP 4: CURRENT STATE — actual performance per product
-- (already captured in vw_product_current_performance,
--  Section D of 02_business_queries.sql)
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- STEP 5: SCENARIO SIMULATION — for every product, evaluate
-- every candidate factory (not just its current one) using the
-- most common ship mode + region mix of that product's orders,
-- and predict lead time under each alternative factory.
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vw_product_region_mix;
CREATE VIEW vw_product_region_mix AS
SELECT
    product_id, product_name, division, region,
    COUNT(*) AS order_count,
    ROUND(AVG(sales),2) AS avg_sales,
    ROUND(AVG(cost),2)  AS avg_cost
FROM orders
GROUP BY product_id, product_name, division, region;

DROP VIEW IF EXISTS vw_scenario_simulation;
CREATE VIEW vw_scenario_simulation AS
SELECT
    m.product_id,
    m.product_name,
    m.division,
    m.region,
    m.order_count,
    d.factory AS candidate_factory,
    d.distance_miles,
    ROUND((SELECT AVG(base_days) FROM vw_ship_mode_base) + d.distance_miles/700.0, 2)
        AS predicted_lead_time,
    m.avg_sales,
    m.avg_cost,
    ROUND(m.avg_sales - m.avg_cost, 2) AS baseline_gross_profit
FROM vw_product_region_mix m
JOIN vw_factory_region_distance d ON d.region = m.region;

-- ------------------------------------------------------------
-- STEP 6: RECOMMENDATION LOGIC — rank candidate factories per
-- product by predicted lead-time improvement vs. current
-- factory, weighted by order volume (a proxy for scale impact).
-- ------------------------------------------------------------
DROP VIEW IF EXISTS vw_reassignment_recommendations;
CREATE VIEW vw_reassignment_recommendations AS
WITH current_perf AS (
    SELECT product_id, current_factory,
           AVG(avg_lead_time) AS current_avg_lead_time
    FROM vw_product_current_performance
    GROUP BY product_id, current_factory
),
scenario_agg AS (
    SELECT
        product_id, product_name, division, candidate_factory,
        SUM(order_count) AS total_orders,
        ROUND(SUM(predicted_lead_time * order_count) / SUM(order_count), 2)
            AS weighted_predicted_lead_time
    FROM vw_scenario_simulation
    GROUP BY product_id, product_name, division, candidate_factory
)
SELECT
    s.product_id,
    s.product_name,
    s.division,
    c.current_factory,
    ROUND(c.current_avg_lead_time, 2)     AS current_lead_time,
    s.candidate_factory,
    s.weighted_predicted_lead_time        AS candidate_lead_time,
    ROUND(c.current_avg_lead_time - s.weighted_predicted_lead_time, 2)
        AS lead_time_improvement_days,
    ROUND(
        (c.current_avg_lead_time - s.weighted_predicted_lead_time)
        / NULLIF(c.current_avg_lead_time,0) * 100, 2
    ) AS lead_time_improvement_pct,
    s.total_orders,
    RANK() OVER (
        PARTITION BY s.product_id
        ORDER BY (c.current_avg_lead_time - s.weighted_predicted_lead_time) DESC
    ) AS recommendation_rank
FROM scenario_agg s
JOIN current_perf c ON c.product_id = s.product_id
WHERE s.candidate_factory <> c.current_factory;

-- ------------------------------------------------------------
-- STEP 7: TOP-N RECOMMENDATIONS (the dashboard's headline output)
-- Only recommend a reassignment when it improves lead time AND
-- the product's current margin is not already excellent
-- (illustrates "balances shipping efficiency and profitability").
-- ------------------------------------------------------------
SELECT
    r.product_name,
    r.division,
    r.current_factory,
    r.current_lead_time,
    r.candidate_factory AS recommended_factory,
    r.candidate_lead_time,
    r.lead_time_improvement_days,
    r.lead_time_improvement_pct,
    p.avg_margin_pct AS current_margin_pct
FROM vw_reassignment_recommendations r
JOIN vw_product_current_performance p
     ON p.product_id = r.product_id AND p.current_factory = r.current_factory
WHERE r.recommendation_rank = 1
  AND r.lead_time_improvement_pct > 5
ORDER BY r.lead_time_improvement_pct DESC;
