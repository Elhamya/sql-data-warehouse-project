Data Warehouse and Analytics Project

This project showcases the development of a modern data warehouse using SQL Server, designed around real-world business needs. It uses a layered Medallion Architecture to process and transform raw data into valuable business insights.

---
📖 Project Overview  
This project involves:

Data Architecture: Designing a Modern Data Warehouse Using a 3-layered Medallion Architecture (Bronze → Silver → Gold).  
ETL Pipelines: Extracting, transforming, and loading CSV files from ERP and CRM source systems into the warehouse.  
Data Modeling: Developing a star schema model with well-structured fact and dimension tables, optimized for analytical queries.  
Analytics & Reporting: Creating SQL-based reports and exploratory queries to generate actionable insights on sales trends, product performance, and customer behavior.  


🏗️ Data Architecture
Bronze Layer: Full-load raw, unprocessed data as-is from the source systems. This layer serves as a landing zone to ensure data traceability and debugging.  
Silver Layer: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.  
Gold Layer: providing business-ready data modeled into a star schema required for reporting and analytics.  

**Specification: The scope of this project is only focused on the latest dataset, not the historization of data.
