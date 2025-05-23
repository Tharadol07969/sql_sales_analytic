/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.
    - To explore data in the database to understand and cover insights about our data sets.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Explore All Objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Explore All Columns in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

-- Explore All Columns in dim_customers Table
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-- Explore All Columns in dim_products Table
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products';

-- Explore All Columns in fact_sales Table
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales';

-- Explore all countries our customers are from
SELECT DISTINCT
country
FROM gold.dim_customers;

-- Explore all product categories
SELECT DISTINCT
category,
subcategory,
product_name
FROM gold.dim_products
ORDER BY 1, 2, 3;

-- Explore date
SELECT
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold.fact_sales;

-- Explore age of customers
SELECT 
MIN(birthdate) AS oldest,
MAX(birthdate) AS youngest,
DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;

-- Find the total sales
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) AS total_units_sold
FROM gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) AS avg_price
FROM gold.fact_sales;

-- Find the total number of orders
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-- Find the total number of products
SELECT COUNT(product_name) AS total_products
FROM gold.dim_products;
SELECT COUNT(DISTINCT product_name) AS total_products
FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(customer_id) AS total_customers
FROM gold.dim_customers;

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key)
FROM gold.fact_sales;

-- Generate a Report that shows all key metrics of business
SELECT 'Total Sales' as measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' as measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' as measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Customers' as measure_name, COUNT(customer_id) AS measure_value FROM gold.dim_customers;

-- Find total customers by countries
SELECT
country,
COUNT(customer_key) AS total_customers 
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Find total customers by gender
SELECT
gender,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Find total products by category
SELECT
category,
COUNT(product_key) AS total_product
FROM gold.dim_products
GROUP BY category
ORDER BY total_product DESC;

-- What is the average cost in each category?
SELECT
category,
AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- What is total revenue generated for each category?
SELECT
dp.category,
SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON dp.product_key = fs.product_key
GROUP BY dp.category
ORDER BY total_revenue DESC;

-- Find total revenue is generated by each customer?
SELECT
dc.customer_id,
dc.firstname,
dc.lastname,
SUM(sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_id, dc.firstname, dc.lastname
ORDER BY total_revenue DESC;

-- What is distribution of sold items across countries?
SELECT
dc.country,
SUM(quantity) AS total_sold_items
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.country
ORDER BY total_sold_items DESC;

-- Which 5 products generate the highest revenue?
SELECT *
FROM (
	SELECT
	dp.product_name,
	SUM(fs.sales_amount) AS total_revenue,
	RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_products AS dp
	ON dp.product_key = fs.product_key
	GROUP BY dp.product_name) AS t
WHERE rank_products <= 5;

-- What are the worst-performing products in terms of sales?
SELECT TOP 5
dp.product_name,
SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON dp.product_key = fs.product_key
GROUP BY dp.product_name
ORDER BY total_revenue;

-- Find the top 10 customers who have generated the highest revenue
SELECT *
FROM (
SELECT
dc.customer_id,
dc.firstname,
dc.lastname,
SUM(sales_amount) AS total_revenue,
RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS rank_customers
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_id, dc.firstname, dc.lastname) t
WHERE rank_customers <= 10
ORDER BY rank_customers;

-- The 3 customers with the fewest orders places
SELECT TOP 3
dc.customer_id,
dc.firstname,
dc.lastname,
COUNT(DISTINCT fs.order_number) AS total_orders
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_id, dc.firstname, dc.lastname
ORDER BY total_orders;
