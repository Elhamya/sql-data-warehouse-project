/*
===============================================================================
Product Report
===============================================================================
View: vw_product_segmentation_analysis
    - This report consolidates key product metrics and behaviors.
Purpose:
    - Analyze product-level sales and performance trends.
    - Segment products based on sales volume, lifecycle, and penetration.
    - Useful for category managers, marketing, or strategic planning teams.
================================================================================*/
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS


WITH base_query AS (
    /*-------------------------------------------------------------------------
    Step 1: Base Sales Data
    Join fact_sales with dim_products to extract enriched sales data.
    -------------------------------------------------------------------------*/
    SELECT 
        f.order_number,
        f.order_date,
        f.sales_amount,
        f.quantity, 
        f.price,
        f.customer_key,
        p.product_key, 
        p.product_number,
        p.product_name,
        p.category, 
        p.subcategory,
        p.cost,
        p.start_date
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL  -- Only consider valid sales records
),


product_aggregations AS (
    /*-------------------------------------------------------------------------
    Step 2: Product-Level Aggregation
    Summarizes key sales and performance metrics for each product.
    -------------------------------------------------------------------------*/
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        MIN(order_date) AS first_sale_date,
        MAX(order_date) AS last_sale_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        DATEDIFF(MONTH, min(start_date), GETDATE()) AS months_on_market,      -- Useful to track long-standing products vs. newer ones.

        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,

        -- Avoid division by zero for price calculations
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price,

        -- Profit Calculation: Sales alone isn’t enough — some high-selling products may bring little or no profit.

        (SUM(sales_amount) - SUM(quantity * cost)) AS total_profit,
        CASE 
            WHEN SUM(sales_amount) = 0 THEN 0
            ELSE ROUND((SUM(sales_amount) - SUM(quantity * cost)) * 100.0 / SUM(sales_amount), 2)
        END AS profit_margin_pct
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)


/*-------------------------------------------------------------------------
Step 3: Final Output
Add segmentation logic to make results actionable.
-------------------------------------------------------------------------*/
SELECT 
    pa.product_key,
    pa.product_name,
    pa.category,
    pa.subcategory,
    pa.cost,
    pa.last_sale_date,

    -- Recency (months since last sale)
    DATEDIFF(MONTH, pa.last_sale_date, GETDATE()) AS recency_in_months,

    -- Product Performance Tier
    CASE
		WHEN pa.total_sales >= 50000 THEN 'High-Performer'
		WHEN pa.total_sales >= 10000 AND pa.total_sales < 50000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
    END AS product_performance,

    -- Product Lifecycle Segmentation
    pa.lifespan,
    CASE 
        WHEN pa.lifespan >= 36 THEN 'Mature'
        WHEN pa.lifespan BETWEEN 12 AND 35 THEN 'Growth'
        ELSE 'New'
    END AS lifecycle_stage,

    -- Sales and Order Metrics
    pa.total_orders,
    pa.total_sales,
    pa.total_quantity,
    pa.total_customers,
    pa.avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE 
        WHEN pa.total_orders = 0 THEN 0
        ELSE pa.total_sales / pa.total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN pa.lifespan = 0 THEN pa.total_sales
        ELSE pa.total_sales / pa.lifespan
    END AS avg_monthly_revenue,

    -- Customer Penetration Rate: Shows how many unique customers purchased the product compared to all customers.
    CAST(pa.total_customers AS FLOAT) / (SELECT COUNT(*) FROM gold.dim_customers) AS penetration_rate

FROM product_aggregations pa;

