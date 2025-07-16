/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To assess whether the business is growing or declining through the progressive aggregation of data over time, enabling performance tracking.
    - Formula: aggregate [Cumulative Measures] based on [Date Dimensions] 
	  - For example: Running total of sales by year or Moving average of sales by month, ...
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/


-- 📊 Monthly Sales with Running Total and Moving Average

-- Step 1: Aggregate sales data at the month level
-- Step 2: Apply window functions to calculate:
--         - Running total of sales 
--         - Moving average of price

SELECT
	order_date,
	total_sales,
	-- Cumulative sum: adds current row + all previous rows based on order_date
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	-- Moving average: progressively averages prices month by month
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        Cast(DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) as Date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY Cast(DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) as Date)
) t

-- 🧠 Notes:
-- - By default, SUM() OVER (ORDER BY ...) uses the frame: 
--   RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW — 
--   meaning it includes all rows up to the current one (cumulative behavior).
--
-- - To calculate a 3-month moving average (including the current month and the two previous months),
--   Use the following window frame:
--   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--   → This averages the current row plus the two preceding rows, creating a rolling 3-month view.

-- 🔍 Aggregation Types:
-- - Standard Aggregation: summarizes data for each individual period separately 
--   (e.g., total sales for each month on its own)

-- - Cumulative Aggregation: builds on previous periods to show how values accumulate over time 
--   (e.g., total sales from the beginning up to each month)
