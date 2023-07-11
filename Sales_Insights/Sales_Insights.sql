USE sales;

DESCRIBE markets;

-- check for duplicated values 
SELECT product_code, customer_code, market_code, order_date, sales_qty, sales_qty, sales_amount, currency, COUNT(*) AS count
FROM transactions
GROUP BY product_code, customer_code, market_code, order_date, sales_qty, sales_qty, sales_amount, currency
ORDER BY count DESC;

-- Data Cleaning 

CREATE TABLE temp_table AS 
SELECT DISTINCT product_code, customer_code, market_code, order_date, sales_qty, sales_amount, currency
FROM transactions;

DROP TABLE transactions;
ALTER TABLE temp_table RENAME TO transactions;

ALTER TABLE customers
CHANGE COLUMN custmer_name customer_name VARCHAR(100);

DELETE FROM markets 
WHERE zone = '';

DELETE FROM transactions
WHERE sales_amount <= 0;

UPDATE transactions 
SET sales_amount = 75.6249 * sales_amount -- exchange rate on Jun 26, 20 on https://www.exchangerates.org.uk/USD-INR-06_06_2020-exchange-rate-history.html
WHERE currency = 'USD';

UPDATE transactions 
SET currency = 'INR';

-- DATA ANALYSIS
SELECT COUNT(*)
FROM transactions;

SELECT * 
FROM  markets
WHERE markets_code NOT IN (
	SELECT market_code
    FROM transactions);
    
;
SELECT
    amount_each / total_amount * 100 AS percentage
FROM
    (SELECT SUM(sales_amount) AS total_amount
    FROM transactions) AS total,
    (SELECT SUM(t.sales_amount) AS amount_each
    FROM transactions AS t
    LEFT JOIN customers AS c ON t.customer_code = c.customer_code
    GROUP BY t.customer_code
    ORDER BY amount_each DESC
    ) AS highest;
    
SELECT m.markets_name, COUNT(DISTINCT customer_code)
FROM transactions AS t 
LEFT JOIN markets AS m 
ON t.market_code = m.markets_code
GROUP BY m.markets_name;
    
SELECT zone, m.markets_name, 
	ROUND(SUM(sales_amount) / (SELECT SUM(sales_amount) FROM transactions) * 100) AS pct_amount
FROM transactions AS t 
LEFT JOIN markets AS m 
ON t.market_code = m.markets_code
GROUP BY zone, m.markets_name
ORDER BY pct_amount DESC;

SELECT SUM(sales_amount) FROM transactions
