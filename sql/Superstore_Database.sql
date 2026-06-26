-- ============================================================
-- PROJECT: Sales Dataset Exploration II — Superstore Database
-- AUTHOR:  Taofeek Salami
-- DATE:    2026-06-26
-- SOURCE:  Superstore Database File.xlsx
-- ============================================================
-- DESCRIPTION:
--   Creates and populates the `superstore` MySQL database with
--   four normalised tables derived from the Excel source file.
--   Followed by 10 self-generated business questions answered
--   with production-ready SQL queries.
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- PHASE 0: DATABASE SETUP
-- ────────────────────────────────────────────────────────────

CREATE DATABASE IF NOT EXISTS superstore
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE superstore;

-- Table 1: orders (central fact table — 8,399 rows)
CREATE TABLE IF NOT EXISTS orders (
    row_id              INT            NOT NULL,
    order_id            INT            NOT NULL,
    order_date          DATE           NOT NULL,
    ship_date           DATE           NOT NULL,
    order_priority      VARCHAR(20)    NOT NULL,
    order_quantity      INT            NOT NULL,
    sales               DECIMAL(12,4)  NOT NULL,
    discount            DECIMAL(5,4)   NOT NULL DEFAULT 0,
    ship_mode           VARCHAR(30)    NOT NULL,
    profit              DECIMAL(12,4)  NOT NULL,
    unit_price          DECIMAL(10,4)  NOT NULL,
    shipping_cost       DECIMAL(10,4)  NOT NULL,
    province            VARCHAR(50)    NOT NULL,
    region              VARCHAR(30)    NOT NULL,
    customer_segment    VARCHAR(30)    NOT NULL,
    product_category    VARCHAR(30)    NOT NULL,
    product_sub_category VARCHAR(60)   NOT NULL,
    product_name        VARCHAR(255)   NOT NULL,
    product_container   VARCHAR(30)    NOT NULL,
    product_base_margin DECIMAL(5,4)   NULL,
    PRIMARY KEY (row_id),
    INDEX idx_order_id   (order_id),
    INDEX idx_order_date (order_date),
    INDEX idx_region     (region),
    INDEX idx_category   (product_category),
    INDEX idx_segment    (customer_segment)
);

-- Table 2: customers (5,496 rows — order-level customer map)
CREATE TABLE IF NOT EXISTS customers (
    id            INT          NOT NULL AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    order_id      INT          NOT NULL,
    PRIMARY KEY (id),
    INDEX idx_customer_order (order_id)
);

-- Table 3: returns (572 rows)
CREATE TABLE IF NOT EXISTS returns (
    id       INT         NOT NULL AUTO_INCREMENT,
    order_id INT         NOT NULL,
    status   VARCHAR(20) NOT NULL DEFAULT 'Returned',
    PRIMARY KEY (id),
    INDEX idx_return_order (order_id)
);

-- Table 4: regional_managers (8 rows)
CREATE TABLE IF NOT EXISTS regional_managers (
    id      INT         NOT NULL AUTO_INCREMENT,
    region  VARCHAR(30) NOT NULL,
    manager VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);

-- ────────────────────────────────────────────────────────────
-- PHASE 2: SAMPLE DATA (first 10 orders shown for brevity)
--          In practice: use MySQL LOAD DATA or Python ETL
-- ────────────────────────────────────────────────────────────

-- Regional managers seed data (complete — 8 rows)
INSERT INTO regional_managers (region, manager) VALUES
  ('Central', 'Chris'),
  ('East',    'Erin'),
  ('South',   'Sam'),
  ('West',    'William'),
  ('West',    'Pat'),
  ('Central', 'Pat'),
  ('East',    'Pat'),
  ('South',   'Pat');
  
-- ────────────────────────────────────────────────────────────
-- PHASE 3: ETL AUTOMATION & DOCUMENTATION
-- ────────────────────────────────────────────────────────────
-- DESCRIPTION:
--   The production tables (`orders`, `customers`, and `returns`)
--   were successfully populated utilizing an automated Python/Pandas
--   ETL pipeline to handle data type mapping and normalization.
--
-- EXECUTION METHOD DETAILS:
--   • Pipeline Script:  superstore_database.ipynb (Jupyter Notebook Notebook Engine)
--   • Data Connector:  SQLAlchemy + mysql-connector-python
--   • Target Database:  superstore (MySQL 8.0+ Local Instance)
--
-- METRICS & AUDIT LOG:
--   • Data Source:      Superstore Database File.xlsx
--   • Orders Loaded:    8,399 rows (Central Fact Table)
--   • Customers Loaded: 5,496 rows (Normalized Order-Customer Map)
--   • Returns Loaded:   572 rows   (Transaction Status Sync)
--   • Status:           Execution Complete — 100% Integrity Confirmed.
-- ────────────────────────────────────────────────────────────

SELECT * 
FROM orders
LIMIT 10;

SELECT * 
FROM customers
LIMIT 10;

SELECT * 
FROM returns
LIMIT 10;

-- ============================================================
-- PHASE 4: 10 BUSINESS QUESTIONS
-- ============================================================
-- Each question follows the format:
--   -- BQ-XX | QUESTION
--   -- RATIONALE: why this matters
--   -- ANSWER:    what the data shows
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- BQ-01 | How has total revenue trended year-over-year?
-- RATIONALE: Identifies whether the business is growing,
--            stagnating, or declining at the top line.
-- ANSWER:    Revenue peaked in 2009 ($4.21M), declined through
--            2011 ($3.44M), then recovered to $3.72M in 2012,
--            although it remained below the 2009 peak.
-- ────────────────────────────────────────────────────────────
SELECT
    YEAR(order_date)            AS order_year,
    ROUND(SUM(sales), 2)        AS total_revenue,
    COUNT(DISTINCT order_id)    AS total_orders,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM orders
GROUP BY order_year
ORDER BY order_year;


-- ────────────────────────────────────────────────────────────
-- BQ-02 | Which product category generates the highest
--          profit margin?
-- RATIONALE: Margin — not revenue — shows where the business
--            actually creates value.
-- ANSWER:    Technology delivers the highest profit margin (14.8%),
--            followed by Office Supplies (13.8%). Despite generating
--            the second-highest revenue, Furniture achieves only
--            a 2.3% margin, indicating that strong sales are not
--            are not translating into profitability.
-- ────────────────────────────────────────────────────────────
SELECT
    product_category,
    ROUND(SUM(sales), 2)                                AS total_sales,
    ROUND(SUM(profit), 2)                               AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)            AS profit_margin_pct
FROM orders
GROUP BY product_category
ORDER BY profit_margin_pct DESC;


-- ────────────────────────────────────────────────────────────
-- BQ-03 | Which product sub-categories are destroying profit
--         (bottom 5 by total profit)?
-- RATIONALE: Pinpoints the drag items that offset gains
--            elsewhere — critical for SKU rationalisation.
-- ANSWER:    Tables (-$99.1K) is by far the largest loss-making sub-category,
--            followed by Bookcases (-$33.6K) and Scissors, Rulers & Trimmers (-$7.8K).
--            Only four sub-categories generate net losses, with
--            Tables accounting for the vast majority of the profit drag.   
-- ────────────────────────────────────────────────────────────
SELECT
    product_category,
    product_sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(*) AS order_lines
FROM orders
GROUP BY product_category, product_sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 5;


-- ────────────────────────────────────────────────────────────
-- BQ-04 | Does a higher discount always lead to lower profit?
-- RATIONALE: Tests whether the discount strategy is working
--            or actively eroding margins.
-- ANSWER:    Orders with no discount average $248.93 profit.
--            In this dataset, the small number of orders discounted above 20%
--            had negative average profit (-$249.40), suggesting deep
--            discounts may erode profitability. More data is needed
--            before making a firm conclusion.
-- ────────────────────────────────────────────────────────────
SELECT
    CASE
        WHEN discount = 0            THEN '0% (No Discount)'
        WHEN discount <= 0.10        THEN '1–10%'
        WHEN discount <= 0.20        THEN '11–20%'
        WHEN discount <= 0.30        THEN '21–30%'
        ELSE '31%+'
    END                              AS discount_bucket,
    COUNT(*)                         AS order_count,
    ROUND(AVG(sales), 2)             AS avg_sales,
    ROUND(AVG(profit), 2)            AS avg_profit,
    ROUND(SUM(profit), 2)            AS total_profit
FROM orders
GROUP BY discount_bucket
ORDER BY MIN(discount);


-- ────────────────────────────────────────────────────────────
-- BQ-05 | Which shipping mode is most cost-efficient relative
--         to the revenue it supports?
-- RATIONALE: Shipping cost directly impacts net margin;
--            over-use of premium modes reduces profit.
-- ANSWER:    Regular Air is the most cost-efficient shipping mode,
--            handling 74.7% of orders while shipping costs represent
--            just 0.64% of sales. Delivery Truck has the highest
--            average shipping cost ($45.35/order) and the highest shipping
--            cost relative to sales (0.83%), though it supports
--            high-value orders. Express Air is used less frequently and
--            performs similarly to Regular Air in shipping cost
-- 			  as a percentage of sales (0.66%).
-- ────────────────────────────────────────────────────────────
SELECT
    ship_mode,
    COUNT(*)                                             AS order_count,
    ROUND(AVG(shipping_cost), 2)                         AS avg_shipping_cost,
    ROUND(SUM(sales), 2)                                 AS total_sales,
    ROUND(SUM(shipping_cost) / SUM(sales) * 100, 2)      AS shipping_cost_pct_of_sales
FROM orders
GROUP BY ship_mode
ORDER BY avg_shipping_cost DESC;


-- ────────────────────────────────────────────────────────────
-- BQ-06 | Which customer segment is most profitable, and
--          what is their average order value?
-- RATIONALE: Knowing which segment drives margin guides
--            sales team prioritisation and CRM strategy.
-- ANSWER:    Corporate is the most profitable customer segment, generating
--            approximately $600K in total profit across 2,002 orders with
--            a 10.91% profit margin. Consumer customers have the highest
--            average order value ($2,847), while Small Business achieves the
--            highest profit margin (11.32%), indicating strong profitability
--            despite fewer orders.
-- ────────────────────────────────────────────────────────────
SELECT
    customer_segment,
    COUNT(DISTINCT order_id)                             AS total_orders,
    ROUND(SUM(sales), 2)                                 AS total_sales,
    ROUND(SUM(profit), 2)                                AS total_profit,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)      AS avg_order_value,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)             AS profit_margin_pct
FROM orders
GROUP BY customer_segment
ORDER BY total_profit DESC;


-- ────────────────────────────────────────────────────────────
-- BQ-07 | Which regions are underperforming on profit margin
--         relative to their sales volume?
-- RATIONALE: High-revenue regions with thin margins signal
--            pricing, discount, or cost structure problems.
-- ANSWER:    West generates the highest revenue ($3.6M) but has a relatively
--            modest 8.26% profit margin, indicating potential pricing
--            or cost optimization opportunities. Nunavut is the weakest-performing
--            region, with both the lowest sales ($116K) and the lowest
--            profit margin (2.44%). In contrast, Ontario and Prairie
--            combine strong sales with healthy 11.32% margins, while
--            Northwest Territories achieves the highest margin (12.57%)
-- 			  despite lower sales volume.
-- ────────────────────────────────────────────────────────────
SELECT
    region,
    COUNT(DISTINCT order_id)                             AS total_orders,
    ROUND(SUM(sales), 2)                                 AS total_sales,
    ROUND(SUM(profit), 2)                                AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2)             AS profit_margin_pct
FROM orders
GROUP BY region
ORDER BY total_sales DESC;


-- ────────────────────────────────────────────────────────────
-- BQ-08 | What share of orders result in a net loss, and
--         which category has the most loss-making orders?
-- RATIONALE: Loss-making orders are a hidden margin drain;
--            identifying them by category reveals root causes.
-- ANSWER:    Approximately 50.8% of all order lines are loss-making (4,264 of 8,399).
--            Furniture is the highest-risk category, with 53.5% of orders
--            generating losses and the largest cumulative loss (-$435.6K).
--            Office Supplies has a nearly identical loss rate (53.4%) but a smaller
--            finacial impact, while Technology records fewer loss-making orders (42.7%)
--            yet still incurs substantial total losses (-$382.4K).
-- ────────────────────────────────────────────────────────────
SELECT
    product_category,
    COUNT(*)                                                     AS total_orders,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END)                 AS loss_orders,
    ROUND(SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END)
          / COUNT(*) * 100, 1)                                   AS loss_rate_pct,
    ROUND(SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END), 2)  AS total_loss_amount
FROM orders
GROUP BY product_category
ORDER BY loss_rate_pct DESC;


-- ────────────────────────────────────────────────────────────
-- BQ-09 | Is there a seasonal sales pattern — which months
--         consistently generate the highest revenue?
-- RATIONALE: Seasonality shapes inventory, staffing, and
--            promotional planning.
-- ANSWER:    December is the strongest month, generating $1.47M in sales
--            (9.84% of annual revenue) with the highest average order value ($2,035).
--            January follows closely with $1.44M in sales (9.69%) and a $2,018
--            average order value. Sales soften from May through August,
--            particularly in June (6.91% of annual revenue), before
--            rebounding through Q4.
-- ────────────────────────────────────────────────────────────
SELECT
    MONTH(order_date)             AS month_num,
    MONTHNAME(order_date)         AS month_name,
    COUNT(*)                      AS total_orders,
    ROUND(SUM(sales), 2)          AS total_sales,
    ROUND(AVG(sales), 2)          AS avg_order_value,
    ROUND(SUM(profit), 2)         AS total_profit,
    ROUND(SUM(sales) /
    (SELECT SUM(sales) 
    FROM orders) * 100,2) 		  AS sales_share_pct
FROM orders
GROUP BY month_num, month_name
ORDER BY month_num;


-- ────────────────────────────────────────────────────────────
-- BQ-10 | Do returned orders follow a pattern by product
--          category or region?
-- RATIONALE: Returns are a revenue leakage signal; patterns
--            suggest quality, expectation, or logistical issues.
-- ANSWER:    Technology in Ontario (13.73%) and Furniture in Yukon (13.64%) record
--            the highest return rates. Most major regions fall within a 9–13% return range,
--            while Nunavut’s low rates reflect a much smaller order base.
--            Combined with Furniture’s high loss rate and relatively lower profitability
--            from earlier analyses, elevated return rates reinforce Furniture
--            as the portfolio’s highest operational risk category.
-- ────────────────────────────────────────────────────────────
SELECT
    o.product_category,
    o.region,
    COUNT(DISTINCT o.order_id) 								   AS total_orders,
    COUNT(DISTINCT r.order_id) 								   AS returned_orders,
    ROUND(COUNT(r.order_id) / COUNT(o.order_id) * 100, 2)      AS return_rate_pct,
    ROUND(SUM(o.sales), 2)                                     AS total_sales,
    ROUND(SUM(o.profit), 2)                                    AS total_profit
FROM orders o
LEFT JOIN returns r ON o.order_id = r.order_id
GROUP BY o.product_category, o.region
ORDER BY return_rate_pct DESC;


-- ============================================================
-- END OF FILE
-- superstore_database.sql | Version 1.0 | 2026-06-26
-- ============================================================
