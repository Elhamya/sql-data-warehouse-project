/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - Identifying how individual parts (e.g., categories, regions, or variants) contribute to a total metric like sales or revenue.
    - Understanding which categories have the highest impact on overall business performance to support better decision-making.
    - Supporting A/B testing by showing how much each variant contributes to overall results.
    - Formula: [Measure] / Total[Measure] * 100 by dimension.
    

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

-- Which categories contribute the most to overall sales?
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    INNER JOIN gold.dim_products p
        ON f.product_key = p.product_key
    GROUP BY p.category
)

SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    Concat(Round(Cast(total_sales as float)/ SUM(total_sales) OVER () *100, 2), '%') percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
