-- =========================
-- DIMENSION TABLES
-- =========================

CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,         -- Surrogate Key
    customer_id VARCHAR(20),                 -- Business Key
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20)
);

CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(20),
    product_name VARCHAR(150),
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

CREATE TABLE dim_date (
    date_key SERIAL PRIMARY KEY,
    order_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT
);

CREATE TABLE dim_region (
    region_key SERIAL PRIMARY KEY,
    region VARCHAR(50),
    market VARCHAR(50)
);


--Cretaing Fact table--
-- =========================
-- FACT TABLE
-- =========================

CREATE TABLE fact_sales (
    sales_key SERIAL PRIMARY KEY,
    
    customer_key INT,
    product_key INT,
    date_key INT,
    region_key INT,

    order_id VARCHAR(20),
    sales NUMERIC(10,2),
    quantity INT,
    discount NUMERIC(5,2),
    profit NUMERIC(10,2),

    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (region_key) REFERENCES dim_region(region_key)
);

--Indexes--
CREATE INDEX idx_fact_customer ON fact_sales(customer_key);
CREATE INDEX idx_fact_product  ON fact_sales(product_key);
CREATE INDEX idx_fact_date     ON fact_sales(date_key);
CREATE INDEX idx_fact_region   ON fact_sales(region_key);

--Example Data Logic--
-- Insert distinct customers
INSERT INTO dim_customer (customer_id, customer_name, segment, country, city, state, postal_code)
SELECT DISTINCT customer_id, customer_name, segment, country, city, state, postal_code
FROM staging_sales;

-- Similar inserts for product, region, and date

-- Insert into fact table using joins
INSERT INTO fact_sales (customer_key, product_key, date_key, region_key, order_id, sales, quantity, discount, profit)
SELECT 
    c.customer_key,
    p.product_key,
    d.date_key,
    r.region_key,
    s.order_id,
    s.sales,
    s.quantity,
    s.discount,
    s.profit
FROM staging_sales s
JOIN dim_customer c ON s.customer_id = c.customer_id
JOIN dim_product  p ON s.product_id  = p.product_id
JOIN dim_date     d ON s.order_date  = d.order_date
JOIN dim_region   r ON s.region      = r.region;
