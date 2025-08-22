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
