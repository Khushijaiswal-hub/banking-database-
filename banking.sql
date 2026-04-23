CREATE DATABASE banking;
USE banking;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    balance DECIMAL(12,2) DEFAULT 0,
    account_type VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    amount DECIMAL(12,2),
    transaction_type VARCHAR(20), -- deposit / withdraw
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
INSERT INTO customers (name, email) VALUES
('Rahul', 'rahul@gmail.com'),
('Anita', 'anita@gmail.com');

INSERT INTO accounts (customer_id, balance, account_type) VALUES
(1, 10000, 'Savings'),
(2, 20000, 'Current');
SELECT a.account_id, c.name, a.balance
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id;
SELECT * FROM transactions
WHERE account_id = 1;
SELECT SUM(amount) AS total_deposit
FROM transactions
WHERE transaction_type = 'deposit';
DELIMITER 

CREATE TRIGGER update_balance
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'deposit' THEN
        UPDATE accounts
        SET balance = balance + NEW.amount
        WHERE account_id = NEW.account_id;
    ELSE
        UPDATE accounts
        SET balance = balance - NEW.amount
        WHERE account_id = NEW.account_id;
    END IF;
END 
START TRANSACTION;

-- Withdraw from account 1
UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1;

-- Deposit into account 2
UPDATE accounts SET balance = balance + 1000 WHERE account_id = 2;

COMMIT;
rollback;
DELIMITER //

CREATE PROCEDURE transfer_money(
    IN from_acc INT,
    IN to_acc INT,
    IN amt DECIMAL(10,2)
)
BEGIN
    START TRANSACTION;
    UPDATE accounts SET balance = balance - amt WHERE account_id = from_acc;
    UPDATE accounts SET balance = balance + amt WHERE account_id = to_acc;

    COMMIT;
END 