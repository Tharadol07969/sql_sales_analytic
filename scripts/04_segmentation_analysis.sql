/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

-- Which categories contribute the most to overall sales?
WITH categories_sales AS (
SELECT
category,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON fs.product_key = dp.product_key
GROUP BY category)

SELECT
category,
total_sales,
SUM(total_sales) OVER () AS overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM categories_sales
ORDER BY total_sales DESC;

/* Segment products into cost ranges and count how many products fall into each segment */
WITH product_segment AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000' END AS cost_range 
FROM gold.dim_products)

SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC;

/* Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than $5000.
	- Regular: Customers with at least 12 months of history but spending $5000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group */
WITH customers_segments AS (
SELECT
dc.customer_key,
SUM(fs.sales_amount) AS total_spending,
MIN(fs.order_date) AS first_order,
MAX(fs.order_date) AS last_order,
DATEDIFF(month, MIN(fs.order_date), MAX(fs.order_date)) AS lifespan
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key)

SELECT 
customers_segment,
COUNT(customer_key) AS total_customer
FROM (
SELECT
customer_key,
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	 ELSE 'New' 
END AS customers_segment
FROM customers_segments) AS t
GROUP BY customers_segment
ORDER BY total_customer DESC;
