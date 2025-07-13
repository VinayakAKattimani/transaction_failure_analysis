select * from merchants
select * from users
select * from banks
select * from transactions


SELECT 'users' AS table, COUNT(*) FROM users
UNION ALL
SELECT 'merchants', COUNT(*) FROM merchants
UNION ALL
SELECT 'banks', COUNT(*) FROM banks
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions


select count(*) from transactions where status is null or status = ''

select count(*) from users where name is null 

select count(*) from banks where bank_name is null


--1. Total Transactions & Amount,

SELECT
      COUNT(*) AS total_No_trans,
      SUM(amount) as total_transaction
	  FROM transactions

--2. Success vs Failed %,
SELECT COUNT(*) AS no_of_failed_trans
 FROM transactions
 WHERE status = 'FAILED'

SELECT COUNT(*) AS no_of_failed_trans
 FROM transactions
 WHERE status = 'SUCCESS'
 

SELECT 
    status, 
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM 
    transactions
GROUP BY 
    status;

 
--3. Top 5 Merchants by Revenue, 
SELECT 
     m.name,
     SUM(t.amount) AS total_trans
FROM merchants m
JOIN transactions t
ON m.merchant_id = t.merchant_id
WHERE t.status = 'SUCCESS'
GROUP BY m.name
ORDER BY total_trans desc
LIMIT 5

-- LOW PERFORMING merchants by revenue
SELECT 
     m.name,
     CAST(SUM(t.amount) AS INT) AS total_trans
FROM merchants m
JOIN transactions t
ON m.merchant_id = t.merchant_id
WHERE t.status = 'SUCCESS'
GROUP BY m.name
ORDER BY total_trans 
LIMIT 5



-- Highest spending user per city
SELECT u.name, u.city, SUM(t.amount) as spending
FROM users u
JOIN transactions t
ON u.user_id = t.user_id
GROUP BY u.name, u.city
ORDER BY spending DESC
LIMIT 5


SELECT name, city
FROM
(SELECT *,
   RANK() OVER(PARTITION BY u.city ORDER BY SUM(t.amount) DESC) as Spending
   FROM users u
   JOIN transactions t
   on u.user_id = t.user_id
   WHERE t.status = 'SUCCESS'
   GROUP BY u.user_id, t.txn_id, u.name
    ) AS MA
 WHERE MA.spending = 1

 SELECT name, city
FROM (
    SELECT 
        u.user_id,
        u.name,
        u.city,
        SUM(t.amount) AS total_spent,
        RANK() OVER (PARTITION BY u.city ORDER BY SUM(t.amount) DESC) AS spending_rank
    FROM users u
    JOIN transactions t ON u.user_id = t.user_id
    WHERE t.status = 'SUCCESS'
    GROUP BY u.user_id, u.name, u.city
) AS ranked_users
WHERE ranked_users.spending_rank = 1;

















