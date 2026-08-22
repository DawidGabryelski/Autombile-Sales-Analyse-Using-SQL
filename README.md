# Sales Data Analysis: SQL Insights & EDA

## 1. Project Introduction
Welcome to the **Sales Data Analysis** project. This repository focuses on transforming raw transactional data into actionable business insights through rigorous Exploratory Data Analysis (EDA) and subsequent SQL-based analytics.

The primary objective of this project is to explore the underlying patterns within sales performance, customer purchasing behavior, and product lifecycle dynamics. By leveraging a structured relational star schema, this analysis aims to identify key trends, operational bottlenecks, and opportunities for revenue optimization.

---

## 2. Exploratory Data Analysis (EDA)

The exploratory data analysis phase was structured into six sequential steps to validate the database architecture, assess data quality, and profile fundamental metrics before moving to advanced analytical modeling.

### 2.1 Database Exploration
*   **Database Structure**: Inspected the schema using `SHOW TABLES`, identifying a star schema comprising 4 core tables: 1 central fact table (`fact_sales`) and 3 dimension tables (`dim_address`, `dim_customers`, and `dim_products`).

### 2.2 Dimensions Exploration
*   **Address Dimension**: Profiled `dim_address`, revealing coverage across **19 countries, 71 cities, and 89 unique addresses**.
*   **Customer Dimension**: Confirmed a total of **89 unique clients** within the `dim_customers` table.
*   **Product Dimension**: Cataloged **109 unique product codes** distributed across **7 distinct product lines**.

### 2.3 Dates Exploration
*   **Temporal Range**: Established a date span from **January 6, 2018, to May 31, 2020**, providing **876 days** (approx. 2.4 years) of historical data for trend identification.

### 2.4 Measure Exploration
*   **Order Statistics**: Average order quantity is **35 units** (range 6–97), with a cumulative volume of **96,428 units sold**.
*   **Revenue Metrics**: Recorded a total revenue of **~9.76 billion**, with an average order value of **3.55 million**.
*   **Customer Recency**: Days since the last order range from 42 to 3,562 days, reflecting diverse purchasing cycles.

### 2.5 Magnitude Analysis
*   Aggregated sales and volume by geographic location, customer, and product line to identify key revenue drivers and market segments.

### 2.6 Top / Bottom Rank Analysis
*   **VIP Identification**: Used `RANK()` to isolate the top 5 revenue-generating customers.
*   **Performance Review**: Utilized `UNION ALL` to contrast top-performing products with bottom-tier items, identifying candidates for pricing reviews or discontinuation.
