📊 Data Analytics with PostgreSQL

🚀 An end-to-end SQL Data Analytics Project focused on transforming raw transactional data into meaningful business insights using PostgreSQL.

📌 Project Overview

This project demonstrates how to design a data warehouse-style schema and perform advanced analytics using SQL. It includes:

Fact and Dimension tables (Sales, Customers, Products)
Real-world business analysis scenarios
KPI-driven reporting using advanced SQL techniques

The goal is to showcase how SQL can be used for decision-making, performance analysis, and customer segmentation—a core skill in data analytics roles .

🗂️ Database Schema

The project uses a star schema design:

Fact Table
gold_fact_sales → Stores transactional sales data
Dimension Tables
gold_dim_customers → Customer details
gold_dim_products → Product information
🔍 Key Analysis Performed
📈 1. Sales Trend Analysis
Yearly and monthly sales trends
Identified seasonality patterns
Metrics:
Total Sales
Total Customers
Total Quantity
🔄 2. Cumulative Analysis
Running total of sales using window functions
Helps track business growth over time
📊 3. Performance Analysis
Compared product sales against:
Average performance
Previous year sales (LAG())
Identified:
Above/Below average products
Growth trends
🧩 4. Part-to-Whole Analysis
Category-wise contribution to total sales
Helps identify high-impact product categories
🎯 5. Customer Segmentation

Customers classified into:

VIP
Regular
New

Based on:

Spending behavior
Customer lifespan
🛍️ 6. Product Segmentation

Products categorized into:

High Performers
Mid-Range
Low Performers
📊 KPIs Built
Recency (months since last order)
Customer lifespan
Average Order Value (AOV)
Average Monthly Spend
Average Selling Price
Total Orders / Sales / Quantity
🧠 Advanced SQL Concepts Used
✅ Common Table Expressions (CTEs)
✅ Window Functions (SUM OVER, LAG, AVG)
✅ Aggregate Functions (SUM, COUNT, AVG)
✅ Date Functions (AGE, DATE_PART, DATE_TRUNC)
✅ CASE Statements for segmentation
✅ Joins (Fact + Dimension tables)

These techniques are widely used in real-world analytics projects to extract insights from structured data .

📁 Project Structure
📦 Data-Analytics-with-POSTGRE-SQL
 ┣ 📜 SQL Scripts
 ┃ ┣ customer_report.sql
 ┃ ┣ product_report.sql
 ┃ ┣ sales_analysis.sql
 ┣ 📊 Dataset / Tables
 ┣ 📄 README.md
📌 Sample Insights
Identified top-performing product categories driving revenue
Segmented high-value customers (VIPs)
Detected seasonal sales patterns
Measured product performance trends over time
🛠️ Tools & Technologies
PostgreSQL
SQL (Advanced)
pgAdmin / SQL Editor
🚀 How to Run
Clone the repository:
git clone https://github.com/Anmol7860-bit/Data-Analytics-with-POSTGRE-SQL.git
Open PostgreSQL / pgAdmin
Run the SQL script:
-- Create database and tables
-- Insert data (if available)
-- Execute analysis queries
🎯 Use Cases
Business Intelligence Reporting
Customer Analytics
Sales Performance Tracking
Product Optimization
📢 Author

Anmol Bhandare
Aspiring Data Analyst | SQL | Data Analytics

⭐ Support

If you found this project useful:

⭐ Star the repository
🔗 Share with others
🤝 Connect on LinkedIn
📌 Conclusion

This project highlights how SQL alone can power end-to-end analytics, from raw data to actionable insights—making it a strong foundation for any data analytics role.
