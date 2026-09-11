# 🍬 Nassau Candy Distributor — SQL Capstone Project

![SQL](https://img.shields.io/badge/SQL-MySQL%208.0-4479A1?logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/status-complete-brightgreen)
![License](https://img.shields.io/badge/license-educational-lightgrey)

> Inspired by [Nassau Candy](https://www.nassaucandy.com/), a real confectionery
> distributor. The dataset and business scenario used here are for educational/
> portfolio purposes and are not affiliated with or endorsed by the company.

A SQL capstone project analyzing sales, profitability, and product-factory
performance for a candy distributor — covering the full breadth of core SQL:
**DDL, DML, joins, subqueries, set operations, CASE logic, CTEs, window
functions, and views.**

---

## 📌 Problem Statement

Nassau Candy assigns products to factories with no structured way to analyze
sales performance, profitability, or product-level trends across its
network. This project builds a relational schema from a real **9,994-row**
order dataset and answers a series of business questions using SQL — from
basic filtering to window functions and CTE-based outlier detection.
nassau-candy-sql-project/
├── README.md
├── data/
│ └── Nassau_Candy_Distributor.csv
├── sql/
│ └── Nassau_Candy_Distributor_Project.sql
└── docs/
└── ERD.md


---

## 🗂️ Schema

See [`docs/ERD.md`](docs/ERD.md) for the full entity-relationship diagram.

| Table | Description |
|---|---|
| **`orders`** | Fact table — 9,994 real order line items, imported via MySQL Workbench's Table Data Import Wizard |
| **`factories`** | 5 manufacturing sites (built manually from the business brief; not present in the source CSV) |
| **`product_factory_map`** | Maps each of the 15 SKUs to its factory |

---

## 🔍 Data Quality Note

The source data's `Ship Date` field does **not** reflect genuine shipping
lead time. A `DATEDIFF` gap-analysis (included in the SQL file, Section 2)
showed the difference between `Ship Date` and `Order Date` clustering
around **908, 1,273, and 1,639 days** — offsets roughly 365 days apart —
indicating `Ship Date` was generated independently of `Order Date` rather
than representing real fulfillment timing.

This was documented rather than silently worked around, and the field is
excluded from analysis as a result.

---

## ✅ What's Covered

The SQL file is organized into 13 sections, each demonstrating a core SQL
concept against the real dataset:

| # | Section | Topic |
|---|---|---|
| 1 | Setup | DDL — database/table setup, reference tables, foreign keys |
| 2 | Investigation | Data quality check (`DATEDIFF`, `GROUP BY`) |
| 3 | DML | `INSERT`, `UPDATE`, `DELETE` |
| 4 | Filtering | `SELECT` / `WHERE` with `IN`, `BETWEEN`, `LIKE` |
| 5 | Aggregation | Aggregate functions, `GROUP BY`, `HAVING` |
| 6 | Joins | `INNER JOIN`, `LEFT JOIN` |
| 7 | Subqueries | Correlated vs. non-correlated |
| 8 | Set Ops | `UNION`, `UNION ALL` |
| 9 | Functions | String, date, and numeric functions |
| 10 | Logic | `CASE` — statement and expression |
| 11 | CTEs | Statistical outlier detection (mean − std dev) |
| 12 | Window Fns | `RANK() OVER (PARTITION BY ...)` |
| 13 | Views | Reusable summary view |

---

## 💡 Key Findings

- 🏆 **Lot's O' Nuts dominates revenue** — $74,935 total sales and $51,802
  gross profit (**69.1% margin**), driven by high Chocolate division volume
- 📉 **The Other Factory and Sugar Shack are under-utilized** — only $1,282
  and $221 in total sales respectively, a stark volume imbalance across the
  5-factory network
- 🌎 **Pacific is the top-performing region** ($45,451 sales, 65.9% margin),
  while **Gulf is smallest** at $22,247
- 📊 The CTE-based outlier query (Section 11) flags factory-region pairs
  whose average margin falls more than one standard deviation below the
  network mean — a statistically grounded way to spot underperformers
  rather than eyeballing a sorted list

---

## 🛠️ Skills Demonstrated

`DDL & Schema Design` · `Foreign Keys` · `DML` · `Joins` ·
`Correlated & Non-Correlated Subqueries` · `Set Operations` ·
`String/Date Functions` · `CASE Expressions` · `CTEs` ·
`Window Functions` · `Views` · `Statistical Outlier Detection in SQL` ·
`Data Quality Investigation`

---

## ▶️ How to Run

1. Create the database:
```sql
   CREATE DATABASE nassau_candy_distributor;
```
2. Import `data/Nassau_Candy_Distributor.csv` via MySQL Workbench's Table
   Data Import Wizard, creating a table named `orders`.
3. Run `sql/Nassau_Candy_Distributor_Project.sql` section by section.

---

*Built by **Uday Garg** — submitted as a portfolio project for Imarticus Learning's PG Program in Data Science & Analytics.*

---

## 📁 Project Structure
