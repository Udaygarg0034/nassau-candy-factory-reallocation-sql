# Entity-Relationship Diagram

```mermaid
erDiagram
    factories ||--o{ product_factory_map : "manufactures"
    product_factory_map ||--o{ orders : "product maps to factory"

    factories {
        int factory_id PK
        varchar factory_name UK
        decimal latitude
        decimal longitude
    }

    product_factory_map {
        varchar product_name PK
        varchar division
        varchar factory_name FK
    }

    orders {
        int row_id PK
        text order_id
        text order_date
        text ship_date
        text ship_mode
        int customer_id
        text country_region
        text city
        text state_province
        int postal_code
        text division
        text region
        text product_id
        text product_name FK
        double sales
        int units
        double gross_profit
        double cost
    }
```

**Design notes**
- `orders` is the fact table (9,994 rows) — the real Nassau Candy dataset,
  imported via MySQL Workbench's Table Data Import Wizard.
- `factories` and `product_factory_map` are reference tables built manually
  from the business brief, since factory and product-to-factory mapping
  data don't exist in the source CSV.
- `Ship Date` is present in `orders` but excluded from analysis — see the
  Data Quality Note in the README for why.
