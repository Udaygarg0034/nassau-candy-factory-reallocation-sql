# 🍬 Nassau Candy Distributor — SQL Capstone Project

> Inspired by [Nassau Candy](https://www.nassaucandy.com/), a real confectionery
> distributor. The dataset and business scenario used here are for educational/
> portfolio purposes and are not affiliated with or endorsed by the company.

A SQL capstone project analyzing sales, profitability, and product-factory
performance for a candy distributor — covering the full breadth of core SQL:
DDL, DML, joins, subqueries, set operations, CASE logic, CTEs, window
functions, and views.

## Problem Statement

Nassau Candy assigns products to factories with no structured way to analyze
sales performance, profitability, or product-level trends across its
network. This project builds a relational schema from a real 9,994-row order
dataset and answers a series of business questions using SQL — from basic
filtering to window functions and CTE-based outlier detection.

## Project Structure
nassau-candy-sql-project/
├── README.md
├── data/
│ └── Nassau_Candy_Distributor.csv
├── sql/
│ └── Nassau_Candy_Distributor_Project.sql
└── docs/
└── ERD.md


## Schema

See `docs/ERD.md` for the full entity-relationship diagram.

- **`orders`** — fact table, 9,994 real order line items imported via MySQL
  Workbench's Table Data Import Wizard
- **`factories`** — 5 manufacturing sites (built manually from the business
  brief; not present in the source CSV)
- **`product_factory_map`** — maps each of the 15 SKUs to its factory

## Data Quality Note

The source data's `Ship Date` field does not reflect genuine shipping lead
time. A `DATEDIFF` gap-analysis (included in the SQL file, Section 2) showed
the difference between `Ship Date` and `Order Date` clustering around
**908, 1,273, and 1,639 days** — offsets roughly 365 days apart — indicating
`Ship Date` was generated independently of `Order Date` rather than
representing real fulfillment timing. This is documented rather than
silently worked around, and the field is excluded from analysis as a result.

## What's Covered

The SQL file is organized into 13 sections, each demonstrating a core SQL
concept against the real dataset:

| Section | Topic |
|---|---|
| 1 | DDL — database/table setup, reference tables, foreign keys |
| 2 | Data quality investigation (`DATEDIFF`, `GROUP BY`) |
| 3 | DML — `INSERT`, `UPDATE`, `DELETE` |
| 4 | `SELECT` / `WHERE` with `IN`, `BETWEEN`, `LIKE` |
| 5 | Aggregate functions, `GROUP BY`, `HAVING` |
| 6 | `INNER JOIN`, `LEFT JOIN` |
| 7 | Subqueries — correlated vs. non-correlated |
| 8 | Set operations — `UNION`, `UNION ALL` |
| 9 | String, date, and numeric functions |
| 10 | `CASE` — statement and expression |
| 11 | CTEs — statistical outlier detection (mean − std dev) |
| 12 | Window functions — `RANK() OVER (PARTITION BY ...)` |
| 13 | Views |

## Key Findings

- **Lot's O' Nuts dominates revenue**: $74,935 total sales and $51,802 gross
  profit (69.1% margin) — driven by high Chocolate division volume
- **The Other Factory and Sugar Shack are under-utilized**: only $1,282 and
  $221 in total sales respectively — a stark volume imbalance across the
  5-factory network
- **Pacific is the top-performing region** ($45,451 sales, 65.9% margin),
  while **Gulf is smallest** at $22,247
- The CTE-based outlier query (Section 11) flags factory-region pairs
  whose average margin falls more than one standard deviation below the
  network mean — a statistically grounded way to spot underperformers
  rather than eyeballing a sorted list

## Skills Demonstrated

`DDL & schema design` · `foreign keys` · `DML` · `joins` ·
`correlated & non-correlated subqueries` · `set operations` ·
`string/date functions` · `CASE expressions` · `CTEs` ·
`window functions` · `views` · `statistical outlier detection in SQL` ·
`data quality investigation`

## How to Run

1. `CREATE DATABASE nassau_candy_distributor;`
2. Import `data/Nassau_Candy_Distributor.csv` via MySQL Workbench's Table
   Data Import Wizard, creating a table named `orders`.
3. Run `sql/Nassau_Candy_Distributor_Project.sql` section by section.

---

*Built by Uday Garg — submitted as a portfolio project for Imarticus Learning's PG Program in Data Science & Analytics.*

Built by Uday Garg — submitted as a portfolio project for Imarticus Learning's PG Program in Data Science & Analytics.
