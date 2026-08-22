-- 1. DATABASE EXPLORATION --
-- 1.1 DATABASE STRUCTURE --

SHOW TABLES;

-- RESULTS: Found 4 tables in workspace.default schema
-- Star schema structure:
--   • dim_address - Address dimension table
--   • dim_customers - Customer dimension table
--   • dim_products - Product dimension table
--   • fact_sales - Sales fact table (central fact table)


-- 1.2 FACT TABLE STRUCTURE -- 

DESCRIBE fact_sales;

-- OBSERVATIONS:
-- fact_sales has 12 columns
--   • Primary metrics: order_quantity, item_price, order_value
--   • Temporal: order_date, days_since_last_order (for customer behavior analysis)
--   • Foreign keys: customer_id, adress_id, product_id (links to dimension tables)
--   • Order tracking: order_id, order_line_nuber, order_status

SELECT
    count(*)
FROM fact_sales;

-- OBSERVATIONS: Total of 2,747 records in fact_sales

-- ********************************************************************************************************* -- 

-- 2. DIMENSIONS EXPLORATION --
-- 2.1 ADDRESS DIMENSION -- 

DESCRIBE dim_address;

SELECT 
    COUNT(DISTINCT country) AS total_countries,
    COUNT(DISTINCT city) AS total_cities,
    COUNT(DISTINCT address) AS total_addresses
FROM dim_address;

-- OBSERVATIONS:
-- dim_address has 4 columns
--   • Primary key: adress_id
-- Address dimension spans 19 countries, 71 cities, and 89 unique addresses

-- 2.2 CUSTOMER DIMENSION -- 

DESCRIBE dim_customers;

SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM dim_customers;

-- OBSERVATIONS:
-- dim_customers has 6 columns
--   • Primary key: customer_id
-- Customer dimension contains 89 unique customers

-- 2.3 PRODUCT DIMENSION -- 

DESCRIBE dim_products;

SELECT
    COUNT(DISTINCT product_code) AS total_product_codes,
    COUNT(DISTINCT product_line) AS total_product_lines
FROM dim_products;

-- OBSERVATIONS:
-- dim_products has 5 columns
--   • Primary key: product_id
--   • Attributes: product_code, product_line, product_price
-- Product dimension contains 109 unique product codes across 7 product lines

-- ********************************************************************************************************* -- 

-- 3. DATES EXPLORATION --

SELECT
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date,
    DATEDIFF(MAX(order_date), MIN(order_date)) AS days_between_dates
FROM fact_sales;

-- OBSERVATIONS:
-- Date range spans from January 6, 2018 to May 31, 2020
-- Total of 876 days (approximately 2.4 years) of sales data
-- This covers a substantial historical period for analysis and trend identification

-- ********************************************************************************************************* -- 

-- 4. MEASURE EXPLORATION --

SELECT * FROM fact_sales LIMIT 10;

-- 4.1 ORDER QUANTITY -- 

SELECT
    ROUND(AVG(order_quantity),0) AS avg_order_quantity,
    MIN(order_quantity) AS min_order_quantity,
    MAX(order_quantity) AS max_order_quantity,
    SUM(order_quantity) AS total_sold_units
FROM fact_sales;

-- OBSERVATIONS:
-- Order quantities range from 6 to 97 units per order
-- Average order quantity: 35 units
-- Total units sold: 96,428 units across all orders

-- 4.2 ORDER VALUE --

SELECT
    ROUND(AVG(order_value),0) AS avg_order_value,
    MIN(order_value) AS min_order_value,
    MAX(order_value) AS max_order_value,
    SUM(order_value) AS total_sales_amount
FROM fact_sales;

-- OBSERVATIONS:
-- Order values range from 482,130 to 14,082,800
-- Average order value: 3,553,048
-- Total sales revenue: 9,760,221,770 (approximately 9.76 billion)

-- 4.3 UNIT PRICE -- 

SELECT 
    ROUND(AVG(item_price),0) AS avg_unit_price,
    MIN(item_price) AS min_unit_price,
    MAX(item_price) AS max_unit_price
FROM fact_sales;

-- OBSERVATIONS:
-- Unit prices range from 26,880 to 252,870
-- Average unit price: 101,099
-- Significant price variation suggests diverse product portfolio

-- 4.4 LAST ORDERS -- 

SELECT
    ROUND(AVG(days_since_last_order),0) AS avg_days_since_last_order,
    MIN(days_since_last_order) AS min_days_since_last_order,
    MAX(days_since_last_order) AS max_days_since_last_order
FROM fact_sales;

-- OBSERVATIONS:
-- Days since last order range from 42 to 3,562 days
-- Average: 1,757 days (approximately 4.8 years)
-- Wide range indicates varying customer purchase frequencies

-- ********************************************************************************************************* --

-- 5. MAGNITUDE -- 
-- This section analyzes business scale across key dimensions
-- Breaking down total sales and units sold by:
--   • Geographic distribution (country/city) - identifies top markets
--   • Customer segmentation - reveals highest value customers  
--   • Product portfolio (product lines) - shows best performing categories

-- 5.1 SOLD UNITS AND SALES BY COUNTRY AND CITY --

SELECT
    a.country,
    a.city,
    SUM(s.order_value) AS total_sales,
    SUM(s.order_quantity) AS total_units_sold,
    ROUND(AVG(s.order_quantity),0) AS avg_order_quantity
FROM fact_sales s
JOIN dim_address a
ON s.adress_id = a.adress_id
GROUP BY a.country, a.city
ORDER BY total_sales DESC;


-- 5.2 SOLD UNIT AND SALES BY CUSTOMER--

SELECT
    c.customer_name,
    SUM(s.order_value) AS total_sales,
    SUM(s.order_quantity) AS total_units_bought,
    ROUND(AVG(s.order_quantity),0) AS avg_order_quantity
FROM fact_sales s
JOIN dim_customers c
ON c.customer_id = s.customer_id
GROUP BY c.customer_name
ORDER BY total_sales DESC;

-- 5.3 SOLD UNIT AND SALES BY PRODUCT LINE --
SELECT
    p.product_line,
    SUM(s.order_value) AS total_sales,
    SUM(s.order_quantity) AS total_units_sold,
    ROUND(AVG(s.order_quantity),0) AS avg_order_quantity
FROM fact_sales s
JOIN dim_products p
ON p.product_id = s.product_id
GROUP BY p.product_line
ORDER BY total_sales DESC;

-- ********************************************************************************************************* --

-- 6. TOP/BOTTOM RANK ANALYZE --  
-- This section identifies best and worst performers across key business dimensions
-- Helps prioritize high-value segments and address underperforming areas

-- 6.1 TOP 5 CUSTOMERS BY REVENUE --

SELECT
    c.customer_name,
    SUM(s.order_value) AS total_sales,
    RANK() OVER (ORDER BY SUM(s.order_value) DESC) AS rank
FROM fact_sales s
LEFT JOIN dim_customers c
ON c.customer_id = s.customer_id
GROUP BY 1
LIMIT 5;

-- OBSERVATIONS:
-- Identifies the top 5 revenue-generating customers
-- RANK() function handles ties in total sales values
-- Results show VIP customers requiring dedicated account management

-- 6.2 TOP 5 CITIES BY UNITS SOLD --

SELECT
    a.country,
    a.city,
    SUM(s.order_quantity) AS total_sales
FROM fact_sales s
LEFT JOIN dim_address a
ON a.adress_id = s.adress_id
GROUP BY 1,2
ORDER BY total_sales DESC
LIMIT 5;

-- OBSERVATIONS:
-- Reveals top performing geographic markets by volume
-- Useful for inventory allocation and regional marketing strategies
-- Country + city granularity enables precise market focus

-- 6.3 TOP 5 AND BOTTOM 5 PRODUCTS BY UNITS SOLD --

(
    SELECT
        p.product_line,
        p.product_code,
        SUM(s.order_quantity) AS total_sales
    FROM fact_sales s
    LEFT JOIN dim_products p ON p.product_id = s.product_id
    GROUP BY 1,2
    ORDER BY total_sales DESC
    LIMIT 5
)
UNION ALL
SELECT NULL, NULL, NULL
UNION ALL
(
    SELECT
        p.product_line,
        p.product_code,
        SUM(s.order_quantity) AS total_sales
    FROM fact_sales s
    LEFT JOIN dim_products p ON p.product_id = s.product_id
    GROUP BY 1,2
    ORDER BY total_sales ASC
    LIMIT 5
);

-- OBSERVATIONS:
-- Combined view of best and worst performing products
-- NULL row separator visually divides top performers from bottom performers
-- Top products = focus for promotion and stock availability
-- Bottom products = candidates for discontinuation or pricing review