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

-- Analyze how to measue evolves over time 
-- ∑[Measure] by [Dimension]

select * from gold_fact_sales;




























