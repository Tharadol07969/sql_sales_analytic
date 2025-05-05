/*
===============================================================================
Sales Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - Window Functions: SUM() OVER(), AVG() OVER(), LAG() OVER()
    - Case: Defines conditional logic for trend analysis.
===============================================================================
*/

-- Analyze sales performance over time
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);


-- Calculate the total sales per month
-- and the running total of sales over time
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY DATETRUNC(year, order_date) ORDER BY order_date) AS running_total_sales, -- window function
AVG(avg_price) OVER (ORDER BY order_date) AS running_avg_price
FROM (
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
) AS t


-- Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales 
WITH yearly_products_sales AS (
SELECT 
YEAR(fs.order_date) AS years,
dp.product_name,
SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON fs.product_key = dp.product_key
WHERE fs.order_date IS NOT NULL
GROUP BY YEAR(fs.order_date), dp.product_name
)

SELECT
years,
product_name,
total_sales,
AVG(total_sales) OVER (PARTITION BY product_name) AS avg_sales,
total_sales - AVG(total_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN total_sales - AVG(total_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN total_sales - AVG(total_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg' END AS avg_change,
-- Year-over-year analysis
LAG(total_sales) OVER (PARTITION BY product_name ORDER BY years) AS previous_year,
total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY years) AS diff_py,
CASE WHEN total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY years) > 0 THEN 'Increase'
	 WHEN total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY years) < 0 THEN 'Decrease'
	 ELSE 'No Change' END AS py_change
FROM yearly_products_sales
ORDER BY product_name, years;
