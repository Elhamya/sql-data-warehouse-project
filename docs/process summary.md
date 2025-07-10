# **Data Warehouse Project: SQL-Based Data Cleansing and Integration**  
In this project, I built a full SQL Data Warehouse using a three-layer Medallion architecture (Bronze, Silver, Gold). I used bulk insert to load raw data, applied quality checks and transformations in SQL, and created a star schema for business analytics. I handled real-world challenges like data inconsistencies, surrogate keys, and business logic, ensuring clean, integrated, and analysis-ready data.

## **Process Overview**  
💽 Database and Schema Setup  
For Creating a brand-new DB > Switch to the master database, which is a system database used to create other databases. After creating a new DB, switch to it before building new objects.
First: Create schemas — it’s like a folder, helps to keep things organized. Having three layers (Bronze, Silver, Gold) requires three schemas.

🟫⬜ Bronze/Silver Layer  
Purpose: Load raw data from source CSVs to the warehouse using BULK INSERT (efficient for batch loading instead of row-by-row inserts).
After creating the same table structure in Silver as in Bronze, detect data quality issues in Bronze first, otherwise transformations may be flawed.
Bronze should contain raw, unprocessed data, while Silver holds cleaned and validated data.
During transformation from Bronze to Silver, always ask: "Does the current DDL still work for this cleaned data?"
Check DDL compatibility against the cleaned data and revise if needed.

🟨 Gold Layer: Business-Ready Integration  
Gold layer focuses on business logic and integration, requiring clear understanding of business objects and source systems.
Collaborate with domain experts to understand business rules and identify key business entities.
Split gold-layer implementation into:  
1.	Build business objects by analyzing the original data model and relationships.
2.	Decide table type: fact vs dimension.
3.	Rename and organize columns for user-friendly access.


🧩 **Fact & Dimension Design**  
•	Always start joins from master table to avoid data loss.  
•	Check for duplicates after joins — because by the join logic the relationship between tables are not always clear 1: M, it may cause M: M relationship at some place, so better to do group by on the unique keys like PK.) In addition to that you may confront with with requires data integration.  
•	Integrated fields: columns under the same information in one table may happened as a result of joining (e.g., Gender exists in multiple tables — consolidate and clean).  
•	Create surrogate keys for dimension tables if source system lacks unique IDs.  
•	Use these surrogate keys in fact tables via lookup joins.  

🧹 **Data Cleansing Functions Used**  
•	String Functions: UPPER(), TRIM(), REPLACE(), SUBSTRING(), LEN()  
•	Null/Missing Handling: ISNULL(), NULLIF()  
•	Date/Time Handling: GETDATE(), LEAD(), LAG()  
•	Analytical/Window Functions: ROW_NUMBER()  
•	Conversion: CAST(), ABS()  

📋 **Data Quality Checks**  
•	Remove duplicates by identifying and retaining the most relevant row, ensuring only one record per entity.  
•	Validate Primary Keys for uniqueness and NULLs.  
•	Check for unwanted spaces in string columns to standardize text formatting.  
•	Ensure data consistency in low cardinality columns (e.g., gender, country, marital status).  
•	Handle missing or invalid values, for example, assigning default values ( like "N/A" for NULLs or empty strings, or using 0 in numeric columns like Null cost values).  
•	Map coded values to readable, user-friendly descriptions (a part of data normalization and standardization).  
•	Data Type Validation: like using CAST() when needed.   
•	Check for outliers and boundary issues in fields like age or date ranges to ensure values are within acceptable limits. (e.g., Order Date < Ship Date, age logic).  
•	Validate business rules in calculations, such as ensuring:  
Sales = Quantity * Price, while also verifying that price is not negative.  
•	Create derived columns by transforming existing data to support deeper analytics.  
•	Enrich data by adding contextually relevant external values based on logic derived from existing fields.  


📝 **Additional Notes (Refined for Clarity):**  
•	Note: For complex transformations in SQL, I often narrow the data down to a specific example (sometimes in Excel) and brainstorm multiple solution approaches before integrating them into the main query.  
•	Note: At this stage, it’s important to consult with domain experts or source system owners to fully understand business rules and ensure transformation logic aligns with real-world processes.  
•	Note: If improvements are introduced in one stored procedure such as enhanced logging or error handling—in one stored procedure, make sure to apply those changes across others to maintain consistency and standards.   

This model enables reliable and fast reporting for business users, supports self-service BI tools, and maintains data governance through structured ETL layers.




