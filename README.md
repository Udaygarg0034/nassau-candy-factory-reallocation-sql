# 🍬 Nassau Candy Distributor — Factory Reallocation & Shipping Optimization (SQL Project)

> Inspired by [Nassau Candy](https://www.nassaucandy.com/), a real confectionery
> distributor. The dataset and business scenario used here are for educational/
> portfolio purposes and are not affiliated with or endorsed by the company.

A SQL-based decision-intelligence project analyzing shipping and profitability
inefficiency at Nassau Candy, culminating in a rule-based factory reassignment
recommendation engine built entirely with SQL views and window functions.

## Problem Statement

Nassau Candy assigns products to factories using static, legacy rules with no
visibility into shipping efficiency or profitability impact. This project
analyzes 9,994 order records to identify inefficient factory-region pairings
and simulates alternative factory assignments using a SQL-based recommendation
engine, moving the business from descriptive reporting to prescriptive
decision-making.

## Project Structure

nassau-candy-sql-project/
├── README.md
├── data/
│ └── Nassau_Candy_Distributor__2_.csv
├── sql/
│ └── full_project.sql
└── docs/
└── ERD.md


## Schema

See `docs/ERD.md` for the full entity-relationship diagram.

- **`orders`** — fact table, 9,994 real order line items
- **`factories`** — 5 manufacturing sites with coordinates (built manually
  from the case study brief; not present in the source CSV)
- **`product_factory_map`** — maps each of the 15 SKUs to its factory
- **`region_centroids`** — approximate lat/long for the dataset's 4 regions
  (Interior, Atlantic, Gulf, Pacific)

## Data Limitation Note

The source data's `Ship Date` field does not reflect genuine shipping lead
time. Gap analysis (`DATEDIFF(ship_date, order_date)`) showed the difference
clustering around **908, 1,273, and 1,639 days** — offsets roughly 365 days
apart — indicating `Ship Date` was generated independently of `Order Date`
rather than representing real fulfillment timing. Rather than fabricate a
correction, `estimated_lead_time_days` was modeled instead, using ship-mode
base days (Standard=5, Second=3, First=2, Same Day=1) plus a haversine-distance
penalty from factory to customer region.

## Key Findings

- **Lot's O' Nuts dominates revenue**: $74,935 total sales and $51,802 gross
  profit (69.1% margin) — driven by high Chocolate division volume
- **The Other Factory and Sugar Shack are under-utilized**: only $1,282 and
  $221 in total sales respectively, a stark volume imbalance across the
  5-factory network
- **Pacific is the top-performing region** ($45,451 sales, 65.9% margin),
  while **Gulf is smallest** at $22,247
- **Margin does not erode with distance** in this dataset — 0-500mi routes
  show the *lowest* margin (36.7%), while 1000-1500mi shows the *highest*
  (69.0%), contradicting the case study's stated premise
- **Recommendation engine's top opportunity**: reassigning **Nerds** from
  Sugar Shack → Wicked Choccy's shows the largest predicted lead-time
  improvement (0.65 days), followed by **Fun Dip** and three Wonka Bar
  chocolate SKUs

## Recommendation Summary

The simulation identifies **Secret Factory** as the most common reassignment
target, receiving 6 of 12 flagged recommendations — suggesting it is
currently under-leveraged relative to its central shipping position. Since
margin doesn't correlate with distance in this dataset, reassignment
decisions should prioritize lead-time gains rather than assuming a
profitability upside.

## Skills Demonstrated

`DDL & schema design` · `foreign keys` · `CTEs` · `window functions (RANK)` ·
`views as a modeling layer` · `statistical outlier detection in SQL` ·
`haversine geodistance in SQL` · `what-if scenario simulation` ·
`data quality investigation` · `business KPI design`

## How to Run

1. `CREATE DATABASE nassau_candy_distributor;`
2. Import `data/Nassau_Candy_Distributor__2_.csv` via MySQL Workbench's
   Table Data Import Wizard, creating a table named `orders`.
3. Run `sql/full_project.sql` for the rest — reference tables, EDA,
   diagnostics, and the recommendation engine.

   ---

Built by Uday Garg — submitted as a portfolio project for Imarticus Learning's PG Program in Data Science & Analytics.
