/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To understand how measures evolve over time, enabling the tracking of trends 
      and identification of seasonality in the data.
    - Core formula: aggregate [Measures] based on [Date Dimensions]. 
      For example: total sales by year, or average cost by month.

Key SQL Functions Utilized:
    - Date Functions:  DATEDIFF(), DATEADD(), DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- ============================================================================
-- 📊 Analyze Sales Performance Over Time
-- ============================================================================

-- 1️⃣ Year-level granularity
SELECT 
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- 2️⃣ Month-level granularity (across all years)
-- ⚠️ Note: Grouping by MONTH(order_date) alone aggregates all years together,
-- which may hide seasonal changes across different years.
SELECT 
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY order_month;

-- 3️⃣ Year + Month-level granularity
-- More specific — allows us to compare the same month across different years.
SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

-- 4️⃣ Truncating to the first day of the month using DATETRUNC() (SQL Server 2022+)
-- DATETRUNC truncates a date to a specified part (e.g. month → first day of that month)
-- Example: DATETRUNC(MONTH, '2024-07-16') → '2024-07-01 00:00:00.000'
SELECT 
    DATETRUNC(MONTH, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY order_date;

-- 5️⃣ If DATETRUNC() is not supported (SQL Server pre-2022),
-- use DATEADD + DATEDIFF to truncate to the first day of the month
SELECT 
    CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) AS DATE) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) AS DATE)
ORDER BY order_date;
