-- Banking Customer Churn & Credit Card Analytics
-- Portfolio SQL (MySQL-style)
-- Synthetic dataset

-- 1. Row counts
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_accounts FROM accounts;
SELECT COUNT(*) AS total_transactions FROM transactions;
SELECT COUNT(*) AS total_cards FROM credit_cards;
SELECT COUNT(*) AS total_branches FROM branches;

-- 2. Duplicate transaction IDs
SELECT transaction_id, COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- 3. Possible business duplicates
SELECT account_id, transaction_date, transaction_type,
       transaction_amount, transaction_channel, transaction_status,
       COUNT(*) AS duplicate_count
FROM transactions
GROUP BY account_id, transaction_date, transaction_type,
         transaction_amount, transaction_channel, transaction_status
HAVING COUNT(*) > 1;

-- 4. Missing customer attributes
SELECT
    SUM(CASE WHEN occupation IS NULL THEN 1 ELSE 0 END) AS missing_occupation,
    SUM(CASE WHEN annual_income IS NULL THEN 1 ELSE 0 END) AS missing_annual_income
FROM customers;

-- 5. Overall churn rate
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_status = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN churn_status = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate
FROM customers;

-- 6. Churn by occupation
SELECT
    occupation,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_status = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN churn_status = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate
FROM customers
GROUP BY occupation
ORDER BY churn_rate DESC;

-- 7. Churn by region
SELECT
    region,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_status = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN churn_status = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate,
    ROUND(AVG(annual_income), 2) AS avg_annual_income
FROM customers
GROUP BY region
ORDER BY churn_rate DESC;

-- 8. Account type analysis
SELECT
    account_type,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(account_id) AS total_accounts,
    ROUND(SUM(current_balance), 2) AS total_balance,
    ROUND(AVG(current_balance), 2) AS avg_account_balance
FROM accounts
GROUP BY account_type
ORDER BY total_balance DESC;

-- 9. Successful transaction channel performance
SELECT
    t.transaction_channel,
    COUNT(t.transaction_id) AS total_transactions,
    COUNT(DISTINCT a.customer_id) AS unique_customers,
    ROUND(SUM(t.transaction_amount), 2) AS total_transaction_amount,
    ROUND(AVG(t.transaction_amount), 2) AS avg_transaction_amount
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE t.transaction_status = 'Success'
GROUP BY t.transaction_channel
ORDER BY total_transaction_amount DESC;

-- 10. Failure rate by channel
SELECT
    transaction_channel,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN transaction_status = 'Failed' THEN 1 ELSE 0 END) AS failed_transactions,
    ROUND(SUM(CASE WHEN transaction_status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS failure_rate
FROM transactions
GROUP BY transaction_channel
ORDER BY failure_rate DESC;

-- 11. Credit utilization by card
SELECT
    card_id, customer_id, card_type, credit_limit, current_balance,
    ROUND(current_balance / NULLIF(credit_limit,0) * 100, 2) AS utilization_pct
FROM credit_cards
WHERE current_balance / NULLIF(credit_limit,0) * 100 > 70
ORDER BY utilization_pct DESC;

-- 12. Credit utilization by card type
SELECT
    card_type,
    COUNT(*) AS total_cards,
    ROUND(AVG(credit_limit),2) AS avg_credit_limit,
    ROUND(AVG(current_balance),2) AS avg_current_balance,
    ROUND(AVG(current_balance / NULLIF(credit_limit,0) * 100),2) AS avg_utilization_pct,
    SUM(CASE WHEN current_balance / NULLIF(credit_limit,0) * 100 > 70 THEN 1 ELSE 0 END) AS high_utilization_cards
FROM credit_cards
GROUP BY card_type
ORDER BY avg_utilization_pct DESC;

-- 13. Branch performance
SELECT
    b.branch_name,
    COUNT(DISTINCT a.customer_id) AS unique_customers,
    COUNT(a.account_id) AS total_accounts,
    ROUND(SUM(a.current_balance),2) AS total_balance,
    ROUND(AVG(a.current_balance),2) AS avg_account_balance
FROM branches b
JOIN accounts a ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY total_balance DESC;

-- 14. Latest successful transaction per customer
WITH ranked_transactions AS (
    SELECT
        c.customer_id,
        c.customer_name,
        t.transaction_id,
        t.transaction_date,
        t.transaction_amount,
        t.transaction_type,
        t.transaction_channel,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY t.transaction_date DESC, t.transaction_id DESC
        ) AS rn
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    JOIN transactions t ON a.account_id = t.account_id
    WHERE t.transaction_status = 'Success'
)
SELECT *
FROM ranked_transactions
WHERE rn = 1;

-- 15. Inactive customers (>90 days relative to dataset max date)
WITH dataset_date AS (
    SELECT MAX(transaction_date) AS max_date
    FROM transactions
    WHERE transaction_status = 'Success'
),
customer_activity AS (
    SELECT
        c.customer_id,
        c.customer_name,
        MAX(t.transaction_date) AS last_transaction_date
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    JOIN transactions t ON a.account_id = t.account_id
    WHERE t.transaction_status = 'Success'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    ca.customer_id,
    ca.customer_name,
    ca.last_transaction_date,
    DATEDIFF(d.max_date, ca.last_transaction_date) AS days_inactive
FROM customer_activity ca
CROSS JOIN dataset_date d
WHERE DATEDIFF(d.max_date, ca.last_transaction_date) > 90
ORDER BY days_inactive DESC;

-- 16. Monthly successful transaction trend + MoM growth
WITH monthly AS (
    SELECT
        DATE_FORMAT(transaction_date, '%Y-%m') AS month,
        SUM(transaction_amount) AS total_amount
    FROM transactions
    WHERE transaction_status = 'Success'
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
),
lagged AS (
    SELECT
        month,
        total_amount,
        LAG(total_amount) OVER (ORDER BY month) AS previous_month_amount
    FROM monthly
)
SELECT
    month,
    ROUND(total_amount,2) AS total_transaction_amount,
    ROUND(previous_month_amount,2) AS previous_month_amount,
    ROUND((total_amount - previous_month_amount) / NULLIF(previous_month_amount,0) * 100,2) AS growth_pct
FROM lagged
ORDER BY month;

-- 17. Customer contribution and cumulative contribution
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(t.transaction_amount) AS total_transaction_amount
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    JOIN transactions t ON a.account_id = t.account_id
    WHERE t.transaction_status = 'Success'
    GROUP BY c.customer_id, c.customer_name
),
contribution AS (
    SELECT
        *,
        total_transaction_amount / SUM(total_transaction_amount) OVER () * 100 AS contribution_pct,
        SUM(total_transaction_amount) OVER (
            ORDER BY total_transaction_amount DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(total_transaction_amount) OVER () * 100 AS cumulative_contribution_pct
    FROM customer_totals
)
SELECT *
FROM contribution
ORDER BY total_transaction_amount DESC;

-- 18. Activity segment vs churn
WITH customer_activity AS (
    SELECT
        c.customer_id,
        c.churn_status,
        COUNT(t.transaction_id) AS transaction_count
    FROM customers c
    LEFT JOIN accounts a ON c.customer_id = a.customer_id
    LEFT JOIN transactions t
        ON a.account_id = t.account_id
       AND t.transaction_status = 'Success'
    GROUP BY c.customer_id, c.churn_status
),
segmentation AS (
    SELECT
        *,
        CASE
            WHEN transaction_count < 5 THEN 'Low Activity'
            WHEN transaction_count BETWEEN 5 AND 15 THEN 'Medium Activity'
            ELSE 'High Activity'
        END AS activity_segment
    FROM customer_activity
)
SELECT
    activity_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_status = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN churn_status = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100,2) AS churn_rate
FROM segmentation
GROUP BY activity_segment
ORDER BY churn_rate DESC;
