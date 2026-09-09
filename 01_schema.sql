-- ============================================================
-- Nassau Candy Distributor: Factory Reallocation & Shipping
-- Optimization Analytics — SQL Schema (DDL)
-- Engine: MySQL 8.0+ (also SQLite-compatible with minor tweaks)
-- ============================================================

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS factories;

-- ------------------------------------------------------------
-- 1. FACTORIES: master list of manufacturing sites
-- ------------------------------------------------------------
CREATE TABLE factories (
    factory_id      INT PRIMARY KEY AUTO_INCREMENT,
    factory_name    VARCHAR(50) NOT NULL UNIQUE,
    latitude        DECIMAL(9,6) NOT NULL,
    longitude       DECIMAL(9,6) NOT NULL
);

-- ------------------------------------------------------------
-- 2. PRODUCTS: product master + current factory assignment
-- ------------------------------------------------------------
CREATE TABLE products (
    product_id       VARCHAR(10) PRIMARY KEY,
    division         VARCHAR(20) NOT NULL,
    product_name     VARCHAR(100) NOT NULL,
    current_factory  VARCHAR(50) NOT NULL,
    FOREIGN KEY (current_factory) REFERENCES factories(factory_name)
);

-- ------------------------------------------------------------
-- 3. ORDERS (fact table): one row per order line item
-- ------------------------------------------------------------
CREATE TABLE orders (
    row_id           INT PRIMARY KEY,
    order_id         VARCHAR(20) NOT NULL,
    order_date       DATE NOT NULL,
    ship_date        DATE NOT NULL,
    ship_mode        VARCHAR(20) NOT NULL,
    customer_id      VARCHAR(15) NOT NULL,
    country_region   VARCHAR(50) NOT NULL,
    city             VARCHAR(50) NOT NULL,
    state_province   VARCHAR(50) NOT NULL,
    postal_code      VARCHAR(10),
    division         VARCHAR(20) NOT NULL,
    region            VARCHAR(20) NOT NULL,
    product_id       VARCHAR(10) NOT NULL,
    product_name     VARCHAR(100) NOT NULL,
    factory          VARCHAR(50) NOT NULL,
    sales            DECIMAL(12,2) NOT NULL,
    units            INT NOT NULL,
    cost             DECIMAL(12,2) NOT NULL,
    gross_profit     DECIMAL(12,2) NOT NULL,
    lead_time_days   INT NOT NULL,
    distance_miles   DECIMAL(10,1) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (factory) REFERENCES factories(factory_name)
);

-- ------------------------------------------------------------
-- Indexes to support the analytical query workload
-- ------------------------------------------------------------
CREATE INDEX idx_orders_region       ON orders(region);
CREATE INDEX idx_orders_factory      ON orders(factory);
CREATE INDEX idx_orders_product      ON orders(product_id);
CREATE INDEX idx_orders_ship_mode    ON orders(ship_mode);
CREATE INDEX idx_orders_order_date   ON orders(order_date);
