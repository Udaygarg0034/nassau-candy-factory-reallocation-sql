# 🍬 Nassau Candy Distributor — SQL Capstone Project

![SQL](https://img.shields.io/badge/SQL-MySQL%208.0-4479A1?logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/status-complete-brightgreen)

> Inspired by [Nassau Candy](https://www.nassaucandy.com/), a real confectionery
> distributor. The dataset and business scenario used here are for educational/
> portfolio purposes and are not affiliated with or endorsed by the company.

A SQL capstone project analyzing sales, profitability, and product-factory
performance for a candy distributor — covering the full breadth of core SQL:
DDL, DML, constraints, all JOIN types, subqueries, set operations, CASE logic,
CTEs, window functions, views, indexes, stored procedures, functions,
triggers, and transactions.

---

## 📌 Problem Statement

Nassau Candy assigns products to factories with no structured way to analyze
sales performance, profitability, or product-level trends across its
network. This project builds a relational schema from a real **9,994-row**
order dataset and answers a series of business questions using SQL.

---

## 📁 Project Structure
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
| **`orders`** | Fact table — 9,994 real order line items |
| **`factories`** | 5 manufacturing sites |
| **`product_factory_map`** | Maps each of the 15 SKUs to its factory |
| **`customers`** | Customer profiles normalized out of `orders` |

---

## 🔍 Data Quality Note

The source data's `Ship Date` field does not reflect genuine shipping lead
time — a `DATEDIFF` gap-analysis showed the difference between `Ship Date`
and `Order Date` clustering around **908, 1,273, and 1,639 days**, roughly
365 days apart. This is documented in the SQL file and the field is
excluded from analysis.

---

## ✅ What's Covered

| Area | Concepts |
|---|---|
| Schema & Constraints | DDL, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`, foreign keys with `ON DELETE`/`ON UPDATE` actions |
| Table Management | `ALTER`, `RENAME`, `DROP`, `TRUNCATE` |
| Data Manipulation | `INSERT`, `UPDATE`, `DELETE` |
| Filtering | `WHERE`, `IN`, `BETWEEN`, `LIKE`, `NOT` |
| Aggregation | `GROUP BY`, `HAVING`, aggregate functions |
| Joins | `INNER`, `LEFT`, `RIGHT`, `CROSS`, self join, 3-table join |
| Subqueries | Correlated, non-correlated, `IN`, `EXISTS` |
| Set Operations | `UNION`, `UNION ALL` |
| Functions | String, date, numeric, `NULL` handling |
| Logic | `CASE` — statement and expression |
| CTEs | Statistical outlier detection, running totals |
| Window Functions | `RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `NTILE` |
| Views & Temp Tables | Reusable summary view, session-scoped temp table |
| Indexes | Created on frequently filtered columns |
| Stored Routines | A stored procedure, a function, and a trigger |
| Transactions | `START TRANSACTION`, `ROLLBACK` |
| Query Planning | `EXPLAIN` on two real queries |

---

## 💡 Key Findings

- 🏆 **Lot's O' Nuts dominates revenue** — $74,935 total sales, 69.1% margin
- 📉 **The Other Factory and Sugar Shack are under-utilized** — under $1,600 combined in sales
- 🌎 **Pacific is the top-performing region** ($45,451 sales); **Gulf is smallest** ($22,247)
- 📊 The CTE-based outlier query flags factory-region pairs whose margin
  falls more than one standard deviation below the network average

---

## 🛠️ Skills Demonstrated

`DDL & Schema Design` · `Constraints` · `DML` · `All Join Types` ·
`Correlated & Non-Correlated Subqueries` · `Set Operations` ·
`CASE Expressions` · `CTEs` · `Window Functions` · `Views` · `Indexes` ·
`Stored Procedures, Functions & Triggers` · `Transactions` · `EXPLAIN` ·
`Data Quality Investigation` · `Normalization`

---

## ▶️ How to Run

1. `CREATE DATABASE nassau_candy_distributor;`
2. Import `data/Nassau_Candy_Distributor.csv` via MySQL Workbench's Table
   Data Import Wizard, creating a table named `orders`.
3. Run `sql/Nassau_Candy_Distributor_Project.sql` section by section.

---

*Built by **Uday Garg** — submitted as a portfolio project for Imarticus Learning's PG Program in Data Science & Analytics.*
