# Zepto-Sales-Data-Analysis-using-SQL

## Project Overview
This project analyzes product-level data from Zepto (a quick-commerce grocery platform) using SQL to uncover insights around inventory availability, pricing strategy, discounting patterns, and category-level performance. The analysis approaches the dataset the way a business analyst would evaluate any retail/e-commerce catalog — focusing on stock risk, revenue drivers, and pricing efficiency.

## Business Objective
Quick-commerce platforms operate on thin margins and fast-moving inventory, so understanding pricing and stock dynamics at the SKU level is critical. This analysis aims to answer:

- Which categories and products drive the most estimated revenue?
- Where is out-of-stock risk concentrated, and what revenue is being lost to it?
- Are discounts being applied strategically, or randomly across price points?
- Which products offer the best value per unit of weight?
- How is inventory distributed across categories in terms of both count and weight?

## Dataset
The dataset (`zepto_v2.csv`) contains SKU-level product data with the following fields:

| Column | Description |
|---|---|
| `sku_id` | Unique identifier for each SKU |
| `category` | Product category |
| `name` | Product name |
| `mrp` | Maximum Retail Price (converted from paise to rupees) |
| `discountPercent` | Discount applied to the product |
| `availableQuantity` | Quantity currently available |
| `discountedSellingPrice` | Price after discount |
| `weightInGms` | Product weight in grams |
| `outOfStock` | Stock status (boolean) |
| `quantity` | Order/pack quantity |

## Project Structure
The analysis is organized in `Zepto_SQL_data_analysis.sql` as a single sequential script, structured in three stages:

| Section | Purpose |
|---|---|
| **Data Exploration** | Row counts, sample records, null checks, category list, stock status split, duplicate product names |
| **Data Cleaning** | Removing invalid ₹0 price entries, converting price fields from paise to rupees |
| **Business Analysis (Q1–Q15)** | Category composition, stock-risk analysis, revenue estimation, discount strategy, price-per-gram value, and inventory/logistics distribution |

## Methodology
1. **Setup** — create the table schema matching the raw dataset structure.
2. **Validation** — check for missing values and invalid (zero-price) records before analysis.
3. **Cleaning** — remove invalid rows and normalize currency units.
4. **Exploration** — understand category composition, product duplication, and stock status at a glance.
5. **Analysis** — move from descriptive questions (top discounts, category revenue) to more diagnostic ones (lost revenue from stockouts, discount-vs-availability relationship, price-per-gram value comparisons).

## Key Business Questions Answered
- **Catalog Composition**: How many SKUs exist per category?
- **Stock Risk**: Which categories have the highest out-of-stock rates, and how much estimated revenue is lost as a result?
- **Revenue Drivers**: Which categories and products generate the most estimated revenue?
- **Pricing Strategy**: Are premium products (MRP > ₹500) under-discounted? Do certain categories get discounted more aggressively than others?
- **Value Analysis**: Which products offer the best price-per-gram value, and how does this vary by category?
- **Inventory Planning**: How is total inventory weight distributed across categories, and which categories are fully depleted?

## Tools Used
- **SQL** (PostgreSQL syntax) for schema creation, data cleaning, and analysis

## How to Run
1. Load `zepto_v2.csv` into a PostgreSQL database (matching the `zepto` table schema defined at the top of the script).
2. Run `Zepto_SQL_data_analysis.sql` top to bottom — the cleaning steps must run before the analysis queries, since later queries depend on the corrected currency values and removed invalid rows.
3. Review each query's output alongside its inline comment to follow the analysis narrative.

## Notes
- Prices in the raw dataset are stored in **paise** and converted to **rupees** during cleaning (divide by 100).
- Rows with `mrp = 0` are treated as invalid/placeholder entries and removed before analysis.
- `NULLIF` is used when calculating price-per-gram to avoid division-by-zero errors for products with no recorded weight.
