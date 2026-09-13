-- ============================================================
-- NASSAU CANDY DISTRIBUTOR — SQL CAPSTONE PROJECT
-- Built by Uday Garg | Imarticus Learning — PG Data Science & Analytics
-- ============================================================

# Nassau Candy Distributor SQL Project
# Uday Garg

# create the database
CREATE DATABASE IF NOT EXISTS nassau_candy_distributor;
USE nassau_candy_distributor;

# fix column names and data types after importing the csv
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

# check how many rows we have
SELECT COUNT(*) FROM orders;


# ---------- factories table ----------
# stores the 5 factories with their location

CREATE TABLE factories (
    factory_id      INT PRIMARY KEY AUTO_INCREMENT,
    factory_name    VARCHAR(50) NOT NULL UNIQUE,
    latitude        DECIMAL(9,6) NOT NULL,
    longitude       DECIMAL(9,6) NOT NULL
);

INSERT INTO factories (factory_name, latitude, longitude) VALUES
("Lot's O' Nuts", 32.881893, -111.768036),
("Wicked Choccy's", 32.076176, -81.088371),
('Sugar Shack', 48.11914, -96.18115),
('Secret Factory', 41.446333, -90.565487),
('The Other Factory', 35.1175, -89.971107);

SELECT * FROM factories;

# ---------- product_factory_map table ----------
# tells us which product is made in which factory

CREATE TABLE product_factory_map (
    product_name    VARCHAR(100) PRIMARY KEY,
    division        VARCHAR(20) NOT NULL,
    factory_name    VARCHAR(50) NOT NULL,
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

# check if any product in orders has no matching factory
SELECT DISTINCT o.product_name
FROM orders o
LEFT JOIN product_factory_map m ON o.product_name = m.product_name
WHERE m.product_name IS NULL;


# ---------- customers table ----------
# pulling customer details out of orders into their own table
# MIN() is used so each customer only appears once

CREATE TABLE customers (
    customer_id     INT PRIMARY KEY,
    city            VARCHAR(50),
    state_province  VARCHAR(50),
    country_region  VARCHAR(50),
    postal_code     INT
);

INSERT INTO customers (customer_id, city, state_province, country_region, postal_code)
SELECT
    customer_id,
    MIN(city),
    MIN(state_province),
    MIN(country_region),
    MIN(postal_code)
FROM orders
GROUP BY customer_id;

SELECT COUNT(*) FROM customers;

# link orders to customers
# if a customer is ever deleted, keep the order but set customer_id to null
ALTER TABLE orders
  ADD CONSTRAINT fk_orders_customer
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
  ON DELETE SET NULL
  ON UPDATE CASCADE;


# ---------- constraints demo ----------
# small table just to show NOT NULL, UNIQUE, CHECK, DEFAULT

CREATE TABLE constraint_demo (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    sku         VARCHAR(20) NOT NULL UNIQUE,
    unit_price  DECIMAL(8,2) NOT NULL CHECK (unit_price > 0),
    factory_name VARCHAR(50) DEFAULT 'Unassigned'
);

INSERT INTO constraint_demo (sku, unit_price) VALUES ('SKU-001', 4.50);
SELECT * FROM constraint_demo;


# ---------- alter, rename, drop, truncate ----------

ALTER TABLE constraint_demo ADD COLUMN notes VARCHAR(100);
ALTER TABLE constraint_demo RENAME COLUMN notes TO remarks;
ALTER TABLE constraint_demo DROP COLUMN remarks;

RENAME TABLE constraint_demo TO constraint_demo_renamed;
RENAME TABLE constraint_demo_renamed TO constraint_demo;

# truncate empties the table but keeps the structure
TRUNCATE TABLE constraint_demo;
SELECT * FROM constraint_demo;


# ---------- checking ship date ----------
# comparing order date and ship date to see if the gap makes sense

SELECT `order_date`, `ship_date` FROM orders LIMIT 5;

SELECT
    DATEDIFF(STR_TO_DATE(ship_date,'%d-%m-%Y'), STR_TO_DATE(order_date,'%d-%m-%Y')) AS gap_days,
    COUNT(*)
FROM orders
GROUP BY gap_days
ORDER BY COUNT(*) DESC
LIMIT 20;
# the gap is way too large for real shipping (2-4 years), so ship_date
# is not used anywhere else in this project


# ---------- insert, update, delete ----------

# add a new row
INSERT INTO orders (row_id, order_id, order_date, ship_date, ship_mode,
    customer_id, country_region, city, state_province, postal_code,
    division, region, product_id, product_name, sales, units, gross_profit, cost)
VALUES (99999, 'TEST-001', '01-01-2024', '05-01-2024', 'Standard Class',
    NULL, 'United States', 'Test City', 'Test State', 10001,
    'Sugar', 'Pacific', 'PROD-006', 'Nerds', 25.50, 10, 8.20, 17.30);

SELECT * FROM orders WHERE row_id = 99999;

# change a value
UPDATE orders SET gross_profit = 9.00 WHERE row_id = 99999;
SELECT * FROM orders WHERE row_id = 99999;

# remove the row again
DELETE FROM orders WHERE row_id = 99999;
SELECT * FROM orders WHERE row_id = 99999;


# ---------- select, where, operators ----------

SELECT * FROM orders WHERE region = 'Pacific' AND sales > 500;

SELECT * FROM orders WHERE ship_mode IN ('Standard Class','Same Day');

SELECT * FROM orders WHERE sales BETWEEN 100 AND 500;

SELECT * FROM orders WHERE product_name LIKE 'Wonka%';

SELECT * FROM orders WHERE NOT region = 'Gulf' LIMIT 20;

SELECT DISTINCT ship_mode FROM orders;


# ---------- aggregate functions, group by, having ----------

# total sales, profit and margin for the whole business
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_line_items,
    SUM(units) AS total_units,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(gross_profit),2) AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS gross_margin_pct
FROM orders;

# sales and profit for each factory
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

# sales and profit for each region
SELECT
    region, COUNT(*) AS line_items,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(gross_profit),2) AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS margin_pct
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

# sales and profit for each division
SELECT
    division, COUNT(*) AS line_items,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(gross_profit),2) AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS margin_pct
FROM orders
GROUP BY division
ORDER BY total_sales DESC;

# average sales for each ship mode
SELECT
    ship_mode, COUNT(*) AS line_items,
    ROUND(AVG(sales),2) AS avg_sales,
    ROUND(AVG(gross_profit),2) AS avg_gross_profit
FROM orders
GROUP BY ship_mode
ORDER BY avg_sales DESC;

# top 10 products by profit
SELECT
    product_name, division,
    ROUND(SUM(gross_profit),2) AS total_gross_profit,
    ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS margin_pct
FROM orders
GROUP BY product_name, division
ORDER BY total_gross_profit DESC
LIMIT 10;

# top 10 states by sales
SELECT state_province, COUNT(*) AS orders, ROUND(SUM(sales),2) AS total_sales
FROM orders
GROUP BY state_province
ORDER BY total_sales DESC
LIMIT 10;

# top 10 customers by total spend
SELECT c.customer_id, c.city, c.state_province, ROUND(SUM(o.sales),2) AS total_spend
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.city, c.state_province
ORDER BY total_spend DESC
LIMIT 10;

# HAVING filters groups after they're made, WHERE filters rows before
SELECT region, ROUND(SUM(sales),2) AS total_sales
FROM orders
GROUP BY region
HAVING SUM(sales) > 20000
ORDER BY total_sales DESC;

# HAVING with two conditions
SELECT region, COUNT(*) AS orders, ROUND(AVG(sales),2) AS avg_sales
FROM orders
GROUP BY region
HAVING AVG(sales) > 100 AND COUNT(*) > 500
ORDER BY avg_sales DESC;

# using WHERE, GROUP BY, HAVING and ORDER BY together
SELECT region, ROUND(SUM(sales),2) AS total_sales
FROM orders
WHERE sales > 0
GROUP BY region
HAVING SUM(sales) > 20000
ORDER BY total_sales DESC
LIMIT 5;


# ---------- joins ----------

# inner join - only matching rows from both tables
SELECT o.order_id, o.product_name, m.factory_name
FROM orders o
INNER JOIN product_factory_map m ON o.product_name = m.product_name
LIMIT 20;

# left join - all products, even ones with no orders
SELECT m.product_name, m.factory_name, o.order_id
FROM product_factory_map m
LEFT JOIN orders o ON o.product_name = m.product_name
WHERE o.product_name IS NULL;

# right join - all orders, even if no factory match
SELECT o.order_id, o.product_name, m.factory_name
FROM product_factory_map m
RIGHT JOIN orders o ON o.product_name = m.product_name
LIMIT 20;

# cross join - every factory paired with every division
SELECT f.factory_name, d.division
FROM factories f
CROSS JOIN (SELECT DISTINCT division FROM product_factory_map) d;

# self join - products made in the same factory, paired up
SELECT a.product_name AS product_a, b.product_name AS product_b, a.factory_name
FROM product_factory_map a
JOIN product_factory_map b
  ON a.factory_name = b.factory_name AND a.product_name < b.product_name
ORDER BY a.factory_name
LIMIT 15;

# joining three tables together
SELECT o.order_id, c.city, m.factory_name, o.sales
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN product_factory_map m ON o.product_name = m.product_name
LIMIT 20;


# ---------- subqueries ----------

# non-correlated - inner query runs once on its own
SELECT product_name, sales
FROM orders
WHERE sales > (SELECT AVG(sales) FROM orders);

# correlated - inner query runs again for every row of the outer query
SELECT o.order_id, o.region, o.sales
FROM orders o
WHERE o.sales = (
    SELECT MAX(o2.sales) FROM orders o2 WHERE o2.region = o.region
);

# subquery with IN
SELECT product_name, division
FROM product_factory_map
WHERE factory_name IN (
    SELECT factory_name FROM factories WHERE latitude > 40
);

# subquery with EXISTS
SELECT c.customer_id, c.city
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.sales > 1000
);


# ---------- union / union all ----------

# union removes duplicate rows
SELECT product_name, sales FROM orders WHERE region = 'Pacific' AND sales > 1000
UNION
SELECT product_name, sales FROM orders WHERE region = 'Atlantic' AND sales > 1000;

# union all keeps duplicates
SELECT product_name, sales FROM orders WHERE region = 'Pacific' AND sales > 1000
UNION ALL
SELECT product_name, sales FROM orders WHERE region = 'Atlantic' AND sales > 1000;

# products that appear in both Pacific and Gulf
SELECT DISTINCT product_name FROM orders WHERE region = 'Pacific'
  AND product_name IN (SELECT product_name FROM orders WHERE region = 'Gulf');


# ---------- string, date, numeric functions, null handling ----------

SELECT UPPER(product_name) AS product_upper, LOWER(division) AS division_lower FROM orders LIMIT 5;

SELECT CONCAT(city, ', ', state_province) AS location, LENGTH(product_name) AS name_length FROM orders LIMIT 5;

SELECT TRIM(product_name) AS trimmed_name, SUBSTRING(product_name, 1, 10) AS short_name FROM orders LIMIT 5;

# pulling month, year and weekday out of order_date
SELECT
    order_date,
    STR_TO_DATE(order_date, '%d-%m-%Y') AS parsed_date,
    MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')) AS order_month,
    YEAR(STR_TO_DATE(order_date, '%d-%m-%Y')) AS order_year,
    DAYNAME(STR_TO_DATE(order_date, '%d-%m-%Y')) AS order_weekday
FROM orders
LIMIT 5;

SELECT ROUND(sales, 0) AS rounded_sales, CEIL(sales) AS ceil_sales, FLOOR(sales) AS floor_sales
FROM orders LIMIT 5;

# replacing NULL values with a default
SELECT order_id, IFNULL(customer_id, 0) AS customer_id_safe FROM orders LIMIT 5;
SELECT order_id, COALESCE(customer_id, -1) AS customer_id_safe FROM orders LIMIT 5;

# any math with NULL gives NULL
SELECT sales, NULL + sales AS demo_null_arithmetic FROM orders LIMIT 3;


# ---------- case ----------

# labeling each order as high, medium or low
SELECT product_name, sales,
    CASE
        WHEN sales >= 1000 THEN 'High'
        WHEN sales >= 300 THEN 'Medium'
        ELSE 'Low'
    END AS sales_tier
FROM orders
LIMIT 20;

# same CASE logic used to group and count
SELECT
    CASE
        WHEN sales >= 1000 THEN 'High'
        WHEN sales >= 300 THEN 'Medium'
        ELSE 'Low'
    END AS sales_tier,
    COUNT(*) AS orders
FROM orders
GROUP BY sales_tier;


# ---------- ctes ----------

# finds factory-region pairs with margin way below average
WITH route_stats AS (
    SELECT m.factory_name, o.region,
           COUNT(*) AS n,
           ROUND(AVG(o.gross_profit / NULLIF(o.sales,0)) * 100, 2) AS avg_margin_pct
    FROM orders o
    JOIN product_factory_map m ON o.product_name = m.product_name
    GROUP BY m.factory_name, o.region
),
overall AS (
    SELECT
        AVG(gross_profit / NULLIF(sales,0)) * 100 AS mean_margin,
        SQRT(GREATEST(
            AVG(POWER(gross_profit / NULLIF(sales,0) * 100, 2))
            - POWER(AVG(gross_profit / NULLIF(sales,0) * 100), 2),
            0
        )) AS std_margin
    FROM orders
)
SELECT r.factory_name, r.region, r.avg_margin_pct, r.n AS order_count
FROM route_stats r, overall o
WHERE r.avg_margin_pct < o.mean_margin - o.std_margin
ORDER BY r.avg_margin_pct ASC;

# running total of monthly sales per factory
WITH monthly_factory_sales AS (
    SELECT
        m.factory_name,
        DATE_FORMAT(STR_TO_DATE(o.order_date,'%d-%m-%Y'), '%Y-%m') AS order_month,
        ROUND(SUM(o.sales),2) AS monthly_sales
    FROM orders o
    JOIN product_factory_map m ON o.product_name = m.product_name
    GROUP BY m.factory_name, order_month
)
SELECT
    factory_name, order_month, monthly_sales,
    SUM(monthly_sales) OVER (PARTITION BY factory_name ORDER BY order_month) AS running_total
FROM monthly_factory_sales
ORDER BY factory_name, order_month;


# ---------- window functions ----------

# RANK - ties get the same rank, next rank skips a number
SELECT
    m.factory_name, o.product_name,
    ROUND(SUM(o.gross_profit),2) AS total_profit,
    RANK() OVER (PARTITION BY m.factory_name ORDER BY SUM(o.gross_profit) DESC) AS profit_rank
FROM orders o
JOIN product_factory_map m ON o.product_name = m.product_name
GROUP BY m.factory_name, o.product_name
ORDER BY m.factory_name, profit_rank;

# DENSE_RANK - ties get the same rank, next rank does not skip
SELECT
    m.factory_name, o.product_name,
    ROUND(SUM(o.gross_profit),2) AS total_profit,
    DENSE_RANK() OVER (PARTITION BY m.factory_name ORDER BY SUM(o.gross_profit) DESC) AS profit_dense_rank
FROM orders o
JOIN product_factory_map m ON o.product_name = m.product_name
GROUP BY m.factory_name, o.product_name
ORDER BY m.factory_name, profit_dense_rank;

# ROW_NUMBER - always gives a unique number, even for ties
SELECT
    region, product_name, sales,
    ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS row_num
FROM orders
LIMIT 20;

# LAG - compares each month's sales to the previous month
WITH monthly_region_sales AS (
    SELECT region,
           DATE_FORMAT(STR_TO_DATE(order_date,'%d-%m-%Y'), '%Y-%m') AS order_month,
           ROUND(SUM(sales),2) AS monthly_sales
    FROM orders
    GROUP BY region, order_month
)
SELECT region, order_month, monthly_sales,
       LAG(monthly_sales) OVER (PARTITION BY region ORDER BY order_month) AS prev_month_sales,
       ROUND(monthly_sales - LAG(monthly_sales) OVER (PARTITION BY region ORDER BY order_month), 2) AS mom_change
FROM monthly_region_sales
ORDER BY region, order_month;

# NTILE - splits products into 4 equal groups by profit
SELECT
    product_name,
    ROUND(SUM(gross_profit),2) AS total_profit,
    NTILE(4) OVER (ORDER BY SUM(gross_profit) DESC) AS profit_quartile
FROM orders
GROUP BY product_name
ORDER BY total_profit DESC;


# ---------- views and temp tables ----------

# a view is a saved query you can reuse like a table
CREATE OR REPLACE VIEW vw_factory_summary AS
SELECT
    m.factory_name,
    COUNT(*) AS total_orders,
    ROUND(SUM(o.sales),2) AS total_sales,
    ROUND(SUM(o.gross_profit)/SUM(o.sales)*100,2) AS margin_pct
FROM orders o
JOIN product_factory_map m ON o.product_name = m.product_name
GROUP BY m.factory_name;

SELECT * FROM vw_factory_summary ORDER BY total_sales DESC;

# temp table only exists for this session
CREATE TEMPORARY TABLE temp_high_value_orders AS
SELECT order_id, product_name, sales, gross_profit
FROM orders
WHERE sales > 1000;

SELECT COUNT(*) FROM temp_high_value_orders;


# ---------- indexes ----------
# indexes help MySQL find rows faster without scanning the whole table

CREATE INDEX idx_orders_region ON orders(region);
CREATE INDEX idx_orders_product_name ON orders(product_name);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

SHOW INDEX FROM orders;


# ---------- stored procedure, function, trigger ----------

DELIMITER $$

# procedure - reusable block that returns sales info for one factory
CREATE PROCEDURE sp_factory_sales_summary(IN p_factory_name VARCHAR(50))
BEGIN
    SELECT
        m.factory_name,
        COUNT(*) AS total_orders,
        ROUND(SUM(o.sales),2) AS total_sales,
        ROUND(SUM(o.gross_profit),2) AS total_profit
    FROM orders o
    JOIN product_factory_map m ON o.product_name = m.product_name
    WHERE m.factory_name = p_factory_name
    GROUP BY m.factory_name;
END$$

# function - takes a value in, returns a value out
CREATE FUNCTION fn_sales_tier(p_sales DOUBLE) RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE tier VARCHAR(10);
    IF p_sales >= 1000 THEN SET tier = 'High';
    ELSEIF p_sales >= 300 THEN SET tier = 'Medium';
    ELSE SET tier = 'Low';
    END IF;
    RETURN tier;
END$$

# trigger - runs automatically before a new order is inserted
CREATE TRIGGER trg_orders_before_insert
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.sales IS NOT NULL AND NEW.cost IS NOT NULL THEN
        SET NEW.gross_profit = NEW.sales - NEW.cost;
    END IF;
END$$

DELIMITER ;

# using the procedure
CALL sp_factory_sales_summary("Lot's O' Nuts");

# using the function
SELECT product_name, sales, fn_sales_tier(sales) AS tier FROM orders LIMIT 10;

# testing the trigger - gross_profit is left out, trigger should fill it in
INSERT INTO orders (row_id, order_id, order_date, ship_date, ship_mode,
    customer_id, country_region, city, state_province, postal_code,
    division, region, product_id, product_name, sales, units, cost)
VALUES (99998, 'TEST-002', '01-01-2024', '05-01-2024', 'Standard Class',
    NULL, 'United States', 'Test City', 'Test State', 10001,
    'Sugar', 'Pacific', 'PROD-006', 'Nerds', 30.00, 5, 20.00);

SELECT * FROM orders WHERE row_id = 99998;
DELETE FROM orders WHERE row_id = 99998;


# ---------- transactions ----------
# a transaction lets you undo a group of changes if needed

START TRANSACTION;

UPDATE orders SET gross_profit = gross_profit * 1.0 WHERE region = 'Gulf';
SELECT COUNT(*) FROM orders WHERE region = 'Gulf';

ROLLBACK;


# ---------- reading an execution plan ----------
# EXPLAIN shows how MySQL plans to run a query

EXPLAIN SELECT * FROM orders WHERE region = 'Pacific' AND sales > 500;

EXPLAIN SELECT m.factory_name, COUNT(*)
FROM orders o
JOIN product_factory_map m ON o.product_name = m.product_name
GROUP BY m.factory_name;
