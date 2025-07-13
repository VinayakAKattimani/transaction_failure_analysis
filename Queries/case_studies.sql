select * from transactions
select * from Banks
select * from merchants
select * from users


--Case Study 1: High Failure Rate During Peak Hours
SELECT fr, sum(total_failed) as num
FROM(SELECT EXTRACT(HOURs FROM txn_time) AS time,failure_reason as fr,
       COUNT(txn_id) AS total_failed
	   FROM transactions
	   WHERE status = 'FAILED'
	   GROUP BY time, fr
	   ORDER BY total_failed DESC ) as total 
WHERE time BETWEEN 19 AND 21
GROUP BY fr
order by num DESC



--Case Study 2: Bank-Specific Failures Leading to Poor Experience
SELECT b.bank_name,t.failure_reason, COUNT(t.status) AS total_failure
FROM banks b
JOIN transactions t
ON t.bank_id = b.bank_id
WHERE t.status = 'FAILED'
GROUP BY b.bank_id,t.failure_reason
ORDER BY  total_failure DESC
ORDER BY total_failure


--Case Study 3: Failure-Prone Merchants
WITH CTE1 AS (
    SELECT 
        m.merchant_id, 
        m.name,
        COUNT(*) AS total_fails
    FROM merchants m
    JOIN transactions t ON t.merchant_id = m.merchant_id
    WHERE t.status = 'FAILED'
    GROUP BY m.merchant_id, m.name
)

SELECT 
    c1.name,
   ( ROUND((c1.total_fails * 100.0 / COUNT(t.*)), 2) || '%') AS failure_rate
FROM CTE1 c1
JOIN transactions t ON c1.merchant_id = t.merchant_id
GROUP BY c1.name, c1.total_fails
ORDER BY failure_rate DESC
LIMIT 5;
      


--Case Study 4: Revenue Loss from Non-Retried Failures
WITH failed_txns AS (
    SELECT 
        txn_id,
        user_id,
        merchant_id,
        amount,
        txn_time
    FROM transactions
    WHERE status = 'FAILED'
),

successful_txns AS (
    SELECT 
        user_id,
        merchant_id,
        amount,
        txn_time
    FROM transactions
    WHERE status = 'SUCCESS'
),

retried_txns AS (
    SELECT 
        f.txn_id
    FROM failed_txns f
    JOIN successful_txns s
      ON f.user_id = s.user_id
     AND f.merchant_id = s.merchant_id
     AND f.amount = s.amount
     AND s.txn_time > f.txn_time
)

SELECT 
    COUNT(*) AS unretried_failed_txns,
    SUM(f.amount) AS estimated_revenue_lost
FROM failed_txns f
LEFT JOIN retried_txns r ON f.txn_id = r.txn_id
WHERE r.txn_id IS NULL;


--Case Study 5: Detecting Possible Fraud Patterns
WITH failed_txns AS (
    SELECT 
        user_id,
        txn_time,
        merchant_id,
        bank_id,
        amount
    FROM transactions
    WHERE status = 'FAILED'
),
suspicious_users AS (
    SELECT 
        f1.user_id,
        COUNT(*) AS fail_count,
        MIN(f1.txn_time) AS first_fail_time,
        MAX(f2.txn_time) AS last_fail_time,
        COUNT(DISTINCT f1.merchant_id) AS unique_merchants,
        COUNT(DISTINCT f1.bank_id) AS unique_banks
    FROM failed_txns f1
    JOIN failed_txns f2 
      ON f1.user_id = f2.user_id 
     AND f2.txn_time BETWEEN f1.txn_time AND f1.txn_time + INTERVAL '10 minutes'
    GROUP BY f1.user_id
    HAVING 
        COUNT(*) >= 3 AND 
        COUNT(DISTINCT f1.merchant_id) >= 2 AND 
        COUNT(DISTINCT f1.bank_id) >= 2
)

SELECT 
    u.user_id,
    u.name AS user_name,
    u.city,
    s.fail_count,
    s.first_fail_time,
    s.last_fail_time,
    s.unique_merchants,
    s.unique_banks
FROM suspicious_users s
JOIN users u ON s.user_id = u.user_id
ORDER BY s.fail_count DESC;

