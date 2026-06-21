CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    credit_score INT,
    created_at TIMESTAMP
);

CREATE TABLE accounts (
    account_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    account_type VARCHAR(50),
    balance_usd NUMERIC(15, 2),
    open_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE cards (
    card_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL,
    card_type VARCHAR(50),
    expiration_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE loans (
    loan_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    loan_amount NUMERIC(15, 2),
    interest_rate NUMERIC(5, 2),
    start_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE merchants (
    merchant_id VARCHAR(50) PRIMARY KEY,
    merchant_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE branches (
    branch_id VARCHAR(50) PRIMARY KEY,
    branch_name VARCHAR(100),
    manager_name VARCHAR(100)
);