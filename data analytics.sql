CREATE DATABASE DATA_ANALYTICS;


CREATE TABLE GOLD_FACT_SALES(
  order_number varchar(150),
  product_key INTEGER,
  customer_key INTEGER,
  order_date TIMESTAMP,
  shipping_date TIMESTAMP,
  due_date TIMESTAMP,
  sales_amount INTEGER,
  quantity INTEGER,
  price INTEGER
);

CREATE TABLE GOLD_DIM_PRODUCTS(
  product_key serial,
  product_id INTEGER,
  product_number varchar(150),
  product_name varchar(150),
  category_id varchar(150),
  category varchar(150),
  subcategory varchar(150),
  maintenance varchar(150),
  cost INTEGER,
  product_line varchar(150),
  start_date timestamp
);

CREATE TABLE GOLD_DIM_CUSTOMERS(
  customer_key serial,
  customer_id INTEGER,
  customer_number varchar(150),
  first_name varchar(150),
  last_name varchar(150),
  country varchar(150),
  martial_status varchar(150),
  gender varchar(150),
  birthdate TIMESTAMP,
  create_date TIMESTAMP
);

-- Analyze how to measure evloves over time 
-- ∑[Measure] by [Dimension]

select * from gold_fact_sales;
select * from gold_dim_customers;
select * from gold_dim_products;

-- Analyzing sales performance over time

SELECT 
EXTRACT(YEAR FROM order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold_fact_sales 
WHERE order_date is not null
group by EXTRACT(YEAR FROM order_date)
order by EXTRACT(YEAR FROM order_date);

-- changed year over month for detailed insight to discover seasonality in your data 
SELECT 
EXTRACT(MONTH FROM order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold_fact_sales 
WHERE order_date is not null
group by EXTRACT(MONTH FROM order_date)
order by EXTRACT(MONTH FROM order_date);

-- Cumulative Analysis
-- ∑[Cumulative Measure] by [Date Dimension]

-- Calculating the total sales per month and running total of sales over time
SELECT 
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) as running_total_sales
FROM
(
SELECT
DATE_TRUNC('MONTH',order_date) as order_date,
SUM(sales_amount) as total_sales
FROM gold_fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('MONTH',order_date)
ORDER BY DATE_TRUNC('MONTH',order_date)
) as monthly_sales;

-- Performance Analysis
-- Comparing the current value to a target value helps measure success and compare performance 
-- current[Measure]-Target[Measure]

-- Analyze the yearly performance of products by comparing each products sales to both its average sales performance and the previous years sales?

WITH yearly_product_sales AS (
    SELECT
        EXTRACT(YEAR FROM gold_fact_sales.order_date) AS order_year,
        gold_dim_products.product_name,
        SUM(gold_fact_sales.sales_amount) AS current_sales 
    FROM gold_fact_sales
    LEFT JOIN gold_dim_products 
        ON gold_fact_sales.product_key = gold_dim_products.product_key
    WHERE gold_fact_sales.order_date IS NOT NULL
    GROUP BY 
        EXTRACT(YEAR FROM gold_fact_sales.order_date),
        gold_dim_products.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
	current_sales-AVG(current_sales) OVER(PARTITION BY product_name) as diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name)>0 THEN 'Above Avg'
	     WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name)<0 THEN 'Below Avg'
		 ElSE 'AVG'
	END avg_change,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales-LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) as diff_py,
    CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)>0 THEN 'Increase'
	     WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)<0 THEN 'Decrease'
		 ELSE 'No change'
END py_change
FROM yearly_product_sales
ORDER BY product_name,order_year; 

-- PART TO WHOLE ANALYSIS
-- Analyzing how an individual part is performing compared to the overall, allowing us to understand which category has the greatest impact on the business

-- Which categories contribute the most to the overall sales?
WITH category_sales AS (
    SELECT 
        category,
        SUM(sales_amount) AS total_sales
    FROM gold_fact_sales
    LEFT JOIN gold_dim_products
        ON gold_dim_products.product_key = gold_fact_sales.product_key
    GROUP BY category
)

SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    CONCAT(ROUND(
        (total_sales::NUMERIC / SUM(total_sales) OVER()) * 100,
        2
    ),'%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

-- Data Segmentation
-- Grouping the data based on specfic range helps understand the correlation between two measures

-- Segment products into cost ranges and count how many products fall into each segment
WITH product_segments AS(
SELECT 
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM gold_dim_products)

SELECT 
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- Group customers into three segments based on their spending behaviour
WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATE_PART('year', AGE(MAX(order_date), MIN(order_date)))*12+ 
		DATE_PART('month', AGE(MAX(order_date), MIN(order_date))) AS lifespan
    FROM gold_fact_sales f
    LEFT JOIN gold_dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)

SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) t
GROUP BY customer_segment
ORDER BY total_customers DESC;

/*
============================================================

Customer Report

============================================================

Purpose:
•⁠  ⁠This report consolidates key customer metrics and behaviors

Highlights:
1.⁠ ⁠Gathers essential fields such as customer names, ages, and transaction details.
2.⁠ ⁠Segments customers into categories (VIP, Regular, New) and age groups.
3.⁠ ⁠Aggregates customer-level metrics:
   - total orders
   - total sales
   - total quantity purchased
   - total products
   - lifespan (in months)

4.⁠ ⁠Calculates valuable KPIs:
   - recency (months since last order)
   - average order value
   - average monthly spend

============================================================
*/
WITH base_query as(
-- Base query retrives core columns from the tables
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ',c.last_name) as customer_name,
DATE_PART('year',AGE(c.birthdate)) as age
FROM gold_fact_sales f 
LEFT JOIN gold_dim_customers c
ON c.customer_key=f.customer_key
WHERE order_date IS NOT NULL 
)
,customer_aggregation AS(
-- Aggregates customer level metrics
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products ,
	MAX(order_date) as last_order_date,
	DATE_PART('month',AGE(MAX(order_date),MIN(order_date))) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
)
-- Customer Segmentation
SELECT 
customer_key,
customer_number,
customer_name,
age,

CASE 
	WHEN age<20 THEN 'Under 20'
	WHEN age between 20 AND 29 THEN '20-29'
	WHEN age between 30 AND 39 THEN '30-39'
	WHEN age between 40 AND 49 THEN '40-49'
	ELSE '50 and above'
END AS age_group,
CASE 
    WHEN lifespan>=12 AND total_sales >5000 then 'VIP'
	WHEN lifespan>=12 and total_sales<=5000 then 'Regular'
	ELSE 'NEW'
END AS customer_segment,
last_order_date,
DATE_PART('month',AGE(CURRENT_DATE,last_order_date)) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
-- Compute average order value(avo)
CASE WHEN total_sales = 0 THEN 0 
	 ELSE total_sales/total_orders
END AS avg_order_value,

-- Compute average monthly spend
CASE WHEN lifespan=0 THEN total_sales
	 ELSE total_sales/lifespan
END AS avg_monthly_spend
FROM customer_aggregation;

/*
============================================================

Product Report

============================================================

Purpose:
•⁠  ⁠This report consolidates key Product metrics and behaviors

Highlights:
1.⁠ ⁠Gathers essential fields such as Product name,category,subcategory and cost.
2.⁠ ⁠Segments products by revenue to identify High-performance,Mid-Range or Low-Performance.
3.⁠ ⁠Aggregates product-level metrics:
   - total orders
   - total sales
   - total quantity sold
   - total customers(unique)
   - lifespan (in months)

4.⁠ ⁠Calculates valuable KPIs:
   - recency (months since last sale)
   - average order revenue
   - average monthly revenue

============================================================
*/

WITH base_query AS(
/*
============================================================
1) Base Query: Retrives core columns from fact_sales and dim_products
============================================================ */
SELECT 
	f.order_number,
	f.order_date,
	f.customer_key,
	f.sales_amount,
	f.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales f LEFT JOIN 
gold.dim_products p 
ON f.product_key=p.product_key
WHERE order_date IS NOT NULL -- only consider valid sales dates 
),	

product_aggregations AS(
/*============================================================
2)Product Aggregations: Summarizes key metrics at the product level
============================================================*/

SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATE_PART('month',MIN(order_date),MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount as FLOAT)/NULLIF(quantity,0)),1) AS avg_selling_price
FROM base query

GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)





























