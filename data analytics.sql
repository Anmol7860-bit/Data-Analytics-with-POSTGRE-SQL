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






























