# Entity-Relationship Diagram

```mermaid
erDiagram
    FACTORIES ||--o{ PRODUCTS : "manufactures"
    FACTORIES ||--o{ ORDERS : "ships from"
    PRODUCTS ||--o{ ORDERS : "ordered as"

    FACTORIES {
        int factory_id PK
        varchar factory_name UK
        decimal latitude
        decimal longitude
    }

    PRODUCTS {
        varchar product_id PK
        varchar division
        varchar product_name
        varchar current_factory FK
    }

    ORDERS {
        int row_id PK
        varchar order_id
        date order_date
        date ship_date
        varchar ship_mode
        varchar customer_id
        varchar country_region
        varchar city
        varchar state_province
        varchar postal_code
        varchar division
        varchar region
        varchar product_id FK
        varchar product_name
        varchar factory FK
        decimal sales
        int units
        decimal cost
        decimal gross_profit
        int lead_time_days
        decimal distance_miles
    }
```

**Design notes**
- `orders` is the fact table (one row per order line item, ~9,100 rows / 4,500 orders).
- `products` and `factories` are dimension tables; `products.current_factory` captures the
  static "as-is" assignment described in the business problem.
- `lead_time_days` and `distance_miles` are derived columns computed at load time
  (ship_date − order_date; haversine distance from factory to customer region) — this
  is what makes the regression / simulation queries possible without extra joins.
- The optimization engine (`03_optimization_engine.sql`) adds two supporting objects:
  `region_centroids` (reference table) and `vw_factory_region_distance` (a view that
  computes the full factory × region distance matrix used for "what-if" scenarios).
