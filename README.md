# 📊 SQL Sales Analytic Report

A comprehensive collection of T‑SQL scripts for exploratory data analysis, metrics calculation, time‑series trends, customer/product segmentation, and report generation. Designed to empower data analysts and BI professionals to rapidly derive insights from a star‑schema sales database.

---

## 📑 Table of Contents

1. [Overview](#-overview)  
2. [Project Structure](#-project-structure)  
3. [Datasets](#%EF%B8%8F-datasets)  
4. [Scripts](#%EF%B8%8F-scripts)  
   - [Database Initialization & EDA](#database-initialization--eda)  
   - [Sales Over Time Analysis](#sales-over-time-analysis)  
   - [Segmentation Analysis](#segmentation-analysis)  
   - [Customer Report](#customer-report)  
   - [Product Report](#product-report)  
5. [Usage](#-usage)  
6. [License](#%EF%B8%8F-license)  

---

## 🔍 Overview

This repository provides a suite of SQL scripts that:

- Initialize a sample star‑schema sales database  
- Perform exploratory data analysis (EDA) on customers, products, and sales  
- Compute key time‑based metrics (daily, monthly, cumulative)  
- Segment customers and products into meaningful cohorts  
- Generate two final reporting views: `gold.report_customers` and `gold.report_products`

---

## 📂 Project Structure
```
sql_sales_analytic/
│
├── datasets/
│   ├── gold.dim_customers.csv                   
│   ├── gold.dim_products.csv
│   └── gold.fact_sales.csv
│
├── doc/
│   ├── report_customers.csv             # Sample output of customer report view
│   └── report_products.csv              # Sample output of product report view
│
├── scripts/
│   ├── 01_init_database.sql                   # Create schemas & load CSVs into staging
│   ├── 02_eda_database_scripts.sql            # Basic EDA: table counts, schemas
│   ├── 03_sales_over_time_analysis.sql        # Time‑based trend analyses    
│   ├── 04_segmentation_analysis.sql           # Customer & product segmentation queries
│   ├── 05_report_customers.sql                # Definition of gold.report_customers view
│   └── 06_report_products.sql                 # Definition of gold.report_products view
│
├── .gitignore
├── README.md
└── LICENSE
```

---

## 🗃️ Datasets

Place your dimension and fact CSV dumps here:

- **`gold.dim_customers.csv`** — Customer master data (keys, names, birthdate, etc.)  
- **`gold.dim_products.csv`** — Product master data (keys, names, categories, cost, etc.)  
- **`gold.fact_sales.csv`** — Sales transactions (order numbers, dates, quantities, amounts, foreign keys)

---

## 🛠️ Scripts

### Database Initialization & EDA

**`01_init_database.sql`**  
- Creates `gold` schema and tables  
- Bulk-imports CSV files into dimension and fact tables  

**`02_eda_database_scripts.sql`**  
- Lists table row counts, column distributions, null‑value checks  

---

### Sales Over Time Analysis

**`03_sales_over_time_analysis.sql`**  
- Calculates daily, monthly, and year‑to‑date sales trends  
- Computes moving averages and cumulative totals  

---

### Segmentation Analysis

**`04_segmentation_analysis.sql`**  
- Defines segments for customers (e.g., VIP, Regular, New) based on recency, frequency, monetary value  
- Classifies products into High/Mid/Low performers by revenue thresholds  

---

### Customer Report

**`05_report_customers.sql`**  
Creates a view `gold.report_customers` that:

- **Purpose:** Consolidates key customer metrics and behaviors  
- **Highlights:**  
  1. Retrieves basic customer info (name, age) and sales history  
  2. Aggregates per-customer totals: orders, sales, quantity, products, lifespan  
  3. Computes KPIs: recency, average order value, average monthly spend  
  4. Segments customers into age groups and VIP/Regular/New cohorts  

> **Sample usage:**  
> ```sql
> SELECT * FROM gold.report_customers
> WHERE customers_segment = 'VIP';
> ```

---

### Product Report

**`06_report_products.sql`**  
Creates a view `gold.report_products` that:

- **Purpose:** Consolidates key product metrics and performance  
- **Highlights:**  
  1. Retrieves product details (name, category, cost) and sales history  
  2. Aggregates per-product totals: orders, sales, quantity sold, unique customers, lifespan  
  3. Computes KPIs: recency, average order revenue, average monthly revenue  
  4. Segments products into High-, Mid-, or Low-performers based on revenue  

> **Sample usage:**  
> ```sql
> SELECT * FROM gold.report_products
> ORDER BY total_sales DESC
> LIMIT 10;
> ```

---

## 🚀 Usage

1. **Initialize the database** with dimensions and fact tables:  
   ```bash
   psql -f scripts/01_init_database.sql
2. **Explore data** using EDA scripts:
   ```bash
   psql -f scripts/02_eda_database_scripts.sql
3. **Run trend and segmentation analyses**:
   ```bash
   psql -f scripts/03_sales_over_time_analysis.sql
   psql -f scripts/04_segmentation_analysis.sql
4. **Build final reports**:
   ```bash
   psql -f scripts/05_report_customers.sql
   psql -f scripts/06_report_products.sql
5. **Query the reporting views**:
   ```bash
   SELECT * FROM gold.report_customers;
   SELECT * FROM gold.report_products;

---

## 🛡️ License
This project is released under the MIT License. See LICENSE for details.
MIT License
