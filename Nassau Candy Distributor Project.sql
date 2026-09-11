-- ============================================================
-- NASSAU CANDY DISTRIBUTOR — SQL CAPSTONE PROJECT
-- Built by Uday Garg | Imarticus Learning — PG Data Science & Analytics
-- ============================================================
-- Run top to bottom in MySQL Workbench, in order.
-- ============================================================


-- ============================================================
-- SECTION 1: DATABASE & TABLE SETUP (DDL)
-- ============================================================

CREATE DATABASE IF NOT EXISTS nassau_candy_distributor;
USE nassau_candy_distributor;

-- (orders table created via Table Data Import Wizard from the CSV,
--  then renamed and re-typed below)

-- If starting fresh, uncomment and adjust based on your import:
-- RENAME TABLE `nassau _candy_distributor` TO orders;

ALTER TABLE orders
  CHANGE `Row ID` row_id INT,
  CHANGE `Order ID` order_id TEXT,
  CHANGE `Order Date` order_date TEXT,
  CHANGE `Ship Date` ship_date TEXT,
  CHANGE `Ship Mode` ship_mode TEXT,
  CHANGE `Customer ID` customer_id INT,
  CHANGE `Country/Region` country_region TEXT,
  CHANGE `City` city TEXT,
  CHANGE `State/Province` state_province TEXT,
  CHANGE `Postal Code` postal_code INT,
  CHANGE `Division` division TEXT,
  CHANGE `Region` region TEXT,
  CHANGE `Product ID` product_id TEXT,
  CHANGE `Product Name` product_name TEXT,
  CHANGE `Sales` sales DOUBLE,
  CHANGE `Units` units INT,
  CHANGE `Gross Profit` gross_profit DOUBLE,
  CHANGE `Cost` cost DOUBLE;

SELECT COUNT(*) FROM orders;


-- ------------------------------------------------------------
-- Reference tables (built manually from the business brief —
-- factory and product-to-factory data isn't in the source CSV)
-- ------------------------------------------------------------

CREATE TABLE factories (
    factory_id INT PRIMARY KEY AUTO_INCREMENT,
    factory_name VARCHAR(50) NOT NULL UNIQUE,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL
);

INSERT INTO factories (factory_name, latitude, longitude) VALUES
("Lot's O' Nuts", 32.881893, -111.768036),
("Wicked Choccy's", 32.076176, -81.088371),
('Sugar Shack', 48.11914, -96.18115),
('Secret Factory', 41.446333, -90.565487),
('The Other Factory', 35.1175, -89.971107);

SELECT * FROM factories;

CREATE TABLE product_factory_map (
    product_name VARCHAR(100) PRIMARY KEY,
    division VARCHAR(20) NOT NULL,
    factory_name VARCHAR(50) NOT NULL,
    FOREIGN KEY (factory_name) REFERENCES factories(factory_name)
);

INSERT INTO product_factory_map (division, product_name, factory_name) VALUES
('Chocolate', 'Wonka Bar - Nutty Crunch Surprise', "Lot's O' Nuts"),
('Chocolate', 'Wonka Bar - Fudge Mallows', "Lot's O' Nuts"),
('Chocolate', 'Wonka Bar -Scrumdiddlyumptious', "Lot's O' Nuts"),
('Chocolate', 'Wonka Bar - Milk Chocolate', "Wicked Choccy's"),
('Chocolate', 'Wonka Bar - Triple Dazzle Caramel', "Wicked Choccy's"),
('Sugar', 'Laffy Taffy', 'Sugar Shack'),
('Sugar', 'SweeTARTS', 'Sugar Shack'),
('Sugar', 'Nerds', 'Sugar Shack'),
('Sugar', 'Fun Dip', 'Sugar Shack'),
('Other', 'Fizzy Lifting Drinks', 'Sugar Shack'),
('Sugar', 'Everlasting Gobstopper', 'Secret Factory'),
('Sugar', 'Hair Toffee', 'The Other Factory'),
('Other', 'Lickable Wallpaper', 'Secret Factory'),
('Other', 'Wonka Gum', 'Secret Factory'),
('Other', 'Kazookles', 'The Other Factory');

SELECT COUNT(*) FROM product_factory_map;

-- Verify every product in orders matches the mapping table
SELECT DISTINCT o.product_name
FROM orders o
LEFT JOIN product_factory_map m ON o.product_name = m.product_name
WHERE m.product_name IS NULL;


-- ============================================================
-- SECTION 2: DATA QUALITY CHECK (Ship Date investigation)
-- ============================================================

SELECT `order_date`, `ship_date` FROM orders LIMIT 5;

-- Gap analysis: DATEDIFF shows Ship Date does NOT reflect real
-- shipping lead time — gaps cluster around 908 / 1,273 / 1,639
-- days, ~365 days apart, indicating the field was generated
-- independently of Order Date. Documented as a known limitation;
-- not used for lead-time calculations in this project.
SELECT
    DATEDIFF(STR_TO_DATE(ship_date,'%d-%m-%Y'), STR_TO_DATE(order_date,'%d-%m-%Y')) AS gap_days,
    COUNT(*)
FROM orders
GROUP BY gap_days
ORDER BY COUNT(*) DESC
LIMIT 20;


-- ============================================================
-- SECTION 3: DML — INSERT, UPDATE, DELETE
-- ============================================================

-- INSERT a sample row
INSERT INTO orders (row_id, order_id, order_date, ship_date, ship_mode,
    customer_id, country_region, city, state_province, postal_code,
    division, region, product_id, product_name, sales, units, gross_profit, cost)
VALUES (99999, 'TEST-001', '01-01-2024', '05-01-2024', 'Standard Class',
    12345, 'United States', 'Test City', 'Test State', 10001,
    'Sugar', 'Pacific', 'PROD-006', 'Nerds', 25.50, 10, 8.20, 17.30);

SELECT * FROM orders WHERE row_id = 99999;

-- UPDATE it
UPDATE orders SET gross_profit = 9.00 WHERE row_id = 99999;
SELECT * FROM orders WHERE row_id = 99999;

-- DELETE it (cleanup)
DELETE FROM orders WHERE row_id = 99999;
SELECT * FROM orders WHERE row_id = 99999;  -- should return 0 rows


-- ============================================================
-- SECTION 4: SELECT, WHERE & OPERATORS
-- ============================================================

SELECT * FROM orders WHERE region = 'Pacific' AND sales > 500;

SELECT * FROM orders WHERE ship_mode IN ('Standard Class','Same Day');

SELECT * FROM orders WHERE sales BETWEEN 100 AND 500;

SELECT * FROM orders WHERE product_name LIKE 'Wonka%';


-- ============================================================
-- SECTION 5: AGGREGATE FUNCTIONS, GROUP BY & HAVING
-- ============================================================

-- Overall business snapshot
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_line_items,
    SUM(units) AS total_units,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(gross_profit),2) AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS gross_margin_pct
FROM orders;

-- Sales & profit by factory (via the mapping table)
SELECT
    m.factory_name,
    COUNT(*) AS line_items,
    ROUND(SUM(o.sales),2) AS total_sales,
    ROUND(SUM(o.gross_profit),2) AS total_gross_profit,
    ROUND(SUM(o.gross_profit)/SUM(o.sales)*100,2) AS margin_pct
FROM orders o
JOIN product_factory_map m ON o.product_name = m.product_name
GROUP BY m.factory_name
ORDER BY total_sales DESC;

-- Sales & profit by region
SELECT
    region, COUNT(*) AS line_items,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(gross_profit),2) AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS margin_pct
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

-- Sales & profit by division
SELECT
    division, COUNT(*) AS line_items,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(gross_profit),2) AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS margin_pct
FROM orders
GROUP BY division
ORDER BY total_sales DESC;

-- Performance by ship mode
SELECT
    ship_mode, COUNT(*) AS line_items,
    ROUND(AVG(sales),2) AS avg_sales,
    ROUND(AVG(gross_profit),2) AS avg_gross_profit
FROM orders
GROUP BY ship_mode
ORDER BY avg_sales DESC;

-- Top 10 products by gross profit
SELECT
    product_name, division,
    ROUND(SUM(gross_profit),2) AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS margin_pct
FROM orders
GROUP BY product_name, division
ORDER BY total_gross_profit DESC
LIMIT 10;

-- Top 10 states by sales
SELECT state_province, COUNT(*) AS orders, ROUND(SUM(sales),2) AS total_sales
FROM orders
GROUP BY state_province
ORDER BY total_sales DESC
LIMIT 10;

-- HAVING: filters GROUPS, not rows (regions with total sales over 20,000)
SELECT region, ROUND(SUM(sales),2) AS total_sales
FROM orders
GROUP BY region
HAVING SUM(sales) > 20000
ORDER BY total_sales DESC;


-- ============================================================
-- SECTION 6: JOINS
-- ============================================================

-- INNER JOIN: only orders that have a matching factory mapping
SELECT o.order_id, o.product_name, m.factory_name
FROM orders o
INNER JOIN product_factory_map m ON o.product_name = m.product_name
LIMIT 20;

-- LEFT JOIN: find any product in the mapping table with zero real orders
SELECT m.product_name, m.factory_name
FROM product_factory_map m
LEFT JOIN orders o ON o.product_name = m.product_name
WHERE o.product_name IS NULL;


-- ============================================================
-- SECTION 7: SUBQUERIES (correlated vs non-correlated)
-- ============================================================

-- Non-correlated: inner query runs once, independent of the outer query
SELECT product_name, sales
FROM orders
WHERE sales > (SELECT AVG(sales) FROM orders);

-- Correlated: inner query re-runs per outer row, referencing o.region
SELECT o.order_id, o.region, o.sales
FROM orders o
WHERE o.sales = (
    SELECT MAX(o2.sales) FROM orders o2 WHERE o2.region = o.region
);


-- ============================================================
-- SECTION 8: SET OPERATIONS — UNION
-- ============================================================

SELECT product_name, sales FROM orders WHERE region = 'Pacific' AND sales > 1000
UNION
SELECT product_name, sales FROM orders WHERE region = 'Atlantic' AND sales > 1000;

-- UNION ALL keeps duplicates — compare row counts against the query above
SELECT product_name, sales FROM orders WHERE region = 'Pacific' AND sales > 1000
UNION ALL
SELECT product_name, sales FROM orders WHERE region = 'Atlantic' AND sales > 1000;


-- ============================================================
-- SECTION 9: STRING, DATE & NUMERIC FUNCTIONS
-- ============================================================

SELECT UPPER(product_name) AS product_upper, product_name FROM orders LIMIT 5;

SELECT CONCAT(city, ', ', state_province) AS location FROM orders LIMIT 5;

SELECT
    order_date,
    STR_TO_DATE(order_date, '%d-%m-%Y') AS parsed_date,
    MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')) AS order_month
FROM orders
LIMIT 5;


-- ============================================================
-- SECTION 10: CASE — STATEMENT & EXPRESSION
-- ============================================================

SELECT product_name, sales,
    CASE
        WHEN sales >= 1000 THEN 'High'
        WHEN sales >= 300 THEN 'Medium'
        ELSE 'Low'
    END AS sales_tier
FROM orders
LIMIT 20;

-- CASE used inside GROUP BY
SELECT
    CASE
        WHEN sales >= 1000 THEN 'High'
        WHEN sales >= 300 THEN 'Medium'
        ELSE 'Low'
    END AS sales_tier,
    COUNT(*) AS orders
FROM orders
GROUP BY sales_tier;


-- ============================================================
-- SECTION 11: CTEs — Statistically Slow Factory-Region Routes
-- ============================================================
-- Uses ship_mode as a proxy performance signal, since real
-- lead time isn't available (see Section 2 data quality note).

WITH route_stats AS (
    SELECT m.factory_name, o.region,
           COUNT(*) AS n,
           ROUND(AVG(o.gross_profit/o.sales)*100, 2) AS avg_margin_pct
    FROM orders o
    JOIN product_factory_map m ON o.product_name = m.product_name
    GROUP BY m.factory_name, o.region
),
overall AS (
    SELECT AVG(gross_profit/sales)*100 AS mean_margin,
           SQRT(AVG(POWER(gross_profit/sales*100,2)) - POWER(AVG(gross_profit/sales*100),2)) AS std_margin
    FROM orders
)
SELECT r.factory_name, r.region, r.avg_margin_pct, r.n AS order_count
FROM route_stats r, overall o
WHERE r.avg_margin_pct < o.mean_margin - o.std_margin
ORDER BY r.avg_margin_pct ASC;


-- ============================================================
-- SECTION 12: WINDOW FUNCTIONS — RANK()
-- ============================================================

SELECT
    m.factory_name,
    o.product_name,
    ROUND(SUM(o.gross_profit),2) AS total_profit,
    RANK() OVER (PARTITION BY m.factory_name ORDER BY SUM(o.gross_profit) DESC) AS profit_rank
FROM orders o
JOIN product_factory_map m ON o.product_name = m.product_name
GROUP BY m.factory_name, o.product_name
ORDER BY m.factory_name, profit_rank;


-- ============================================================
-- SECTION 13: VIEWS
-- ============================================================

CREATE VIEW vw_factory_summary AS
SELECT
    m.factory_name,
    COUNT(*) AS total_orders,
    ROUND(SUM(o.sales),2) AS total_sales,
    ROUND(SUM(o.gross_profit)/SUM(o.sales)*100,2) AS margin_pct
FROM orders o
JOIN product_factory_map m ON o.product_name = m.product_name
GROUP BY m.factory_name;

SELECT * FROM vw_factory_summary ORDER BY total_sales DESC;
