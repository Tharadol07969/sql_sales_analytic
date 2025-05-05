/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO
CREATE VIEW gold.report_products AS
WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
	SELECT
		dp.product_key,
		dp.product_name,
		dp.category,
		dp.subcategory,
		dp.cost,
		fs.order_number,
		fs.sales_amount,
		fs.quantity,
		fs.customer_key,
		fs.order_date
	FROM gold.fact_sales AS fs
	LEFT JOIN gold.dim_products AS dp
	ON fs.product_key = dp.product_key
	WHERE fs.order_date IS NOT NULL)

, product_aggregation AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity_sold,
		COUNT(DISTINCT customer_key) AS total_customers,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
		MAX(order_date) AS last_order_date
	FROM base_query
	GROUP BY
		product_key,
		product_name,
		category,
		subcategory,
		cost)

/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	lifespan,
	CASE WHEN total_sales > 50000 THEN 'High-Performers'
		 WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid-Range'
		 ELSE 'Low-performers'
	END AS product_segment,
	total_orders,
	total_sales,
	total_quantity_sold,
	total_customers,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders 
	END AS avg_order_revenue,
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales / lifespan 
	END AS avg_monthly_revenue
FROM product_aggregation;
