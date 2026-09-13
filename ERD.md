# Entity-Relationship Diagram

```mermaid
erDiagram
    factories ||--o{ product_factory_map : "manufactures"
    product_factory_map ||--o{ orders : "product maps to factory"
    customers ||--o{ orders : "places"

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

    customers {
        int customer_id PK
        varchar city
        varchar state_province
        varchar country_region
        int postal_code
    }

    orders {
        int row_id PK
        text order_id
        text order_date
        text ship_date
        text ship_mode
        int customer_id FK
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
- `customers` is normalized out of `orders` — each customer's city/state/
  country is stored once instead of repeated on every order row.
- `orders.customer_id` is a foreign key to `customers`, with `ON DELETE
  SET NULL` — if a customer record is removed, their past orders remain
  but the link is cleared rather than the order being deleted.
- `Ship Date` is present in `orders` but excluded from analysis — see the
  Data Quality Note in the README for why.
