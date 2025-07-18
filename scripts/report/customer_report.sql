/*
==========================================================================================
Customer Report
==========================================================================================
Purpose:
    - This script consolidates key customer metrics and behavioral insights to support 
      analysis and decision-making for marketing, sales, and retention strategies.
-- ------------------------------------------------------------------------------------------------------------------------------
-- It includes:
--  1. Base sales and customer extraction: Extracts essential transaction and demographic details
--  2. Aggregation of customer-level KPIs
--  3. Behavioral and value-based customer segmentation: Assigns each customer to a strategic segment ( VIP, Loyal, Inactive, New)
--  4. RFM scoring and customer tagging
-- 
-- 🔍 Final Output: One row per customer with segmentation tags, KPIs, and RFM scores.
-- ================================================================================================================================
🧠 Overview: Two Types of Customer Segmentation
This analysis compares two different segmentation approaches:

✅ 1. Behavioral (Business Rule–Based) Segmentation
Uses custom rules based on domain knowledge and business strategy.
Defines customer types such as VIP, Loyal, Inactive, or New based on metrics like recency, lifespan, total_sales, etc.
Flexible and tailored to specific business goals.

✅ 2. RFM Segmentation (Recency, Frequency, Monetary)
A systematic, quantitative approach to customer scoring.
Each customer is scored (typically 1–3) on:
Recency – how recently they purchased
Frequency – how often they purchased
Monetary – how much they spent

Segments such as Champions, Loyal Customers, At Risk, etc., are assigned based on combined scores.
-- ================================================================================================================================
*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

with base_query as(
/*--------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables > ❌ Don’t do GROUP BY or segmentation here.
  --------------------------------------------------------------------------------------------
*/
select  
    f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		f.price,
		c.customer_key,
		c.customer_number,
		c.country,
		c.marital_status,
		c.gender,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		FLOOR(DATEDIFF(day, c.birthdate, GETDATE()) / 365.25) AS age,
		p.cost,
		f.quantity * p.cost AS line_cost  -- calculate line item cost	
			
from gold.fact_sales f Left Join gold.dim_customers c
on f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key 
where order_date IS NOT NULL
),


customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
-----------------------------------------------------------------------------
*/
select  
    customer_key,
		customer_number,
		customer_name,
		age,
		count(distinct order_number) as Total_orders,
		sum(sales_amount)as Total_sales,
		sum(line_cost) as Total_cost,
		sum(quantity) as Total_quantity,
		count(distinct product_key) as total_products,
		min(order_date) as first_order_date,
		max(order_date) as last_order_date, 
		DATEDIFF(month, max(order_date), GETDATE()) AS recency,        -- Months since last order
                CASE WHEN COUNT(DISTINCT order_number) > 1 THEN 'Yes' 
		     ELSE 'No' 
	        END AS has_returned, 
		DATEDIFF(Month, MIN(order_date), MAX(order_date)) as lifespan  -- months between first and last order
from base_query
group by customer_key,
		 customer_number,
		 customer_name,
		 age),


customer_segmentation as(

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE 
         WHEN age < 30 THEN 'Young'
         WHEN age BETWEEN 30 AND 50 THEN 'Middle-aged'
         ELSE 'Senior'
    END age_group,
    CASE 
        WHEN recency <= 3 AND total_sales >= 5000 THEN 'VIP'                     -- High-spending customers who bought recently. These are top-tier customers.
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'High-Value Regular'     -- Long-term, high-spending customers, but not necessarily recent buyers.
        WHEN lifespan >= 6 AND total_orders >= 10 THEN 'Loyal'                   -- Long-term customers with frequent orders who may not spend a lot per order but buy often.
        WHEN recency >= 12 THEN 'Inactive'                                       -- Haven’t made a purchase in over a year — need re-engagement.
        ELSE 'New'                                                               -- New, low-spending, or low-activity customers — still learning their behavior.
    END AS customer_segment
    ,
    last_order_date,
    recency,   
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    -- Compuate average order value (AOV)
    CASE WHEN total_sales = 0 THEN 0
    	   ELSE total_sales / total_orders
    END AS avg_order_value,
    -- Compuate average monthly spend
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan
    END AS avg_monthly_spend,
    -- Compuate order frequency (Orders per month = Engagement level)
    CASE WHEN lifespan = 0 THEN total_orders
         ELSE total_orders * 1.0 / lifespan
    END AS order_frequency,
    -- Compute average quantity per order (Reveals whether a customer buys in bulk or makes frequent small purchases)
    CASE WHEN total_orders = 0 THEN 0 
         ELSE total_quantity * 1.0 / total_orders 
    END AS avg_quantity_per_order,
    -- Compute Customer Profit (CLV)
    Total_sales - Total_cost AS customer_lifetime_value,
    -- Compute profit margin
    CASE WHEN total_sales = 0 THEN NULL
         ELSE (total_sales - total_cost) * 1.0 / total_sales
    END AS profit_margin,
    -- Recency score (lower recency = better)
    CASE 
        WHEN recency <= 3 THEN 3
        WHEN recency <= 6 THEN 2
        ELSE 1
    END AS recency_score,
    
    -- Frequency score (more orders = better)
    CASE 
        WHEN total_orders >= 10 THEN 3
        WHEN total_orders >= 5 THEN 2
        ELSE 1
    END AS frequency_score,
    
    -- Monetary score (more spend = better)
    CASE 
        WHEN total_sales >= 1000 THEN 3
        WHEN total_sales >= 500 THEN 2
        ELSE 1
    END AS monetary_score
FROM customer_aggregation
)



select *,
     CASE 
    	 WHEN recency_score = 3 AND frequency_score = 3 AND monetary_score = 3 THEN 'Champions'                -- best customers: spend the most, buy most often, and purchased recently
    	 WHEN recency_score >= 2 AND frequency_score >= 2 AND monetary_score >= 2 THEN 'Loyal Customers'       -- Very engaged, valuable customers who come back often and spend well
    	 WHEN recency_score = 1 AND monetary_score >= 2 THEN 'At Risk'                                         -- haven’t purchased recently), but still spend> start to drift — you should re-engage them
    	 WHEN recency_score = 1 AND frequency_score = 1 THEN 'Lost'                                            -- Haven’t purchased in a long time and were never frequent buyers — maybe churned
    	 WHEN total_orders = 1 AND recency_score = 3 THEN 'New'                                                -- Just joined — they need onboarding and nurturing
         ELSE 'Others'                                                                                         -- Customers who don’t fit clearly into the above categories — a mixed bag
     END AS rfm_segment
from customer_segmentation




















