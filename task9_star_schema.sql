CREATE TABLE orders (
    transaction_id INT,
    date DATE,
    customer_id VARCHAR(50),
    gender VARCHAR(20),
    age INT,
    product_category VARCHAR(100),
    quantity INT,
    price_per_unit NUMERIC(10,2),
    total_amount NUMERIC(10,2)
);

SELECT COUNT(*) FROM orders;
SELECT * FROM orders LIMIT 5;

CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50),
    gender VARCHAR(20),
    age INT
);

CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_category VARCHAR(100)
);
CREATE TABLE dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    day INT
);

CREATE TABLE fact_sales (
    sales_key SERIAL PRIMARY KEY,
    transaction_id INT,
    customer_key INT,
    product_key INT,
    date_key INT,
    quantity INT,
    price_per_unit NUMERIC(10,2),
    total_amount NUMERIC(10,2),

    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

INSERT INTO dim_customer (customer_id, gender, age)
SELECT DISTINCT customer_id, gender, age
FROM orders;

INSERT INTO dim_product (product_category)
SELECT DISTINCT product_category
FROM orders;

INSERT INTO dim_date (full_date, year, month, day)
SELECT DISTINCT
    date,
    EXTRACT(YEAR FROM date),
    EXTRACT(MONTH FROM date),
    EXTRACT(DAY FROM date)
FROM orders;
INSERT INTO fact_sales (
    transaction_id,
    customer_key,
    product_key,
    date_key,
    quantity,
    price_per_unit,
    total_amount
)
SELECT
    o.transaction_id,
    dc.customer_key,
    dp.product_key,
    dd.date_key,
    o.quantity,
    o.price_per_unit,
    o.total_amount
FROM orders o
JOIN dim_customer dc
    ON o.customer_id = dc.customer_id
JOIN dim_product dp
    ON o.product_category = dp.product_category
JOIN dim_date dd
    ON o.date = dd.full_date;

CREATE INDEX idx_customer ON fact_sales(customer_key);
CREATE INDEX idx_product ON fact_sales(product_key);
CREATE INDEX idx_date ON fact_sales(date_key);

SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM fact_sales;

SELECT COUNT(*)
FROM fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL
   OR date_key IS NULL;

SELECT p.product_category,
       SUM(f.total_amount) AS total_sales
FROM fact_sales f
JOIN dim_product p
  ON f.product_key = p.product_key
GROUP BY p.product_category;

SELECT d.year,
       SUM(f.total_amount) AS total_sales
FROM fact_sales f
JOIN dim_date d
  ON f.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;

SELECT p.product_category,
       SUM(f.quantity) AS total_quantity
FROM fact_sales f
JOIN dim_product p
  ON f.product_key = p.product_key
GROUP BY p.product_category;

