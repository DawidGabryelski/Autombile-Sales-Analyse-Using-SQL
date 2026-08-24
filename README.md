# Sales Data Analysis: SQL Insights & EDA

## 1. Project Introduction
Welcome to the **Sales Data Analysis** project. This repository focuses on transforming raw transactional data into actionable business insights through rigorous Exploratory Data Analysis (EDA) and subsequent SQL-based analytics.

The primary objective of this project is to explore the underlying patterns within sales performance and customer purchasing behavior. By leveraging a structured relational star schema, this analysis aims to identify key trends, operational bottlenecks, and opportunities for revenue optimization.

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

---

## 3. Advanced Analysis

Building upon the exploratory findings, the advanced analysis phase dives deeper into temporal trends, cumulative performance, comparative growth metrics, part-to-whole segment contributions, customer cohorts, and structured reporting views.

### 3.1 Time Analysis
*   **Temporal Breakdown**: Aggregates total orders, sales revenue, and units sold grouped by year and month.
*   **Business Value**: Helps identify seasonal patterns, peak demand periods, and the impact of promotional events or new product launches over time.

### 3.2 Cumulative Analysis
*   **Running Totals**: Utilizes window functions (`SUM() OVER (ORDER BY ...)`) on monthly aggregated sales and unit volumes.
*   **Business Value**: Tracks sustained business growth trajectories, revealing acceleration periods or stagnation in off-peak months.

### 3.3 Comparative Analysis
*   **Year-over-Year (YoY) Summary**: Compares annual revenue and units against prior years using `LAG()`, calculating percentage growth to benchmark strategic progress.
*   **Month-over-Month (MoM) Summary**: Tracks granular short-term momentum changes and seasonal surges to support agile operational and resource planning.

### 3.4 Part-to-Whole Analysis
*   **Dimensional Share**: Measures the revenue and unit contribution percentage of individual segments relative to the overall business using window ratios (`sales_amount / SUM(sales_amount) OVER()`).
*   **Key Segments**: Broken down across **Countries**, **Cities**, **Product Lines**, and **Customers** to uncover concentration risks and identify key growth strongholds.

### 3.5 Cohort Analysis
*   **Customer Recency**: Segments orders and customers based on time elapsed since their last purchase (`days_since_last_order`) into quartiles (Quarter, Half Year, Year, Above Year) to track engagement and attrition.
*   **Price Segment Clustering**: Categorizes orders and products into price bands (*Low Segment* < 50k, *Medium Segment* 50k–100k, *High Segment* > 100k) to analyze customer willingness to pay.

### 3.6 Business Reporting Views
*   **Location Report**: Summarizes regional order activity, market share within nations, average order values, and predicted next order dates (`DATE_ADD`).
*   **Customer Report**: Details client-level metrics including total orders, revenue contributions, average order values, and last purchase dates to prioritize retention and upselling.
*   **Product Report**: Ranks products by sales performance, volume, and line averages to highlight top sellers and identify items requiring pricing or inventory reevaluation.

---

## 4. Summary & Business Impact

The combination of rigorous exploratory data analysis and advanced SQL querying provided a 360-degree view of operational performance:

*   **Data Reliability & Structure**: The star schema architecture proved robust, ensuring seamless integration between transactional records (`fact_sales`) and contextual dimensions (`dim_address`, `dim_customers`, `dim_products`).
*   **Revenue Concentration & Risk**: Part-to-whole and ranking analyses revealed clear pockets of high-value concentration (VIP customers and top-performing cities), highlighting both major revenue drivers and potential dependency risks.
*   **Actionable Intelligence**: Cohort tracking and structured reporting views (such as order recency and predictive next-order dates) bridge the gap between historical reporting and proactive sales management, establishing a solid foundation for inventory forecasting, targeted marketing, and customer retention strategies.

#### Data Source - https://www.kaggle.com/datasets/ddosad/auto-sales-data
