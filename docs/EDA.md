<img width="379" height="210" alt="image" src="https://github.com/user-attachments/assets/d3eb29fd-963c-4f6e-af39-eb517dfd7524" />

Exploratory Data Analysis (EDA) with SQL

Exploratory Data Analysis (EDA) is the process of using SQL to understand the structure, quality, and content of a dataset.
The goal is to profile the data before moving into deeper analysis or modelling.

EDA can be broken into five key steps:

Database Exploration

Dimensions Exploration

Date Exploration

Measure & Magnitude Analysis

Ranking Analysis

1. Database Exploration

The first step is understanding the database structure — tables, views, columns, and constraints.
SQL provides system views (in INFORMATION_SCHEMA) for this purpose:

-- List all tables in the database
SELECT table_schema, table_name
FROM INFORMATION_SCHEMA.TABLES;

-- List all columns in a specific table
SELECT column_name, data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'sales';

This gives a read-only overview of the schema.
From here, you can start thinking about what belongs to Dimensions and what belongs to Measures:
•	Measures → numeric values that make sense to aggregate (e.g., revenue, quantity).
•	Dimensions → descriptive attributes that group or segment measures (e.g., product, region, customer).
•	Sometimes, numeric values can be derived from dimensions (e.g., age from birthdate).
2. Dimensions Exploration

Dimensions describe how data can be grouped or segmented.
Key steps:

Identify unique values in each dimension.

Check hierarchies (e.g., country → region → city).

Assess granularity (e.g., customer-level, order-level).

-- Count distinct categories in products
SELECT COUNT(DISTINCT category) AS unique_categories
FROM products;

-- View sample categories
SELECT DISTINCT category
FROM products
LIMIT 10;


✅ Low-cardinality dimensions: country, gender, category
✅ High-cardinality dimensions: customer_id, product_id, address

3. Date Exploration

Dates define the scope and timeline of the dataset.
This is essential for time-series analysis and forecasting.

-- Find min and max dates
SELECT MIN(order_date) AS first_date,
       MAX(order_date) AS last_date,
       DATEDIFF(MAX(order_date), MIN(order_date)) AS timespan_days
FROM sales;


This tells you:

The boundaries of the dataset

The timespan covered

Whether the data is continuous or missing periods

4. Measure & Magnitude Analysis

Measures are quantitative metrics (e.g., sales, revenue, profit).
We use aggregation functions (SUM, AVG, MIN, MAX, COUNT) to answer questions like:

How many?

How much?

-- Total sales and average order value
SELECT SUM(sales_amount) AS total_sales,
       AVG(sales_amount) AS avg_order_value
FROM sales;


Magnitude Analysis compares measures across dimensions:

-- Sales by country
SELECT country, SUM(sales_amount) AS total_sales
FROM sales
GROUP BY country
ORDER BY total_sales DESC;

This helps identify which categories, regions, or products contribute the most.

5. Ranking Analysis

Ranking highlights the top/bottom performers across dimensions.

-- Top 5 products by revenue
SELECT product_id, 
       SUM(sales_amount) AS total_sales,
       RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS sales_rank
FROM sales
GROUP BY product_id
ORDER BY sales_rank
LIMIT 5;


Example output:

Product_ID	Total Sales	Sales Rank
P123	95,000	1
P451	82,000	2
P672	77,500	3

This reveals top-performing or underperforming categories, products, or customers.

🔑 Summary

EDA with SQL helps answer:

What’s in my data? (Database exploration)

How can it be grouped? (Dimensions exploration)

What’s the time range? (Date exploration)

What are the key metrics? (Measure & magnitude analysis)

Who/what performs best? (Ranking analysis)

By following these steps, you build a clear understanding of the dataset before deeper analysis or modeling.
