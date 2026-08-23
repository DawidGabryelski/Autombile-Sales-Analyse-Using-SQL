-- 1. TIME ANALYSIS --
-- THIS QUERY SUMMARIZES SALES PERFORMANCE BY YEAR AND MONTH, OFFERING A BREAKDOWN OF ORDER COUNT, SALES VALUE, AND UNITS SOLD.
-- OBSERVATIONS: USE THIS TO IDENTIFY MONTHLY AND YEARLY SALES TRENDS, INCLUDING PEAK DEMAND PERIODS AND SEASONAL PATTERNS.
-- ADDITIONAL OBSERVATIONS: SHARP INCREASES IN SALES MAY REFLECT PROMOTIONAL EVENTS OR NEW PRODUCT LAUNCHES. MONTHS WITH CONSISTENTLY LOW SALES COULD INDICATE THE NEED FOR TARGETED MARKETING. COMPARING YEAR-OVER-YEAR PERFORMANCE HIGHLIGHTS GROWTH RATES AND POTENTIAL EXTERNAL INFLUENCES, SUCH AS MARKET CONDITIONS OR SUPPLY CHAIN DISRUPTIONS.

SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(*) AS total_orders,
    SUM(order_value) AS sales_amount,
    SUM(order_quantity) AS total_units_sold
FROM fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

-- 2. CUMULATIVE ANALYSIS --
-- THIS SECTION CALCULATES CUMULATIVE SALES AND UNITS SOLD ACROSS MONTHS AND YEARS, HELPING TRACK GROWTH AND ASSESS OVERALL PERFORMANCE.
-- OBSERVATIONS: THE CUMULATIVE TOTALS SHOW HOW SALES AND UNITS SOLD ACCUMULATE OVER TIME, REVEALING CONSISTENT GROWTH AND HIGHLIGHTING PERIODS WHERE THE RATE OF INCREASE ACCELERATES OR SLOWS DOWN. PERSISTENT INCREASES INDICATE SUSTAINED BUSINESS GROWTH, WHILE STAGNATION OR DIPS MAY SIGNAL WEAKER PERFORMANCE.
-- RESULTS: PREVIOUS RUNS TYPICALLY SHOW STEADY CUMULATIVE GROWTH ACROSS MONTHS AND YEARS, WITH OCCASIONAL JUMPS INDICATING STRONG SALES PERIODS, AND OCCASIONAL STAGNATION OR SLOW GROWTH IN OFF-PEAK MONTHS. 

WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS _year,
        MONTH(order_date) AS _month,
        COUNT(*) AS total_orders,
        SUM(order_value) AS sales_amount,
        SUM(order_quantity) AS total_units_sold
    FROM fact_sales
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    _year,
    _month,
    total_orders,
    sales_amount,
    SUM(sales_amount) OVER (ORDER BY _year, _month) AS running_total,
    total_units_sold,
    SUM(total_units_sold) OVER (ORDER BY _year, _month) AS running_units
FROM monthly_sales
ORDER BY _year, _month;

-- 3. COMPARING ANALYSIS -- 
-- 3.1 YEAR OVER YEAR SUMMARY --
-- THIS QUERY CALCULATES ANNUAL SALES AND UNIT DIFFERENCES COMPARED TO THE PREVIOUS YEAR.
-- OBSERVATIONS: YEAR-OVER-YEAR PERCENT CHANGES HIGHLIGHT SALES MOMENTUM, GROWTH, OR CONTRACTION IN BOTH REVENUE AND UNITS. A POSITIVE PERCENTAGE INDICATES EXPANSION, WHILE A NEGATIVE VALUE SIGNALS DECLINE. LARGE SWINGS MAY REFLECT OPERATIONAL CHANGES, ECONOMICAL FACTORS, OR PROMOTION EFFECTIVENESS.
-- RESULTS: USE THESE NUMBERS TO BENCHMARK YEARLY PERFORMANCE AND ASSESS STRATEGIC PROGRESS VERSUS PRIOR YEARS.

WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS _year,
        MONTH(order_date) AS _month,
        COUNT(*) AS total_orders,
        SUM(order_value) AS sales_amount,
        SUM(order_quantity) AS total_units_sold
    FROM fact_sales
    GROUP BY YEAR(order_date), MONTH(order_date)
),
prevoius_year_diff AS (
    SELECT
        _year,
        SUM(sales_amount) AS sales_amount,  
        LAG(SUM(sales_amount)) OVER (ORDER BY _year) AS previous_year,
        SUM(total_units_sold) AS total_units_sold,
        LAG(SUM(total_units_sold)) OVER (ORDER BY _year) AS previous_year_units
    FROM monthly_sales
    GROUP BY _year
)
SELECT
    _year,
    CASE WHEN previous_year IS NULL OR previous_year = 0 THEN 0
    ELSE ROUND((sales_amount - previous_year)/previous_year * 100, 0)  END AS sales_growth_prc,
    CASE WHEN previous_year_units IS NULL OR previous_year_units = 0 THEN 0
    ELSE ROUND((total_units_sold - previous_year_units)/previous_year_units * 100, 0) END AS units_growth_prc
FROM prevoius_year_diff
ORDER BY _year ASC;

-- 3.2 MONTH OVER MONTH SUMMARY --
-- THIS ANALYSIS SHOWS SALES AND UNIT GROWTH ON A MONTH-TO-MONTH BASIS, OFFERING GRANULAR INSIGHTS ON SHORT-TERM CHANGES.
-- OBSERVATIONS: MONTHLY PERCENT CHANGES HELP TRACK SURGES OR DROPS FROM RECENT ACTIVITY. CONSISTENT INCREASES SHOW HEALTHY TRENDS, WHILE NEGATIVE MOVEMENTS MAY WARRANT TACTICAL ADJUSTMENTS. USE THIS TO EVALUATE SEASONAL PEAKS, MARKETING IMPACT, AND OPERATIONAL ISSUES.
-- RESULTS: TREND ANALYSIS REVEALS PERIODS OF RAPID GROWTH OR SLOWDOWNS AT THE MONTHLY LEVEL, USEFUL FOR AGILE PLANNING AND RESOURCE ALLOCATION.

WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS _year,
        MONTH(order_date) AS _month,
        COUNT(*) AS total_orders,
        SUM(order_value) AS sales_amount,
        SUM(order_quantity) AS total_units_sold
    FROM fact_sales
    GROUP BY YEAR(order_date), MONTH(order_date)
),
prevoius_month_diff AS (
    SELECT
        _year,
        _month,
        SUM(sales_amount) AS sales_amount,  
        LAG(SUM(sales_amount)) OVER (ORDER BY _year, _month) AS previous_month,
        SUM(total_units_sold) AS total_units_sold,
        LAG(SUM(total_units_sold)) OVER (ORDER BY _year, _month) AS previous_month_units
    FROM monthly_sales
    GROUP BY _year, _month
)
SELECT
    _year,
    _month,
    CASE WHEN previous_month IS NULL OR previous_month = 0 THEN 0
         ELSE ROUND((sales_amount - previous_month) / previous_month * 100, 0) END AS sales_growth_prc,
    CASE WHEN previous_month_units IS NULL OR previous_month_units = 0 THEN 0
         ELSE ROUND((total_units_sold - previous_month_units) / previous_month_units * 100, 0) END AS units_growth_prc
FROM prevoius_month_diff
ORDER BY _year ASC, _month ASC;

-- 4. PART TO WHOLE ANALYSIS --
-- THIS SECTION MEASURES HOW INDIVIDUAL SEGMENTS (COUNTRIES, CITIES, PRODUCTS, CUSTOMERS) CONTRIBUTE TO OVERALL SALES PERFORMANCE.
-- OBSERVATIONS: PART-TO-WHOLE ANALYSIS REVEALS WHICH AREAS, ITEMS, OR CUSTOMERS MAKE UP THE LARGEST SHARE OF REVENUE, HELPING IDENTIFY CONCENTRATION RISK, TOP CONTRIBUTORS, AND OPPORTUNITIES FOR DIVERSIFICATION. USE THIS TO TARGET GROWTH REGIONS, OPTIMIZE PRODUCT MIX, OR TAILOR CUSTOMER STRATEGIES.

-- 4.1 COUNTRIES --
-- THIS QUERY SUMMARIZES ORDER COUNT, SALES VALUE, AND UNITS SOLD BY COUNTRY, SHOWING EACH COUNTRY’S SALES SHARE OF THE TOTAL.
-- OBSERVATIONS: COUNTRIES WITH HIGH SALES PERCENTAGES ARE BUSINESS STRONGHOLDS. IF A FEW COUNTRIES DOMINATE, CONSIDER EXPANSION ELSEWHERE FOR BALANCE. COUNTRIES WITH LOW SALES MAY BENEFIT FROM TARGETED MARKETING OR LOCAL PARTNERSHIPS.

WITH city_sales AS (
    SELECT
        a.city,
        COUNT(*) AS total_orders,
        SUM(s.order_value) AS sales_amount,
        SUM(s.order_quantity) AS total_units_sold
    FROM fact_sales s
    LEFT JOIN dim_address a
    ON s.address_id = a.address_id
    GROUP BY 1
    ORDER BY 2 DESC
)
SELECT
    city,
    total_orders,
    sales_amount,
    total_units_sold,
    ROUND(sales_amount / SUM(sales_amount) OVER() * 100, 0) AS pct_sales
FROM city_sales
GROUP BY 1, 2, 3, 4;

-- 4.2 CITIES --
-- THIS QUERY PRESENTS CITY-LEVEL SALES DETAILS, CALCULATING EACH CITY’S SHARE OF TOTAL SALES.
-- OBSERVATIONS: TOP-PERFORMING CITIES HIGHLIGHT GROWTH HUBS AND POTENTIAL FOR REGIONAL INVESTMENT. CITIES WITH SMALL SALES SHARES MAY REQUIRE MARKET RESEARCH OR SALES INITIATIVES. OUTLIERS CAN SURFACE BOTH RISKS AND OPPORTUNITIES.

WITH city_sales AS (
    SELECT
        a.city,
        COUNT(*) AS total_orders,
        SUM(s.order_value) AS sales_amount,
        SUM(s.order_quantity) AS total_units_sold
    FROM fact_sales s
    LEFT JOIN dim_address a
    ON s.address_id = a.address_id
    GROUP BY 1
    ORDER BY 2 DESC
)
SELECT
    city,
    total_orders,
    sales_amount,
    total_units_sold,
    ROUND(sales_amount / SUM(sales_amount) OVER() * 100, 0) AS pct_sales
FROM city_sales
GROUP BY 1, 2, 3, 4;

-- 4.3 PRODUCTS --
-- THIS ANALYSIS BREAKS DOWN SALES METRICS AND SHARE BY PRODUCT LINE, REVEALING WHICH PRODUCTS DRIVE OVERALL REVENUE.
-- OBSERVATIONS: PRODUCT LINES WITH HIGH SALES PERCENTAGES ARE CRITICAL. IF A FEW LINES DOMINATE, DIVERSIFY OFFERINGS OR NURTURE EMERGING PRODUCTS. LOW-SHARE LINES MAY REQUIRE PRICING REVIEWS, ENHANCEMENTS, OR DISCONTINUATION.

WITH product_sales AS (
    SELECT
        p.product_line,
        COUNT(*) AS total_orders,
        SUM(s.order_value) AS sales_amount,
        SUM(s.order_quantity) AS total_units_sold
    FROM fact_sales s
    LEFT JOIN dim_products p
    ON s.product_id = p.product_id
    GROUP BY 1
    ORDER BY 3 DESC
)
SELECT
    product_line,
    total_orders,
    sales_amount,
    total_units_sold,
    ROUND(sales_amount / SUM(sales_amount) OVER() * 100, 0) AS pct_sales
FROM product_sales
GROUP BY 1, 2, 3, 4;

-- 4.4 CUSTOMERS --
-- THIS QUERY DETAILS SALES AND UNIT METRICS BY CUSTOMER, QUANTIFYING EACH CUSTOMER'S CONTRIBUTION TO THE WHOLE.
-- OBSERVATIONS: A FEW CUSTOMERS MAY DOMINATE SALES, POSING CONCENTRATION RISKS. HIGH-VALUE CUSTOMERS WARRANT RETENTION EFFORTS; LOW-SHARE CUSTOMERS MIGHT BE CANDIDATES FOR UPSELLING. REVIEW CUSTOMER MIX REGULARLY TO MAINTAIN RESILIENCE.

WITH customer_sales AS (
    SELECT
        c.customer_name,
        COUNT(*) AS total_orders,
        SUM(s.order_value) AS sales_amount,
        SUM(s.order_quantity) AS total_units_sold
    FROM fact_sales s
    LEFT JOIN dim_customers c
    ON s.customer_id = c.customer_id
    GROUP BY 1
    ORDER BY 3 DESC
)
SELECT
    customer_name,
    total_orders,
    sales_amount,
    total_units_sold,
    ROUND(sales_amount / SUM(sales_amount) OVER() * 100, 1) AS pct_sales
FROM customer_sales
GROUP BY 1, 2, 3, 4;

-- 5. COHORT ANALYSIS --
-- THIS SECTION EXPLORES ORDER PATTERNS AND PRODUCT SEGMENTS, GROUPING CUSTOMERS OR ORDERS BY LIFECYCLE AND PRICE RANGE.
-- OBSERVATIONS: COHORT SEGMENTATION UNCOVERS BEHAVIOR AMONG GROUPS BASED ON RECENCY OR VALUE. IDENTIFY DORMANT USERS, LOYAL SEGMENTS, AND PRICE SENSITIVITIES. USE FINDINGS TO INFORM RETENTION STRATEGIES, TARGETED OFFERS, AND PRODUCT DEVELOPMENT.

-- 5.1 LAST ORDERS --
-- THIS ANALYSIS SEGMENTS CUSTOMERS BY TIME SINCE THEIR LAST ORDER, CATEGORIZING THEM INTO QUARTILES AND YEARLY BANDS.
-- OBSERVATIONS: MOST CUSTOMERS IN RECENT COHORTS SIGNAL STRONG ENGAGEMENT. A GROWING ‘ABOVE YEAR’ COHORT SUGGESTS ATTRITION OR INACTIVITY, WARRANTING RE-ENGAGEMENT. COMPARE DISTRIBUTIONS TO MEASURE LOYALTY AND LIFECYCLE STRENGTH.

WITH last_orders AS (
    SELECT
        days_since_last_order,
        CASE
            WHEN days_since_last_order < 90 THEN 'Quarter'
            WHEN days_since_last_order >= 90 AND days_since_last_order < 180 THEN 'Half Year'
            WHEN days_since_last_order >= 180 AND days_since_last_order < 365 THEN 'Year'
            ELSE 'Above Year'
        END AS cohort,
        COUNT(*) AS total_orders
    FROM fact_sales
    GROUP BY 1, 2
    ORDER BY 1 DESC
)
SELECT
    cohort,
    COUNT(*) AS total_orders
FROM last_orders
GROUP BY 1
ORDER BY 2 DESC;

-- 5.2 ORDER BY PRODUCT PRICE --
-- THIS QUERY GROUPS ORDERS AND PRODUCTS INTO PRICE SEGMENTS (LOW, MEDIUM, HIGH) BASED ON PRODUCT PRICE.
-- OBSERVATIONS: THE SEGMENT DISTRIBUTION HELPS UNDERSTAND SALES CONCENTRATION IN PRICE BANDS, SHOWING CUSTOMER WILLINGNESS TO PAY. A DOMINANT SEGMENT CAN INFORM PRICING STRATEGIES, PRODUCT LAUNCHES, AND PROMOTIONAL TARGETING.

WITH price_segment AS (
    SELECT
        s.product_id,
        p.product_price AS price,
        CASE 
            WHEN p.product_price < 50000 THEN 'Low Segment'
            WHEN p.product_price BETWEEN 50000 AND 100000 THEN 'Medium Segment'
            ELSE 'High Segment' 
        END AS segment
    FROM fact_sales s
    LEFT JOIN dim_products p
    ON s.product_id = p.product_id
)
SELECT
    segment,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT product_id) AS total_products
FROM price_segment
GROUP BY 1
ORDER BY 2 DESC;

-- 6. BUILDING A REPORT -- 
-- THIS SECTION COMPILES KEY PERFORMANCE METRICS ACROSS MAJOR BUSINESS DIMENSIONS: LOCATION, CUSTOMER, AND PRODUCT.
-- OBSERVATIONS: USE THESE REPORTS TO DRILL INTO OPERATIONAL DRIVERS AT A GRANULAR LEVEL. LOCATION INSIGHTS UNCOVER REGIONAL STRENGTHS AND GROWTH OPPORTUNITIES, CUSTOMER STATS IDENTIFY ENGAGEMENT AND REVENUE CONCENTRATION, AND PRODUCT ANALYSIS DETECTS SALES LEADERS AND DISTRIBUTION TRENDS. STRATEGIC REVIEW OF THESE REPORTS HELPS OPTIMIZE RESOURCE ALLOCATION, MARKETING FOCUS, AND INVENTORY PLANNING FOR SUSTAINED GROWTH.

-- 6.1 LOCATION REPORT --
-- THIS REPORT SUMMARIZES SALES AND ORDER ACTIVITY BY COUNTRY AND CITY, PROVIDES EACH CITY’S SHARE OF ITS NATION’S MARKET, AND PREDICTS THE NEXT EXPECTED ORDER DATE.
-- OBSERVATIONS: CITIES WITH HIGH MARKET SHARE WITHIN A COUNTRY SIGNAL KEY HUBS; THOSE WITH LOWER SHARES MAY BENEFIT FROM ATTENTION OR EXPANSION. AVERAGE ORDER VALUES AND PREDICTED ORDER DATES SUPPORT SALES PLANNING AND CUSTOMER RE-ENGAGEMENT IN EACH REGION.

WITH base_querry AS (
    SELECT
        a.country,
        a.city,
        COUNT(DISTINCT s.order_id) AS total_orders,
        SUM(s.order_value) AS total_sales,
        MAX(s.order_date) AS last_order_date,
        ROUND(AVG(s.days_since_last_order), 0) AS avg_days_between_orders,
        DATEDIFF(CURRENT_DATE, MAX(s.order_date)) AS days_since_last_order
    FROM fact_sales s
    LEFT JOIN dim_address a
    ON s.address_id = a.address_id
    GROUP BY a.country, a.city
)
SELECT
    country,
    city,
    CONCAT(ROUND(total_orders / SUM(total_orders) OVER(PARTITION BY country) * 100, 0), '%') AS part_of_nation_market,
    total_sales,
    ROUND(total_sales/total_orders, 0) AS avg_order_value,
    DATE_ADD(last_order_date, CAST(avg_days_between_orders AS INT)) AS next_order_prediction
FROM base_querry;

-- 6.2 CUSTOMER REPORT --
-- THIS REPORT DETAILS CUSTOMER-LEVEL METRICS INCLUDING ORDERS, SALES, AVERAGE ORDER VALUE, AND LAST ORDER DATE.
-- OBSERVATIONS: TRACK TOP CUSTOMERS TO PRIORITIZE RETENTION EFFORTS. LOW-ORDER CUSTOMERS MIGHT BE TARGETED FOR UPSELLING OR ENGAGEMENT CAMPAIGNS. REVIEWING LAST ORDER DATES SUPPORTS OUTREACH STRATEGIES AND LOYALTY INITIATIVES.

WITH base_query AS (
    SELECT 
        c.customer_name,
        CONCAT(c.contact_first_name, ' ', c.contact_last_name) AS customer_full_name,
        COUNT(DISTINCT s.order_id) AS total_orders,
        SUM(s.order_value) AS total_sales,
        MAX(s.order_date) AS last_order_date
    FROM fact_sales s
    LEFT JOIN dim_customers c
    ON s.customer_id = c.customer_id
    GROUP BY 1, 2
    ORDER BY 3 DESC, 4 DESC
)
SELECT
    customer_name,
    customer_full_name,
    total_orders,
    total_sales,
    ROUND(total_sales/total_orders, 0) AS avg_order_value,
    last_order_date
FROM base_query;

-- 6.3 PRODUCT REPORT -- 
-- THIS REPORT RANKS PRODUCTS BY SALES AND ORDER ACTIVITY, INCLUDING RECENT ORDERING ACTIVITY AND PRODUCT LINE AVERAGES.
-- OBSERVATIONS: IDENTIFY TOP SELLERS AND PRODUCT LINES WITH HEALTHY AVERAGE ORDER VOLUMES. OUTLIERS MAY WARRANT PRODUCT DEVELOPMENT, PRICING REVIEW, OR INVENTORY ADJUSTMENT. HIGH-VOLUME LINES SUGGEST MAJOR SALES CHANNELS, WHILE WEAKER LINES MIGHT NEED SUPPORT OR REEVALUATION.

WITH base_query AS (
    SELECT 
        p.product_line,
        p.product_code,
        s.item_price AS price,
        s.order_quantity,
        MAX(order_date) AS last_order,
        COUNT(s.order_id) AS total_orders,
        SUM(s.order_value) AS total_sales
    FROM fact_sales s
    LEFT JOIN dim_products p
    ON s.product_id = p.product_id
    GROUP BY 1, 2, 3, 4
)
SELECT
    product_line,
    product_code,
    price,
    order_quantity AS order_volume,
    total_orders,
    total_sales,
    ROUND(total_sales/total_orders, 0) AS avg_order_value,
    ROUND(AVG(order_quantity) OVER(PARTITION BY product_line), 0) AS avg_order_by_product_line,
    last_order
FROM base_query
ORDER BY total_sales DESC;
