# 🛒 Superstore Database — Sales Dataset Exploration II

An end-to-end data analytics project built on a Canadian retail superstore dataset (2009–2012). This project demonstrates the complete analytics workflow—from **database design** and **Python ETL** to **SQL-based business analysis**—through 10 self-defined business questions that uncover actionable insights into sales performance, profitability, customer behavior, and operational efficiency.

---

## 📁 Repository Structure

```
Superstore_Database/
├── notebook/
│   └── superstore_database.ipynb   # Python ETL pipeline (Excel → MySQL)
├── sql/
│   └── superstore_database.sql     # Database schema + 10 business questions
└── outputs/
    └── (query result exports)
```

---

## 🗂️ Dataset

| Attribute | Detail |
|---|---|
| **Source** | Superstore Database File.xlsx (Kaggle) |
| **Coverage** | Canadian retail chain (January 2009 – December 2012) |
| **Worksheets** | Orders, Customer Name, Returns, Users |

---

## 🏗️ Database Schema

**Database:** `superstore`  
**Database Engine:** MySQL 8.0+ (`utf8mb4` character set)

| Table | Rows | Description |
|---|---:|---|
| `orders` | 8,399 | Central fact table containing sales transactions (21 columns, 5 indexes) |
| `customers` | 5,496 | Customer name lookup table linked to orders |
| `returns` | 572 | Returned order records |
| `regional_managers` | 8 | Region-to-manager reference table |

### Schema Highlights

- Optimized with five indexes on:
  - `order_id`
  - `order_date`
  - `region`
  - `product_category`
  - `customer_segment`
- `product_base_margin` is nullable (63 missing values documented).
- Monetary fields are stored as `DECIMAL(12,4)` to preserve financial precision.
- Customer information is normalized into a separate table to reduce redundancy.

---

## ⚙️ ETL Pipeline

**Notebook:** `notebook/superstore_database.ipynb`

The notebook performs the complete **Extract → Transform → Load (ETL)** workflow.

```python
# Libraries
pandas
sqlalchemy
mysql-connector-python

# Connection
mysql+mysqlconnector://localhost:3306/superstore

# Workflow
1. Read all source worksheets from Excel
2. Standardize column names
3. Normalize customer data into a dedicated table
4. Load cleaned tables into MySQL using pandas.to_sql()
```

| Table | Rows Loaded | Status |
|---|---:|---|
| `orders` | 8,399 | ✅ Complete |
| `customers` | 5,496 | ✅ Complete |
| `returns` | 572 | ✅ Complete |

---

## ❓ Business Questions

Each query inside **`superstore_database.sql`** follows a consistent documentation format:

```sql
-- BQ-XX | QUESTION
-- RATIONALE: Why this question matters to the business
-- ANSWER:    Summary of the insights returned by the query

SELECT ...
```

| # | Business Question | Key Finding |
|---|---|---|
| **BQ-01** | How has total revenue trended year-over-year? | Revenue peaked at **$4.21M** in 2009 and declined to **$3.72M** by 2012. |
| **BQ-02** | Which product category has the highest profit margin? | Technology leads with a **14.8%** margin, while Furniture earns only **2.3%** despite generating **$5.18M** in sales. |
| **BQ-03** | Which sub-categories are destroying profit? | Tables alone lost **$99.1K**; all five worst-performing sub-categories are dominated by Furniture products. |
| **BQ-04** | Does a higher discount always lead to lower profit? | Discounts above **20%** push average order profit into negative territory. |
| **BQ-05** | Which shipping mode is the most cost-efficient? | Regular Air handles **74.7%** of orders while shipping costs account for only **0.64%** of sales. |
| **BQ-06** | Which customer segment is most profitable? | Corporate generates the highest total profit (~**$600K**), while Small Business records the highest profit margin (**11.32%**). |
| **BQ-07** | Which regions underperform on profit margin relative to sales? | West generates the highest revenue but only an **8.26%** margin, while Nunavut records the weakest profitability (**2.44%**). |
| **BQ-08** | What percentage of orders result in a net loss? | **50.8%** of all order lines are loss-making, with Furniture showing the highest loss rate (**53.5%**). |
| **BQ-09** | Is there a seasonal sales pattern? | December and January consistently deliver the strongest sales performance, while May–August forms the annual low season. |
| **BQ-10** | Do product returns follow a pattern by category or region? | Ontario and Yukon exhibit the highest return rates across Technology and Furniture, highlighting potential operational risk areas. |

---

## 🔍 SQL Techniques Demonstrated

This project showcases practical SQL techniques commonly used in business analytics:

- Aggregate analysis using `GROUP BY` and `HAVING`
- Conditional aggregation with `CASE WHEN`
- Multi-table analysis using `LEFT JOIN`
- Correlated subqueries
- Calculated business metrics:
  - Profit Margin (%)
  - Shipping Cost as % of Sales
  - Average Order Value (AOV)
  - Sales Share (%)
  - Return Rate (%)
- Proper use of `COUNT(*)` versus `COUNT(DISTINCT order_id)`
- Data bucketing for discount and profitability analysis
- Business-focused KPI calculations

---

## 📊 Key Business Insights

> All findings are derived directly from the dataset without assumptions beyond the query results.

- 📉 Revenue has steadily declined since its **2009 peak of $4.21M**.
- 🪑 Furniture is the portfolio's highest-risk category, combining:
  - the lowest profit margin,
  - the highest loss rate,
  - and elevated return rates.
- 💸 Discounts exceeding **20%** consistently eliminate profitability.
- ⚠️ **50.8%** of all order lines generate negative profit, representing the largest operational concern identified.
- 🌎 Northwest Territories achieves the strongest regional profit margin (**12.57%**) despite relatively modest sales.
- 👔 Corporate and Small Business customers deliver the strongest overall profitability and should remain key strategic segments.
- 📦 Regular Air provides the best balance between shipping cost and revenue generated.
- 📅 Sales exhibit clear seasonality, with demand recovering strongly during the fourth quarter.

---

## 🛠️ Tools & Technologies

| Layer | Technology |
|---|---|
| **Database** | MySQL 8.0+ |
| **Programming** | Python 3 |
| **Data Processing** | Pandas |
| **Database Connectivity** | SQLAlchemy, mysql-connector-python |
| **Analysis** | SQL (DDL & DML) |
| **Source Data** | Microsoft Excel (.xlsx) |
| **Development Environment** | Jupyter Notebook (Anaconda) |

---

## 👤 Author

**Taofeek Olawale Salami**

**Data Analyst** | SQL • Python • Excel • Tableau

GitHub: **[@HarjiiBoss](https://github.com/HarjiiBoss)**

---

*Completed as part of the Next Gen Cohort — 3MTT × Darey.io Human Capacity Development Program.*
