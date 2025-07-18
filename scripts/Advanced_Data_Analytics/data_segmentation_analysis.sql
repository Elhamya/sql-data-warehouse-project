/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
-	Group data into defined ranges or categories by transforming a measure 
    into grouped segments.
-	This allows for aggregation based on the newly created categories.

Use Cases:
-	Customer segmentation
-	Product categorization
-	Regional or geographic analysis
-   ...

Example Concept:
-	[Measure] BY [Measure], where one measure is transformed into a range 
    or group to enable aggregation.

SQL Functions Used:
-	CASE WHEN: Defines custom segmentation logic.
-	GROUP BY: Aggregates data based on the defined segments.
===============================================================================
*/


/*
Group customers into three segments based on their spending behavior:
    - VIP: Customers with at least 12 months of history and spending more than €5,000.
    - Regular: Customers with at least 12 months of history but spending €5,000 or less.
    - New: Customers with a lifespan of less than 12 months.
Return the total number of customers for each group.
*/

WITH customer_order_summary AS (
    SELECT
        c.customer_key,
        c.first_name + ' ' + c.last_name AS customer_name,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM gold.fact_sales f
    INNER JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
),

customer_loyalty AS (
    SELECT
        customer_key,
        customer_name,
        total_spending,
        lifespan,
        CASE
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segmentation
    FROM customer_order_summary
)

SELECT
    customer_segmentation,
    COUNT(customer_key) AS total_customers
FROM customer_loyalty
GROUP BY customer_segmentation
ORDER BY total_customers DESC;


