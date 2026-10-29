# 🛒 Superstore Database — Sales Dataset Exploration II

An end-to-end data analytics project built on a Canadian retail superstore dataset (2009–2012). This project demonstrates the complete analytics workflow—from **database design** and **Python ETL** to **SQL-based business analysis**—through 10 self-defined business questions that uncover actionable insights into sales performance, profitability, customer behavior, and operational efficiency.

> **Status:** Complete (June 2026); figures re-checked and corrected in October 2026. 50.8% of the 8,399 order lines lost money, and Furniture earned a 2.3% margin on $5.18M in sales.

**Project page:** [taofeeksalami.com/Superstore_Database](https://taofeeksalami.com/Superstore_Database)

---

## 📊 Key Business Insights

> All findings are derived directly from the dataset without assumptions beyond the query results.

- 📉 Revenue fell from its **2009 peak of $4.21M** to **$3.44M** in 2011 and recovered to **$3.72M** in 2012, still **$489K** below the peak.
- 🪑 Furniture has the lowest profit margin (**2.3%**), the highest share of loss-making lines (**53.5%**) and the largest total loss (**−$436K**) of the three categories. Its return rate (**10.9%** of orders) is only slightly above Technology's (**10.5%**) and Office Supplies' (**10.1%**).
- 💸 Discounted order lines earn less on average, but only 5 order lines carry a discount above 10%, too few to fix a discount threshold.
- ⚠️ **50.8%** of all order lines generate negative profit, representing the largest operational concern identified.
- 🌎 Northwest Territories achieves the strongest regional profit margin (**12.57%**) despite relatively modest sales.
- 👔 Corporate has the highest total profit (about **$600K**) and Small Business the highest margin (**11.32%**).
- 📦 Regular Air carries **74.7%** of order lines at the lowest shipping cost relative to sales (**0.64%**).
- 📅 December (**9.84%** of sales) and January (**9.69%**) are the strongest months; June (**6.91%**) is the weakest.

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
| **BQ-03** | Which sub-categories are destroying profit? | Tables alone lost **$99.1K** (−5.2% margin). Four sub-categories made a net loss: two in Furniture (Tables, Bookcases) and two in Office Supplies. |
| **BQ-04** | Does a higher discount always lead to lower profit? | Order lines with no discount average **$249** profit; the two order lines at 21–30% average **−$249**. Only **5** order lines carry a discount above 10%, so the break-even point is not well estimated. |
| **BQ-05** | Which shipping mode is the most cost-efficient? | Regular Air carries **74.7%** of order lines while shipping costs account for only **0.64%** of sales. |
| **BQ-06** | Which customer segment is most profitable? | Corporate generates the highest total profit (~**$600K**), while Small Business records the highest profit margin (**11.32%**). |
| **BQ-07** | Which regions underperform on profit margin relative to sales? | West generates the highest revenue but only an **8.26%** margin, while Nunavut records the weakest profitability (**2.44%**). |
| **BQ-08** | What percentage of orders result in a net loss? | **50.8%** of all order lines are loss-making, with Furniture showing the highest loss rate (**53.5%**). |
| **BQ-09** | Is there a seasonal sales pattern? | December (**9.84%** of sales) and January (**9.69%**) are the strongest months across 2009–2012 combined; May–August is the weakest four-month stretch (**29.8%** of sales). |
| **BQ-10** | Do product returns follow a pattern by category or region? | Technology in Ontario (**13.73%**) and Furniture in Yukon (**13.64%**) have the highest return rates. |

---

## 🗂️ Dataset

| Attribute | Detail |
|---|---|
| **Source** | Superstore Database File.xlsx (Kaggle) |
| **Coverage** | Canadian retail chain (January 2009 – December 2012) |
| **Worksheets** | Orders, Customer Name, Returns, Users |
| **Unit of analysis** | One order line (8,399 lines across 5,496 orders). Counts labelled "order lines" use the first; average order value uses the second |
| **Checksum** | Not recorded at download; the project predates the playbook's provenance standard |
| **Licence** | Set by the source listing. The Excel file is not stored in this repository |

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

## 🔁 Reproducibility

Requirements: MySQL 8.0+, Python 3 with Jupyter, and `pandas`, `numpy`, `matplotlib`, `seaborn`, `sqlalchemy`, `mysql-connector-python` and `openpyxl`.

1. Clone the repository and place `Superstore Database File.xlsx` in the folder you start Jupyter from.
2. Run the Phase 0 section of `sql/Superstore_Database.sql` in MySQL to create the `superstore` database and its four tables.
3. In `notebook/superstore_database.ipynb`, replace `<password>` in `DATABASE_URL` with your MySQL password. Do not commit the file with the password in it.
4. Run the notebook from top to bottom. It loads the four tables, answers the 10 business questions and saves the charts to `outputs/`.
5. Run the 10 business-question queries in `sql/Superstore_Database.sql`. Their results are the CSV files in `outputs/`.
6. Check the figures in this README and on the project page with the [Data Analysis Playbook](https://github.com/HarjiiBoss/analytics-playbook)'s `tools/check_figures.py`. Derived figures checked by hand are listed with their calculations in `.figures-allow`.

---

## 📁 Repository Structure

```text
Superstore_Database/
├── docs/
│   └── index.html               # Project page (taofeeksalami.com/Superstore_Database)
├── notebook/
│   └── superstore_database.ipynb   # Python ETL (Excel → MySQL) and the 10 business questions
├── outputs/                     # Query results (CSV) and charts (bq01–bq10 PNG)
├── sql/
│   └── Superstore_Database.sql  # Schema and the 10 business-question queries
├── .figures-allow               # Derived figures checked by hand, with their calculations
├── LICENSE
└── README.md
```

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

## 📄 License

The code and documentation in this repository are released under the MIT License (see `LICENSE`). The dataset is not covered by this licence; its terms are set by its source listing.

---

## 👤 Author

**Taofeek Olawale Salami**

**Data Analyst** | SQL • Python • Excel • Tableau

GitHub: **[@HarjiiBoss](https://github.com/HarjiiBoss)**

---

*Completed as part of the Next Gen Cohort — 3MTT × Darey.io Human Capacity Development Program.*

---

## 📝 Corrections

**29 October 2026**

- **Unit of analysis:** counts of 8,399 rows are order lines, not orders (there are 5,496 orders). "74.7% of orders" shipped by Regular Air, the discount counts and the loss-making share now say "order lines", in the README, on the project page and in the SQL comments.
- **Seasonality:** "December and January consistently deliver the strongest sales" replaced with their shares of 2009–2012 sales combined (9.84% and 9.69%). The data was not compared year by year, so "consistently" was not shown. The SQL comment's "% of annual revenue" now reads "% of sales".
- **Returns:** Furniture's "elevated return rates" replaced with the figures: 10.9% of Furniture orders were returned, against 10.5% for Technology and 10.1% for Office Supplies.
- **Project page:** Technology is "the highest sales, profit and margin of the three categories" rather than "the strongest by every measure" (Office Supplies has a lower return rate). December and January order-line values are $2,018–$2,035, not "about $2,020".
- **SQL comments:** the discount answer no longer suggests deep discounts erode profit from two order lines; typos fixed.

**26 October 2026**

- Notebook findings rewritten to print from computed results, and README and page figures aligned with them after the portfolio audit (pull request #1): 50.8% of order lines loss-making (previously 50.4%), and the "discounts above 20% eliminate profit" claim removed.

## 📍 Published Surfaces

Every place this project's findings appear outside this repository. When a figure changes, each one is updated and its date refreshed (Data Analysis Playbook v3.4, Published Surfaces).

| Surface | Link | Figures quoted | Last checked |
|---------|------|----------------|--------------|
| Project page | [taofeeksalami.com/Superstore_Database](https://taofeeksalami.com/Superstore_Database) | Full findings | 29 Oct 2026 |
| Portfolio site card | [taofeeksalami.com](https://taofeeksalami.com) | 50.8% loss-making lines, $14.9M revenue, 8,399 order lines, Furniture 2.3% margin on $5.18M | 29 Oct 2026 |
| GitHub profile README | [github.com/HarjiiBoss](https://github.com/HarjiiBoss) | 50.8%, $14.9M, Furniture 2.3% on $5.18M, Tables −$99.1K, December 9.84%, January 9.69% | 29 Oct 2026 |
| Resume | — | 8,399 order lines, 50.8%, Furniture 2.3% on $5.18M | 29 Oct 2026 |
