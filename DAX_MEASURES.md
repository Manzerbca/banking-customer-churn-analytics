# Power BI DAX Measures

``` dax
Total Customers =
DISTINCTCOUNT(customers[customer_id])

Churned Customers =
CALCULATE(
    [Total Customers],
    customers[churn_status] = 1
)

Churn Rate =
DIVIDE([Churned Customers], [Total Customers], 0)

Average Annual Income =
AVERAGE(customers[annual_income])

Total Account Balance =
SUM(accounts[current_balance])

Total Transactions =
DISTINCTCOUNT(transactions[transaction_id])

Successful Transactions =
CALCULATE(
    DISTINCTCOUNT(transactions[transaction_id]),
    transactions[transaction_status] = "Success"
)

Failed Transactions =
CALCULATE(
    COUNT(transactions[transaction_id]),
    transactions[transaction_status] = "Failed"
)

Failure Rate =
DIVIDE([Failed Transactions], [Total Transactions], 0)

Total Transaction Amount =
SUM(transactions[transaction_amount])

Successful Transaction Amount =
CALCULATE(
    SUM(transactions[transaction_amount]),
    transactions[transaction_status] = "Success"
)

Average Successful Transaction Amount =
CALCULATE(
    AVERAGE(transactions[transaction_amount]),
    transactions[transaction_status] = "Success"
)

Total Cards =
DISTINCTCOUNT(credit_cards[card_id])

Credit Utilization % =
DIVIDE(
    SUM(credit_cards[current_balance]),
    SUM(credit_cards[credit_limit]),
    0
)

High Utilization Cards =
CALCULATE(
    COUNT(credit_cards[card_id]),
    FILTER(
        credit_cards,
        DIVIDE(
            credit_cards[current_balance],
            credit_cards[credit_limit],
            0
        ) > 0.70
    )
)

High Utilization Rate =
DIVIDE([High Utilization Cards], [Total Cards], 0)
```

## Calculated columns

``` dax
Churn Label =
IF(customers[churn_status] = 1, "Churned", "Active")

Income Segment =
SWITCH(
    TRUE(),
    ISBLANK(customers[annual_income]), "Unknown",
    customers[annual_income] < 500000, "Low Income",
    customers[annual_income] <= 1000000, "Middle Income",
    "High Income"
)

Year Month =
FORMAT(transactions[transaction_date], "YYYY-MM")

Year Month Sort =
YEAR(transactions[transaction_date]) * 100
    + MONTH(transactions[transaction_date])
```
