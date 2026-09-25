# Banking Customer Churn & Credit Card Analytics

An end-to-end **Data Analyst portfolio project** that analyzes customer
churn, transaction behavior, account balances, branch performance, and
credit-card utilization using **SQL, Excel, and Power BI**.

> **Note:** This project uses a synthetic dataset created for portfolio
> and interview practice. Findings should not be interpreted as results
> from a real bank.

## Project objectives

-   Measure overall customer churn and identify segments associated with
    higher churn.
-   Analyze successful, failed, and reversed transaction behavior.
-   Compare transaction channels using volume, value, and failure rate.
-   Evaluate account balances across account types and branches.
-   Measure credit-card utilization and identify high-utilization cards.
-   Build an interactive Power BI report that communicates findings to
    business stakeholders.

## Dataset

  Table              Rows Purpose
  -------------- -------- -----------------------------------------------
  Customers         1,000 Demographics, income, join date, churn status
  Accounts          1,450 Account type, balance, status, branch
  Transactions     12,015 Transaction date, channel, amount, status
  Credit Cards        720 Card type, limit, balance, status
  Branches             20 Branch and regional attributes

### Data model

-   `customers[customer_id]` 1 → \* `accounts[customer_id]`
-   `customers[customer_id]` 1 → \* `credit_cards[customer_id]`
-   `accounts[account_id]` 1 → \* `transactions[account_id]`
-   `branches[branch_id]` 1 → \* `accounts[branch_id]`

## Tools and skills demonstrated

**SQL:** joins, CTEs, conditional aggregation, window functions,
`ROW_NUMBER`, `DENSE_RANK`, `LAG`, date analysis, segmentation, Pareto
analysis, duplicate checks, NULL handling, customer-level granularity.

**Excel:** Excel Tables, `COUNTIF`, `COUNTBLANK`, `IF`, data-quality
checks, PivotTables, churn-rate analysis, channel analysis.

**Power BI:** relational modeling, DAX measures, calculated columns,
filter context, row-level `FILTER`, KPI cards, slicers, bar charts, line
charts, donut charts, date sorting, multi-page dashboard design.

## Dashboard

### 1. Customer Churn Analysis

![Customer Churn Analysis](screenshots/customer_churn_analysis.png)

Focuses on overall churn and churn patterns by region, income segment,
and occupation.

### 2. Transaction Analysis

![Transaction Analysis](screenshots/transaction_analysis.png)

Focuses on transaction volume/value, successful transactions, monthly
trend, transaction status, channel usage, and failure rate.

### 3. Account & Credit Analysis

![Account & Credit Analysis](screenshots/account_credit_analysis.png)

Focuses on account balances, credit utilization, high-utilization
exposure, branch performance, card type, and card status.

## Key findings

-   Overall customer churn rate: **19.10%**.
-   Region-level churn is relatively close; the observed regional spread
    is small.
-   Freelancers show the highest observed occupation-level churn rate in
    the dashboard.
-   Total account balance is approximately **162.9M**, with Savings
    accounts holding the largest aggregate balance.
-   There are **12,015** transactions; **11,318** are successful.
-   Overall transaction failure rate is **3.92%**.
-   Branch and POS channels have the highest observed failure rates, at
    about **4.52%** each.
-   Successful transaction amount is approximately **50.1M**.
-   Portfolio credit utilization is **47.11%**.
-   **26.11%** of cards meet the project's high-utilization threshold
    (\>70%).
-   **91.94%** of credit cards are Active.

## Business recommendations

1.  Investigate high-churn customer segments---especially occupation
    groups with elevated churn---while checking segment size before
    acting.
2.  Review Branch and POS transaction journeys because their failure
    rates are higher than other channels in this dataset.
3.  Monitor high-utilization credit-card customers and prioritize
    proactive risk/engagement workflows.
4.  Use branch balance concentration to support branch-level service and
    relationship-management planning.
5.  Track churn, transaction failure, and credit utilization over time
    rather than treating a single snapshot as causal evidence.

## Repository structure

``` text
Banking_Customer_Churn_Portfolio/
├── README.md
├── dataset/
│   └── banking_churn_credit_card_analytics_dataset.xlsx
├── sql/
│   └── banking_analysis.sql
├── power-bi/
│   ├── DAX_MEASURES.md
│   └── ADD_YOUR_PBIX_HERE.txt
├── screenshots/
│   ├── customer_churn_analysis.png
│   ├── transaction_analysis.png
│   └── account_credit_analysis.png
└── documentation/
    ├── PROJECT_SUMMARY.pdf
    ├── DATA_DICTIONARY.md
    └── INTERVIEW_GUIDE.md
```

## How to use

1.  Import the Excel workbook into MySQL/SQL Server or Power BI.
2.  Run the SQL analysis in `sql/banking_analysis.sql`.
3.  Recreate or inspect the Power BI measures in
    `power-bi/DAX_MEASURES.md`.
4.  Open the Power BI report (`.pbix`) after adding it to the `power-bi`
    folder.
5.  Use the screenshots and project summary for portfolio presentation.

## Interview-ready project summary

"I built an end-to-end banking analytics project using SQL, Excel, and
Power BI. I first validated and analyzed customer, account, transaction,
credit-card, and branch data in SQL. I used customer-level aggregation
carefully to avoid duplication from one-to-many relationships. I then
validated key metrics in Excel using formulas and PivotTables. In Power
BI, I built a relational model, created DAX measures for churn,
transaction failure, balances, and credit utilization, and designed
three dashboard pages covering customer churn, transactions, and
account/credit analysis. The project helped identify churn patterns,
channel failure rates, branch balance concentration, and high credit
utilization."

## Author

**Manzer Alam**\
Data Analyst Portfolio Project
