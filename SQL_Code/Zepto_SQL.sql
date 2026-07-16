/*
=============================================================
Zepto Inventory & Pricing — SQL Exploratory Data Analysis
=============================================================
*/

DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);

/*
=============================================================
1. Data Exploration
=============================================================
*/

-- Total number of rows
SELECT COUNT(*) FROM zepto;

-- Sample data
SELECT * FROM zepto
LIMIT 10;

-- Null values check
SELECT * FROM zepto
WHERE name IS NULL
OR category IS NULL
OR mrp IS NULL
OR discountPercent IS NULL
OR discountedSellingPrice IS NULL
OR weightInGms IS NULL
OR availableQuantity IS NULL
OR outOfStock IS NULL
OR quantity IS NULL;

-- Distinct product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- Products in stock vs out of stock
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

-- Product names appearing multiple times (different SKUs/variants)
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

/*
=============================================================
2. Data Cleaning
=============================================================
*/

-- Products with price = 0 (likely invalid/placeholder entries)
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;

-- Convert paise to rupees
UPDATE zepto
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

SELECT mrp, discountedSellingPrice FROM zepto;

/*
=============================================================
3. Business Analysis
=============================================================
*/

-- Q1. How many categories exist, and how many SKUs does each contain?
-- (Understand catalog composition before analyzing performance.)
SELECT category,
COUNT(sku_id) AS total_skus
FROM zepto
GROUP BY category
ORDER BY total_skus DESC;

-- Q2. What is the overall out-of-stock rate, and which categories are hit hardest?
-- (Stockouts directly translate to lost sales opportunity.)
SELECT category,
COUNT(*) AS total_skus,
SUM(CASE WHEN outOfStock THEN 1 ELSE 0 END) AS out_of_stock_skus,
ROUND(SUM(CASE WHEN outOfStock THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS out_of_stock_rate_percent
FROM zepto
GROUP BY category
ORDER BY out_of_stock_rate_percent DESC;

-- Q3. What are the top 10 best-value products based on discount percentage?
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q4. Which high-MRP products are currently out of stock?
-- (High-value items going unsold represent the biggest revenue risk.)
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE AND mrp > 300
ORDER BY mrp DESC;

-- Q5. What is the estimated revenue for each category?
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- Q6. How much potential revenue is being lost to out-of-stock items?
-- (Estimated using MRP and quantity as a stand-in for expected demand.)
SELECT category,
SUM(mrp * quantity) AS estimated_lost_revenue
FROM zepto
WHERE outOfStock = TRUE
GROUP BY category
ORDER BY estimated_lost_revenue DESC;

-- Q7. Which products have MRP greater than ₹500 but a discount under 10%?
-- (Low discounting on premium items — potential pricing strategy insight.)
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q8. Which are the top 5 categories offering the highest average discount percentage?
SELECT category,
ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q9. Is there a relationship between discount percentage and stock availability?
-- (Do heavily discounted items tend to sell out faster, or sit unsold?)
SELECT
CASE
    WHEN discountPercent < 10 THEN '0-10%'
    WHEN discountPercent < 20 THEN '10-20%'
    WHEN discountPercent < 30 THEN '20-30%'
    ELSE '30%+'
END AS discount_band,
COUNT(*) AS total_skus,
SUM(CASE WHEN outOfStock THEN 1 ELSE 0 END) AS out_of_stock_skus,
ROUND(SUM(CASE WHEN outOfStock THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS out_of_stock_rate_percent
FROM zepto
GROUP BY discount_band
ORDER BY discount_band;

-- Q10. What is the price per gram for products above 100g, sorted by best value?
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q11. How does average price per gram compare across categories?
-- (Identifies which categories carry a value premium vs. budget-friendly categories.)
SELECT category,
ROUND(AVG(discountedSellingPrice / NULLIF(weightInGms, 0)), 2) AS avg_price_per_gram
FROM zepto
WHERE weightInGms > 0
GROUP BY category
ORDER BY avg_price_per_gram DESC;

-- Q12. How are products distributed across weight categories: Low, Medium, Bulk?
SELECT
CASE WHEN weightInGms < 1000 THEN 'Low'
    WHEN weightInGms < 5000 THEN 'Medium'
    ELSE 'Bulk'
END AS weight_category,
COUNT(DISTINCT name) AS total_products
FROM zepto
GROUP BY weight_category
ORDER BY total_products DESC;

-- Q13. What is the total inventory weight per category?
-- (Useful for logistics/warehousing load estimation.)
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight DESC;

-- Q14. Which products have the largest gap between MRP and discounted price in absolute terms?
-- (Highlights the biggest "flagship deal" items likely to attract attention.)
SELECT DISTINCT name, mrp, discountedSellingPrice,
ROUND(mrp - discountedSellingPrice, 2) AS absolute_savings
FROM zepto
ORDER BY absolute_savings DESC
LIMIT 10;

-- Q15. Which categories have zero available quantity across all their SKUs (fully depleted)?
-- (Flags categories needing urgent restocking attention.)
SELECT category,
COUNT(*) AS total_skus,
SUM(availableQuantity) AS total_available_quantity
FROM zepto
GROUP BY category
HAVING SUM(availableQuantity) = 0;
