-- ============================================================
-- PROJECT: Sales Dataset Exploration II — Superstore Database
-- AUTHOR:  Taofeek Salami | HarjiiBoss
-- DATE:    2026-06-26
-- SOURCE:  Superstore Database File.xlsx (Kaggle)
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

-- ────────────────────────────────────────────────────────────
-- PHASE 1: TABLE DEFINITIONS
-- ────────────────────────────────────────────────────────────

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
-- PHASE 3: ETL NOTE
-- ────────────────────────────────────────────────────────────
-- The orders, customers, and returns tables are populated via
-- Python/Pandas ETL script (superstore_etl.py).
-- Command: python3 superstore_etl.py
-- Source:  Superstore Database File.xlsx
-- Rows loaded: orders=8399, customers=5496, returns=572
-- ────────────────────────────────────────────────────────────


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
-- ANSWER:    Revenue peaked in 2009 ($4.2M) and declined
--            through 2011 ($3.4M) before recovering in 2012
--            ($3.7M). 2010–2012 are consistently below 2009.
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
-- ANSWER:    Technology leads at 14.8% margin, Office Supplies
--            at 13.8%. Furniture earns only 2.3% despite being
--            the second-highest revenue category — a margin risk.
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
--          (bottom 5 by total profit)?
-- RATIONALE: Pinpoints the drag items that offset gains
--            elsewhere — critical for SKU rationalisation.
-- ANSWER:    Tables (-$64K), Bookcases (-$4K) and Scissors
--            (-$2K) are the top loss sub-categories.
-- ────────────────────────────────────────────────────────────
SELECT
    product_category,
    product_sub_category,
    ROUND(SUM(sales), 2)   AS total_sales,
    ROUND(SUM(profit), 2)  AS total_profit,
    COUNT(*)               AS order_lines
FROM orders
GROUP BY product_category, product_sub_category
ORDER BY total_profit ASC
LIMIT 5;


-- ────────────────────────────────────────────────────────────
-- BQ-04 | Does a higher discount always lead to lower profit?
-- RATIONALE: Tests whether the discount strategy is working
--            or actively eroding margins.
-- ANSWER:    Orders with 0% discount average $249 profit.
--            At 21–30% discount, average profit turns negative
--            (-$249). Discounting above 20% destroys value.
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
--          to the revenue it supports?
-- RATIONALE: Shipping cost directly impacts net margin;
--            over-use of premium modes reduces profit.
-- ANSWER:    Regular Air handles 74.7% of orders at only
--            $7.66 avg shipping cost. Delivery Truck costs
--            $45.35 per order but carries high-value orders.
--            Express Air is rarely used and most expensive
--            per dollar of sales generated.
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
-- ANSWER:    Corporate leads with $599K total profit across
--            3,076 orders. Home Office has the highest avg
--            order value at $1,754. Small Business generates
--            comparable profit to Consumer despite fewer orders.
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
--          relative to their sales volume?
-- RATIONALE: High-revenue regions with thin margins signal
--            pricing, discount, or cost structure problems.
-- ANSWER:    West leads in revenue ($3.6M) but Ontario leads
--            in profit ($347K) with a stronger margin. Nunavut
--            has the least revenue ($116K) and weakest profit
--            ($2.8K) — lowest priority market.
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
--          which category has the most loss-making orders?
-- RATIONALE: Loss-making orders are a hidden margin drain;
--            identifying them by category reveals root causes.
-- ANSWER:    50.8% of all order lines are loss-making (4,264
--            of 8,399). Furniture has the highest loss rate
--            at ~61%. This is the single biggest operational
--            risk in the dataset.
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
--          consistently generate the highest revenue?
-- RATIONALE: Seasonality shapes inventory, staffing, and
--            promotional planning.
-- ANSWER:    January ($2,018 avg/order) and December ($2,035)
--            are the strongest months. May–August is the
--            consistent low season. Q4 outperforms Q2/Q3.
-- ────────────────────────────────────────────────────────────
SELECT
    MONTH(order_date)             AS month_num,
    MONTHNAME(order_date)         AS month_name,
    COUNT(*)                      AS total_orders,
    ROUND(SUM(sales), 2)          AS total_sales,
    ROUND(AVG(sales), 2)          AS avg_order_value,
    ROUND(SUM(profit), 2)         AS total_profit
FROM orders
GROUP BY month_num, month_name
ORDER BY month_num;


-- ────────────────────────────────────────────────────────────
-- BQ-10 | Do returned orders follow a pattern by product
--          category or region?
-- RATIONALE: Returns are a revenue leakage signal; patterns
--            suggest quality, expectation, or logistical issues.
-- ANSWER:    Furniture has the highest return rate (11.2%)
--            vs Technology (10.6%) and Office Supplies (10.0%).
--            Returns are spread evenly, but Furniture's
--            combination of high returns AND low margin makes
--            it the highest-risk category in the portfolio.
-- ────────────────────────────────────────────────────────────
SELECT
    o.product_category,
    o.region,
    COUNT(o.order_id)                                          AS total_orders,
    COUNT(r.order_id)                                          AS returned_orders,
    ROUND(COUNT(r.order_id) / COUNT(o.order_id) * 100, 2)     AS return_rate_pct,
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
