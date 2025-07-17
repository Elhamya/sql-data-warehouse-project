/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To compare current values against target benchmarks such as:
        • Previous values (e.g., last year/month)
        • Averages
        • Minimums or maximums
    - Example: Current year sales vs. previous year sales (YOY analysis),
               Current month sales vs. average sales, or vs. highest/lowest values
    - To track monthly or yearly trends and growth.
    - To benchmark and identify high- or low-performing entities.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
    - Value-based Functions: 
        • LAG(): Retrieves values from the previous row (for comparisons)
    - CASE: For conditional trend logic (e.g., flagging growth or decline)
===============================================================================
*/

-- Analyze the *yearly* performance of *products* by comparing their *sales* 
-- to both the average sales performance of the product and the previous year's sales

WITH product_sales_by_year AS (
    SELECT 
        YEAR(f.order_date) AS sales_year,
        p.product_name,
        SUM(f.sales_amount) AS yearly_sales_amount
    FROM 
        gold.fact_sales f
    LEFT JOIN 
        gold.dim_products p ON f.product_key = p.product_key
    WHERE 
        f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date), p.product_name
),

sales_with_analytics AS (
    SELECT
        sales_year,
        product_name,
        yearly_sales_amount,
        AVG(yearly_sales_amount) OVER (PARTITION BY product_name) AS average_sales_amount,
        LAG(yearly_sales_amount) OVER (PARTITION BY product_name ORDER BY sales_year) AS previous_year_sales
    FROM 
        product_sales_by_year
)

SELECT
    sales_year,
    product_name,
    yearly_sales_amount,
    previous_year_sales,
    yearly_sales_amount - previous_year_sales AS sales_change_from_previous_year,
    CASE 
        WHEN yearly_sales_amount > previous_year_sales THEN 'increase'
        WHEN yearly_sales_amount < previous_year_sales THEN 'decrease'
        ELSE 'no_change'
    END AS year_over_year_comparison,

    average_sales_amount,
    yearly_sales_amount - average_sales_amount AS sales_vs_average,
    CASE 
        WHEN yearly_sales_amount > average_sales_amount THEN 'above_average'
        WHEN yearly_sales_amount < average_sales_amount THEN 'below_average'
        ELSE 'average'
    END AS average_comparison

FROM 
    sales_with_analytics
ORDER BY 
    product_name, sales_year;


-- --------------------------------------------------------
-- 💡 Query Design Note:
-- 
-- Try to write SQL that is not only efficient but also easy to read and maintain.
-- Using **layered CTEs** is a helpful way to structure complex logic in stages.
--
-- In this example:
-- - The first CTE (`product_sales_by_year`) handles basic aggregation.
-- - The second CTE (`sales_with_analytics`) adds business logic using window functions.
-- - The final SELECT presents clean, labeled output ready for reporting or dashboards.
--
-- This structure makes the query easier to follow — like a **data pipeline**, where each layer
-- performs a specific task. It also improves maintainability: if the business logic changes,
-- you can often update just one layer without rewriting the entire query.
-- --------------------------------------------------------
