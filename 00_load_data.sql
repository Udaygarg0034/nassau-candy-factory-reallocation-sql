-- ============================================================
-- Nassau Candy Distributor — Data Load Script (MySQL)
-- Run 01_schema.sql first, then this script.
-- Adjust the file paths to match your local machine / server,
-- and ensure `secure_file_priv` / local_infile settings allow it.
-- ============================================================

-- Load factories
LOAD DATA LOCAL INFILE 'data/factories.csv'
INTO TABLE factories
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(factory_name, latitude, longitude);

-- Load products
LOAD DATA LOCAL INFILE 'data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(division, product_name, current_factory, product_id);

-- Load orders (fact table)
LOAD DATA LOCAL INFILE 'data/nassau_candy_orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(row_id, order_id, order_date, ship_date, ship_mode, customer_id,
 country_region, city, state_province, postal_code, division, region,
 product_id, product_name, factory, sales, units, cost, gross_profit,
 lead_time_days, distance_miles);

-- Sanity check
SELECT
    (SELECT COUNT(*) FROM factories) AS factories,
    (SELECT COUNT(*) FROM products)  AS products,
    (SELECT COUNT(*) FROM orders)    AS orders;
