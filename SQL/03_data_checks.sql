--Check the number of rows in each table.

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'accounts', COUNT(*)
FROM accounts

UNION ALL

SELECT 'cards', COUNT(*)
FROM cards

UNION ALL

SELECT 'loans', COUNT(*)
FROM loans

UNION ALL

SELECT 'branches', COUNT(*)
FROM branches

UNION ALL

SELECT 'merchants', COUNT(*)
FROM merchants;

-- Check 10 rows of data from each table.
-- Make sure to run them seperately to avoid conflict. 

SELECT *
FROM customers
LIMIT 10;

SELECT *
FROM accounts
LIMIT 10;

SELECT *
FROM cards
LIMIT 10;

SELECT *
FROM loans
LIMIT 10;

SELECT *
FROM branches
LIMIT 10;

SELECT *
FROM merchants
LIMIT 10;

-- To check how many rows are not matchig. 
-- Accounts without matching customers
SELECT a.*
FROM accounts a
LEFT JOIN customers c
    ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Loans without matching customers
SELECT l.*
FROM loans l
LEFT JOIN customers c
    ON l.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Cards without matching accounts
SELECT ca.*
FROM cards ca
LEFT JOIN accounts a
    ON ca.account_id = a.account_id
WHERE a.account_id IS NULL;