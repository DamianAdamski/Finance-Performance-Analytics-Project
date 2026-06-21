-- Counting totals 

-- total customers 
SELECT COUNT(*) AS total_customers
FROM customers;

-- total accounts
SELECT COUNT(*) AS total_accounts
FROM accounts;

--total balance in accounts
SELECT SUM(balance_usd) AS total_balance
FROM accounts;

-- total loans
SELECT COUNT(*) AS total_loans
FROM loans;

--total loan amount
SELECT SUM(loan_amount) AS total_loan_amount
FROM loans;

--total cards
SELECT COUNT(*) AS total_cards
FROM cards;

-- Account analysis by type
SELECT account_type, 
COUNT(*) AS total_accounts, 
ROUND(AVG(balance_usd), 2) AS average_balance,
ROUND(SUM(balance_usd), 2) AS total_balance
FROM accounts
GROUP BY account_type
ORDER BY total_balance DESC;

-- customer credit score analysis
-- overall analysis of credit scores data
SELECT 
    ROUND(AVG(credit_score), 2) AS average_credit_score,
    MIN(credit_score) AS minimum_credit_score,
    MAX(credit_score) AS maximum_credit_score
FROM customers;



-- check how many scores are good and bad by categorising them
SELECT 
    CASE
        WHEN credit_score <550 THEN 'Poor'
        WHEN credit_score BETWEEN 550 AND 679 THEN 'Fair'
        WHEN credit_score BETWEEN 680 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
        WHEN credit_score >= 800 THEN 'Excellent'
    END AS credit_score_category,
    COUNT(*) AS total_customers
FROM customers
GROUP BY credit_score_category
ORDER BY total_customers;




-- customer value summary 
WITH account_summary AS (
    SELECT
        customer_id,
        SUM(balance_usd) AS total_account_balance,
        COUNT(account_id) AS number_of_accounts
    FROM accounts
    GROUP BY customer_id
),

card_summary AS (
    SELECT
        a.customer_id,
        COUNT(c.card_id) AS number_of_cards
    FROM accounts a
    LEFT JOIN cards c ON a.account_id = c.account_id
    GROUP BY a.customer_id
),

loan_summary AS (
    SELECT
        customer_id,
        SUM(loan_amount) AS total_loan_amount,
        COUNT(loan_id) AS number_of_loans,
        AVG(interest_rate) AS average_interest_rate
    FROM loans
    GROUP BY customer_id
)

SELECT --final customer summary with account, card, and loan information
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.credit_score,
    COALESCE(a.total_account_balance, 0) AS total_account_balance,
    COALESCE(a.number_of_accounts, 0) AS number_of_accounts,
    COALESCE(cs.number_of_cards, 0) AS number_of_cards,
    COALESCE(l.total_loan_amount, 0) AS total_loan_amount,
    COALESCE(l.number_of_loans, 0) AS number_of_loans,
    COALESCE(l.average_interest_rate, 0) AS average_interest_rate
FROM customers c
LEFT JOIN
    account_summary a ON c.customer_id = a.customer_id
LEFT JOIN
    card_summary cs ON c.customer_id = cs.customer_id
LEFT JOIN
    loan_summary l ON c.customer_id = l.customer_id
ORDER BY total_account_balance DESC;


-- Customer risk analysis 
-- data does not include missed payments, defaults, overdue balances, repayment history, income
-- cannot calculate true default risk, but can create risk indicator


-- Loan to balance ratio analysis
WITH account_summary AS (
    SELECT
        customer_id,
        SUM(balance_usd) AS total_account_balance
    FROM accounts
    GROUP BY customer_id
),

loan_summary AS (
    SELECT
        customer_id,
        SUM(loan_amount) AS total_loan_amount,
        AVG(interest_rate) AS average_interest_rate
    FROM loans
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.credit_score,
    COALESCE(a.total_account_balance, 0) AS total_account_balance,
    COALESCE(l.total_loan_amount, 0) AS total_loan_amount,
    l.average_interest_rate,

    ROUND(
        COALESCE(l.total_loan_amount, 0)
        / NULLIF(a.total_account_balance, 0),
        2
    ) AS loan_to_balance_ratio

FROM customers c
LEFT JOIN account_summary a
    ON c.customer_id = a.customer_id
LEFT JOIN loan_summary l
    ON c.customer_id = l.customer_id
ORDER BY loan_to_balance_ratio DESC NULLS LAST;



-- Using the above ratios, create bandwidths for risk analysis
WITH account_summary AS (
    SELECT
        customer_id,
        SUM(balance_usd) AS total_account_balance
    FROM accounts
    GROUP BY customer_id
),

loan_summary AS (
    SELECT
        customer_id,
        SUM(loan_amount) AS total_loan_amount
    FROM loans
    GROUP BY customer_id
),

customer_risk AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.city,
        c.credit_score,
        COALESCE(a.total_account_balance, 0) AS total_account_balance,
        COALESCE(l.total_loan_amount, 0) AS total_loan_amount,
        COALESCE(l.total_loan_amount, 0)
            / NULLIF(a.total_account_balance, 0) AS loan_to_balance_ratio
    FROM customers c
    LEFT JOIN account_summary a
        ON c.customer_id = a.customer_id
    LEFT JOIN loan_summary l
        ON c.customer_id = l.customer_id
)

SELECT
    *,
    CASE
        WHEN credit_score < 550 THEN 'High risk'
        WHEN credit_score < 680 THEN 'Medium risk'
        ELSE 'Lower risk'
    END AS credit_risk_band
FROM customer_risk
ORDER BY credit_score ASC;




-- They analysis works better if we can combine the credit score and loan to balance ratio into a single risk indicator.
WITH account_summary AS (
    SELECT
        customer_id,
        SUM(balance_usd) AS total_account_balance
    FROM accounts
    GROUP BY customer_id
),

loan_summary AS (
    SELECT
        customer_id,
        SUM(loan_amount) AS total_loan_amount
    FROM loans
    GROUP BY customer_id
),

risk_data AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.credit_score,
        COALESCE(a.total_account_balance, 0) AS total_account_balance,
        COALESCE(l.total_loan_amount, 0) AS total_loan_amount,
        COALESCE(l.total_loan_amount, 0)
            / NULLIF(a.total_account_balance, 0) AS loan_to_balance_ratio
    FROM customers c
    LEFT JOIN account_summary a
        ON c.customer_id = a.customer_id
    LEFT JOIN loan_summary l
        ON c.customer_id = l.customer_id
)

SELECT
    *,
    CASE
        WHEN credit_score < 550
             AND loan_to_balance_ratio > 5
            THEN 'High risk'

        WHEN credit_score < 680
             OR loan_to_balance_ratio > 3
            THEN 'Medium risk'

        ELSE 'Lower risk'
    END AS overall_risk_category
FROM risk_data
ORDER BY
    CASE
        WHEN credit_score < 550
             AND loan_to_balance_ratio > 5 THEN 1
        WHEN credit_score < 680 
             OR loan_to_balance_ratio > 3 THEN 2
        ELSE 3
    END;

