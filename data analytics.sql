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
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales
FROM yearly_product_sales;


























