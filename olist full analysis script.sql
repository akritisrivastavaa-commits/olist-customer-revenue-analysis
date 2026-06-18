-- What drives customer value and what causes revenue leakage in Olist’s marketplace?--

-- 1.1 Customer Value Analysis

-- Who generates Value and how is value distributed and whether revenue is concentrated?--

Describe orders;

-- Total Number of customers, repeat customers and one time customers --

WITH customer_matrix as(

SELECT c.customer_uid,
COUNT(DISTINCT o.order_id) AS total_orders
FROM customers_new c
JOIN orders o
ON c.customer_id= o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_uid
)
SELECT COUNT(DISTINCT customer_uid) as total_customers,
COUNT(CASE WHEN total_orders > 1 THEN 1 END) as repeat_customers,
COUNT(CASE WHEN total_orders = 1 THEN 1 END) as one_time_customers FROM customer_matrix;

-- Average revenue for one-time customers --

WITH customer_matrix as(

SELECT c.customer_uid,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(oi.price + oi.freight_value) AS revenue
FROM customers_new c
JOIN orders o
ON c.customer_id= o.customer_id
JOIN order_items oi
ON o.order_id= oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_uid
)
SELECT AVG(revenue) as avg_reveune FROM customer_matrix
WHERE total_orders=1;

-- Average revenue for repeat customers --

WITH customer_matrix as(

SELECT c.customer_uid,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(oi.price + oi.freight_value) AS revenue
FROM customers_new c
JOIN orders o
ON c.customer_id= o.customer_id
JOIN order_items oi
ON o.order_id= oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_uid
)
SELECT AVG(revenue) as avg_reveune FROM customer_matrix
WHERE total_orders>1;

-- Revenue Concentration of TOP 10% customers --

WITH customer_matrix as(

SELECT c.customer_uid,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(oi.price + oi.freight_value) AS revenue
FROM customers_new c
JOIN orders o
ON c.customer_id= o.customer_id
JOIN order_items oi
ON o.order_id= oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_uid
),
customer_rank AS (
SELECT *,
NTILE(10) OVER(ORDER BY revenue DESC) as decile
FROM customer_matrix
)
SELECT SUM(revenue)
FROM customer_rank 
WHERE decile= 1;

-- Revenue concentration of Bottom 50% customers --

WITH customer_matrix as(

SELECT c.customer_uid,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(oi.price + oi.freight_value) AS revenue
FROM customers_new c
JOIN orders o
ON c.customer_id= o.customer_id
JOIN order_items oi
ON o.order_id= oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_uid
),
customer_rank AS (
SELECT *,
NTILE(2) OVER(ORDER BY revenue DESC) as decile
FROM customer_matrix
)
SELECT SUM(revenue)
FROM customer_rank 
WHERE decile= 2;

-- 1.2 Repeat Purchase Behaviour-- 

-- Average number of orders placed by repeat customers only --

SELECT AVG(total_orders) AS avg_orders
FROM (
     SELECT c.customer_uid,
     COUNT(DISTINCT o.order_id) AS total_orders
     FROM customers_new c
     JOIN orders o
     ON c.customer_id = o.customer_id
     WHERE o.order_status = 'delivered'
     GROUP BY c.customer_uid
     HAVING COUNT(DISTINCT o.order_id) > 1
) AS repeat_customers;

-- Average order value --

WITH customer_matrix as(

SELECT c.customer_uid,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(oi.price + oi.freight_value) AS revenue
FROM customers_new c
JOIN orders o
ON c.customer_id= o.customer_id
JOIN order_items oi
ON o.order_id= oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_uid
)
SELECT CASE 
WHEN total_orders=1 THEN 'One-time'
ELSE 'repeat' END AS customer_type,
AVG(revenue/total_orders) as avg_order_value
FROM customer_matrix
GROUP BY customer_type;

-- Average days between first and second orders --

WITH customer_orders AS (
    SELECT 
        c.customer_uid,
        DATE(o.purchase_dt) AS purchase_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_uid 
            ORDER BY o.purchase_dt
        ) AS order_rank
    FROM customers_new c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
),
first_two AS (
    SELECT 
        customer_uid,
        MAX(CASE WHEN order_rank = 1 THEN purchase_date END) AS first_order,
        MAX(CASE WHEN order_rank = 2 THEN purchase_date END) AS second_order
    FROM customer_orders
    WHERE order_rank <= 2
    GROUP BY customer_uid
)
SELECT 
    AVG(DATEDIFF(second_order, first_order)) AS avg_days_first_to_second
FROM first_two
WHERE second_order IS NOT NULL;

-- 1.3 Delivery performance & Revenue Analysis--

-- Whether delivery inefficiencies maybe hurting customer experience and revenue --

-- On time orders --

SELECT COUNT(order_id), order_status FROM orders
WHERE est_delivery_dt>= delivered_dt
AND order_status= 'delivered'
GROUP BY order_status;

-- Late orders --

SELECT COUNT(order_id), order_status FROM orders
WHERE est_delivery_dt< delivered_dt
AND order_status= 'delivered'
GROUP BY order_status;

-- Total orders --

SELECT COUNT(order_id), order_status FROM orders
WHERE order_status= 'delivered'
GROUP BY order_status;

-- Average delay between days --

SELECT AVG(
DATEDIFF(
DATE (delivered_dt), DATE(est_delivery_dt)
)
)
 AS avg_delay
FROM orders
WHERE delivered_dt> est_delivery_dt
AND order_status= 'delivered';
 
-- 1.4 Impact of delays on customer retention--



WITH customer_orders AS (
     SELECT 
     c.customer_uid,
     COUNT(DISTINCT o.order_id) as total_orders
     FROM Customers_new c 
     JOIN orders o
     ON c.customer_id= o.customer_id
     WHERE order_status= 'delivered'
     GROUP BY customer_uid
     ),
     customer_delay as (
     SELECT customer_uid,
     CASE
	 WHEN MAX(delivered_dt> est_delivery_dt)= 1
     THEN 'Had Delay'
     ELSE 'No Delay'
     END AS Delay_status
     FROM customers_new c
     JOIN orders o 
     ON c.customer_id= o.customer_id
     WHERE order_status= 'delivered'
     GROUP BY customer_uid
     )
     SELECT cd.delay_status,
     ROUND(
    COUNT(CASE WHEN co.total_orders > 1 THEN 1 END) * 100.0 / COUNT(*), 2
) AS repeat_rate_pct,
     COUNT(*) AS total_customers,
     COUNT(
     CASE
     WHEN co.total_orders> 1 THEN 1
     END)
     AS repeat_customers
     
     FROM customer_orders co 
     JOIN customer_delay cd
     ON co.customer_uid= cd.customer_uid
     GROUP BY cd.delay_status;
     
     -- 1.5 Payment Behaviour and Revenue Quality --
     
     SELECT payment_type, AVG(payment_installments) FROM order_payments
     GROUP BY payment_type;
     
     WITH order_value AS (
     SELECT order_id,
     SUM(price + freight_value) AS order_value
     FROM order_items
     GROUP BY order_id
)
SELECT 
AVG(order_value) AS avg_order_value,
payment_installments
FROM order_payments op
JOIN order_value ov
ON op.order_id = ov.order_id
GROUP BY payment_installments
ORDER BY payment_installments;

-- Revenue Leakage from Non-delivered orders --

-- Leakage by order status

SELECT 
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS lost_gross_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status IN ('cancelled', 'unavailable')
GROUP BY o.order_status
ORDER BY lost_gross_value DESC;

WITH total AS (
    SELECT SUM(oi.price + oi.freight_value) AS total_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
),
lost AS (
    SELECT SUM(oi.price + oi.freight_value) AS lost_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status IN ('cancelled', 'unavailable')
)
SELECT
    ROUND(lost_value, 2) AS lost_value,
    ROUND(total_value, 2) AS total_value,
    ROUND((lost_value / total_value) * 100, 2) AS leakage_pct
FROM total, lost;

