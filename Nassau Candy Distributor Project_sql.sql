CREATE DATABASE nassau_candy_distributor;
USE nassau_candy_distributor;
 SHOW TABLES;
 RENAME TABLE `nassau _candy_distributor` TO orders;
  SELECT COUNT(*) FROM orders;
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
  SELECT `order_date`, `ship_date` FROM orders LIMIT 5;
  SELECT DATEDIFF(STR_TO_DATE(ship_date,'%d-%m-%Y'), STR_TO_DATE(order_date,'%d-%m-%Y')) AS gap_days, COUNT(*) FROM orders GROUP BY gap_days ORDER BY COUNT(*) DESC LIMIT 20; 
 CREATE TABLE factories ( factory_id INT PRIMARY KEY AUTO_INCREMENT, factory_name VARCHAR(50) NOT NULL UNIQUE, latitude DECIMAL(9,6) NOT NULL, longitude DECIMAL(9,6) NOT NULL );
 INSERT INTO factories (factory_name, latitude, longitude) VALUES ("Lot's O' Nuts", 32.881893, -111.768036), ("Wicked Choccy's", 32.076176, -81.088371), ('Sugar Shack', 48.11914, -96.18115), ('Secret Factory', 41.446333, -90.565487), ('The Other Factory', 35.1175, -89.971107);
  SELECT * FROM factories;
   CREATE TABLE product_factory_map ( product_name VARCHAR(100) PRIMARY KEY, division VARCHAR(20) NOT NULL, factory_name VARCHAR(50) NOT NULL, FOREIGN KEY (factory_name) REFERENCES factories(factory_name) );
    INSERT INTO product_factory_map (division, product_name, factory_name) VALUES ('Chocolate', 'Wonka Bar - Nutty Crunch Surprise', "Lot's O' Nuts"), ('Chocolate', 'Wonka Bar - Fudge Mallows', "Lot's O' Nuts"), ('Chocolate', 'Wonka Bar -Scrumdiddlyumptious', "Lot's O' Nuts"), ('Chocolate', 'Wonka Bar - Milk Chocolate', "Wicked Choccy's"), ('Chocolate', 'Wonka Bar - Triple Dazzle Caramel', "Wicked Choccy's"), ('Sugar', 'Laffy Taffy', 'Sugar Shack'), ('Sugar', 'SweeTARTS', 'Sugar Shack'), ('Sugar', 'Nerds', 'Sugar Shack'), ('Sugar', 'Fun Dip', 'Sugar Shack'), ('Other', 'Fizzy Lifting Drinks', 'Sugar Shack'), ('Sugar', 'Everlasting Gobstopper', 'Secret Factory'), ('Sugar', 'Hair Toffee', 'The Other Factory'), ('Other', 'Lickable Wallpaper', 'Secret Factory'), ('Other', 'Wonka Gum', 'Secret Factory'), ('Other', 'Kazookles', 'The Other Factory');
 SELECT COUNT(*) FROM product_factory_map; 
  SELECT DISTINCT o.product_name
  FROM orders o
  LEFT JOIN product_factory_map m ON o.product_name = m.product_name 
  WHERE m.product_name IS NULL;
  
  #EDA queries — real business insights from Sales/Profit/Region/Division/Ship Mode.
  
  #Overall business snapshot
SELECT COUNT(DISTINCT order_id) AS total_orders,
 COUNT(*) AS total_line_items, SUM(units) AS total_units, ROUND(SUM(sales),2) AS total_sales, ROUND(SUM(gross_profit),2) AS total_gross_profit, ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS gross_margin_pct 
 FROM orders;
 
 #Sales & profit by factory (via the mapping table)
SELECT m.factory_name, COUNT(*) AS line_items, ROUND(SUM(o.sales),2) AS total_sales, ROUND(SUM(o.gross_profit),2) AS total_gross_profit, ROUND(SUM(o.gross_profit)/SUM(o.sales)*100,2) AS margin_pct 
FROM orders o 
JOIN product_factory_map m ON o.product_name = m.product_name 
GROUP BY m.factory_name 
ORDER BY total_sales DESC;

#Sales & profit by region
SELECT region, COUNT(*) AS line_items, ROUND(SUM(sales),2) AS total_sales, ROUND(SUM(gross_profit),2) AS total_gross_profit, ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS margin_pct 
FROM orders 
GROUP BY region 
ORDER BY total_sales DESC;

#Sales & profit by division
SELECT division, COUNT(*) AS line_items, ROUND(SUM(sales),2) AS total_sales, ROUND(SUM(gross_profit),2) AS total_gross_profit, ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS margin_pct
 FROM orders 
 GROUP BY division 
 ORDER BY total_sales DESC;
 
 #Performance by ship mode
SELECT ship_mode, COUNT(*) AS line_items, ROUND(AVG(sales),2) AS avg_sales, ROUND(AVG(gross_profit),2) AS avg_gross_profit 
FROM orders 
GROUP BY ship_mode 
ORDER BY avg_sales DESC;

#Top 10 products by gross profit
SELECT product_name, division, ROUND(SUM(gross_profit),2) AS total_gross_profit, ROUND(SUM(gross_profit)/SUM(sales)*100,2) AS margin_pct 
FROM orders 
GROUP BY product_name, division
ORDER BY total_gross_profit DESC LIMIT 10;

#Top 10 states by sales
SELECT state_province, COUNT(*) AS orders, ROUND(SUM(sales),2) AS total_sales 
FROM orders 
GROUP BY state_province 
ORDER BY total_sales DESC LIMIT 10;


#Create region_centroids table
CREATE TABLE region_centroids ( region VARCHAR(20) PRIMARY KEY, latitude DECIMAL(9,6), longitude DECIMAL(9,6) );
INSERT INTO region_centroids VALUES ('Interior', 41.9, -93.0), ('Atlantic', 40.7, -76.0), ('Gulf', 29.9, -90.0), ('Pacific', 37.0, -120.5); 
#(These are approximate US regional centers matching your 4 Region values: Interior, Atlantic, Gulf, Pacific.)

#Create the distance view (haversine formula)
CREATE VIEW vw_factory_region_distance AS SELECT f.factory_name AS factory, r.region, ROUND( 3958.8 * ACOS( COS(RADIANS(f.latitude)) * COS(RADIANS(r.latitude)) * COS(RADIANS(r.longitude) - RADIANS(f.longitude)) + SIN(RADIANS(f.latitude)) * SIN(RADIANS(r.latitude)) ), 1 ) AS distance_miles FROM factories f CROSS JOIN region_centroids r; 
SELECT * FROM vw_factory_region_distance ORDER BY factory, region;
#see 5 factories × 4 regions = 20 rows, all positive distances in the hundreds/thousands of miles.

#Add and populate estimated_lead_time_days
ALTER TABLE orders ADD COLUMN estimated_lead_time_days DECIMAL(4,1); 
UPDATE orders o JOIN product_factory_map m ON o.product_name = m.product_name JOIN vw_factory_region_distance d ON d.factory = m.factory_name AND d.region = o.region SET o.estimated_lead_time_days = ROUND( CASE o.ship_mode WHEN 'Standard Class' THEN 5 WHEN 'Second Class' THEN 3 WHEN 'First Class' THEN 2 WHEN 'Same Day' THEN 1 END + d.distance_miles/700, 1 );
 
 SELECT ship_mode, ROUND(AVG(estimated_lead_time_days),2) AS avg_lead_time, MIN(estimated_lead_time_days), MAX(estimated_lead_time_days) FROM orders GROUP BY ship_mode;
 
 #Factory x Region performance matrix
SELECT 
    m.factory_name, 
    o.region, 
    COUNT(*) AS orders, 
    ROUND(AVG(o.estimated_lead_time_days), 2) AS avg_lead_time, 
    ROUND(AVG(o.gross_profit / o.sales) * 100, 2) AS avg_margin_pct
FROM orders o 
JOIN product_factory_map m ON o.product_name = m.product_name 
GROUP BY m.factory_name, o.region 
ORDER BY avg_lead_time DESC;


#Statistically slow routes (CTE)
WITH route_stats AS (
    SELECT m.factory_name, o.region, 
           AVG(o.estimated_lead_time_days) AS avg_lt, 
           COUNT(*) AS n
    FROM orders o 
    JOIN product_factory_map m ON o.product_name = m.product_name
    GROUP BY m.factory_name, o.region
),
overall AS (
    SELECT AVG(estimated_lead_time_days) AS mean_lt, 
           SQRT(AVG(estimated_lead_time_days*estimated_lead_time_days) - AVG(estimated_lead_time_days)*AVG(estimated_lead_time_days)) AS std_lt
    FROM orders
)
SELECT r.factory_name, r.region, ROUND(r.avg_lt,2) AS avg_lead_time, r.n AS order_count
FROM route_stats r, overall o
WHERE r.avg_lt > o.mean_lt + o.std_lt
ORDER BY r.avg_lt DESC;

#Margin erosion by distance band
SELECT CASE WHEN d.distance_miles < 500 THEN '0-500 mi' WHEN d.distance_miles < 1000 THEN '500-1000 mi' WHEN d.distance_miles < 1500 THEN '1000-1500 mi' ELSE '1500+ mi' END AS distance_band, ROUND(AVG(o.gross_profit/o.sales)*100,2) AS avg_margin_pct, COUNT(*) AS orders 
FROM orders o JOIN product_factory_map m ON o.product_name = m.product_name JOIN vw_factory_region_distance d ON d.factory = m.factory_name AND d.region = o.region
 GROUP BY distance_band 
 ORDER BY MIN(d.distance_miles); 
 
 #Product profitability ranked within each factory (RANK window function)
SELECT m.factory_name, o.product_name, ROUND(SUM(o.gross_profit),2) AS total_profit, RANK() OVER (PARTITION BY m.factory_name ORDER BY SUM(o.gross_profit) DESC) AS profit_rank FROM orders o JOIN product_factory_map m ON o.product_name = m.product_name GROUP BY m.factory_name, o.product_name ORDER BY m.factory_name, profit_rank; 

#Create vw_ship_mode_base
CREATE VIEW vw_ship_mode_base AS SELECT ship_mode, CASE ship_mode WHEN 'Standard Class' THEN 5 WHEN 'Second Class' THEN 3 WHEN 'First Class' THEN 2 WHEN 'Same Day' THEN 1 END AS base_days FROM orders GROUP BY ship_mode;

#Create vw_product_region_mix
CREATE VIEW vw_product_region_mix AS SELECT o.product_name, m.factory_name AS current_factory, o.region, COUNT(*) AS order_count, ROUND(AVG(o.sales),2) AS avg_sales, ROUND(AVG(o.cost),2) AS avg_cost, ROUND(AVG(o.gross_profit),2) AS avg_profit FROM orders o JOIN product_factory_map m ON o.product_name = m.product_name GROUP BY o.product_name, m.factory_name, o.region; 

#Create vw_scenario_simulation
CREATE VIEW vw_scenario_simulation AS SELECT mix.product_name, mix.current_factory, mix.region, mix.order_count, d.factory AS candidate_factory, d.distance_miles, ROUND(4 + d.distance_miles/700, 2) AS predicted_lead_time FROM vw_product_region_mix mix JOIN vw_factory_region_distance d ON d.region = mix.region; 

#Create vw_reassignment_recommendations (the RANK logic)
CREATE VIEW vw_reassignment_recommendations AS WITH current_perf AS ( SELECT product_name, current_factory, AVG(order_count) AS n, SUM(order_count * (4 + (SELECT distance_miles FROM vw_factory_region_distance d WHERE d.factory = current_factory AND d.region = region))) / SUM(order_count) AS current_lead_time FROM vw_product_region_mix GROUP BY product_name, current_factory ), scenario_agg AS ( SELECT product_name, candidate_factory, SUM(order_count) AS total_orders, ROUND(SUM(predicted_lead_time * order_count) / SUM(order_count), 2) AS weighted_predicted_lead_time FROM vw_scenario_simulation GROUP BY product_name, candidate_factory ) SELECT s.product_name, c.current_factory, ROUND(c.current_lead_time,2) AS current_lead_time, s.candidate_factory, s.weighted_predicted_lead_time AS candidate_lead_time, ROUND(c.current_lead_time - s.weighted_predicted_lead_time, 2) AS improvement_days, RANK() OVER (PARTITION BY s.product_name ORDER BY (c.current_lead_time - s.weighted_predicted_lead_time) DESC) AS rec_rank FROM scenario_agg s JOIN current_perf c ON c.product_name = s.product_name WHERE s.candidate_factory <> c.current_factory;

#Run the final recommendation query
#This is your project's headline output — a ranked list of 'move Product X from Factory A to Factory B, save Y days' recommendations.
SELECT product_name, current_factory, current_lead_time, candidate_factory AS recommended_factory, candidate_lead_time, improvement_days FROM vw_reassignment_recommendations WHERE rec_rank = 1 AND improvement_days > 0 ORDER BY improvement_days DESC; 

SELECT factory_name, COUNT(*) FROM factories GROUP BY factory_name HAVING COUNT(*) > 1;
SELECT region, COUNT(*) FROM region_centroids GROUP BY region HAVING COUNT(*) > 1;

DROP VIEW IF EXISTS vw_reassignment_recommendations;

CREATE VIEW vw_reassignment_recommendations AS
WITH current_perf AS (
    SELECT 
        mix.product_name, 
        mix.current_factory,
        SUM(mix.order_count * (4 + d.distance_miles/700)) / SUM(mix.order_count) AS current_lead_time
    FROM vw_product_region_mix mix
    JOIN vw_factory_region_distance d 
        ON d.factory = mix.current_factory AND d.region = mix.region
    GROUP BY mix.product_name, mix.current_factory
),
scenario_agg AS (
    SELECT product_name, candidate_factory,
           SUM(order_count) AS total_orders,
           ROUND(SUM(predicted_lead_time * order_count) / SUM(order_count), 2) AS weighted_predicted_lead_time
    FROM vw_scenario_simulation
    GROUP BY product_name, candidate_factory
)
SELECT
    s.product_name,
    c.current_factory,
    ROUND(c.current_lead_time, 2) AS current_lead_time,
    s.candidate_factory,
    s.weighted_predicted_lead_time AS candidate_lead_time,
    ROUND(c.current_lead_time - s.weighted_predicted_lead_time, 2) AS improvement_days,
    RANK() OVER (PARTITION BY s.product_name ORDER BY (c.current_lead_time - s.weighted_predicted_lead_time) DESC) AS rec_rank
FROM scenario_agg s
JOIN current_perf c ON c.product_name = s.product_name
WHERE s.candidate_factory <> c.current_factory;

