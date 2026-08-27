-- E-Commerce Business Analyst Portfolio Project
-- MySQL 8+

CREATE DATABASE IF NOT EXISTS ecommerce_ba;
USE ecommerce_ba;

-- Load CSVs using your local MySQL import method.

-- 1. Total orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- 2. Total order value
SELECT SUM(order_value) AS total_order_value
FROM orders;

-- 3. Cancellation rate
SELECT
  ROUND(100.0 * SUM(status = 'Cancelled') / COUNT(*), 2) AS cancellation_rate_pct
FROM orders;

-- 4. Return rate
SELECT
  ROUND(100.0 * SUM(status = 'Returned') / COUNT(*), 2) AS return_rate_pct
FROM orders;

-- 5. On-time delivery rate
SELECT
  ROUND(
    100.0 * SUM(status = 'Delivered' AND actual_delivery <= promised_delivery)
    / NULLIF(SUM(status = 'Delivered'),0), 2
  ) AS on_time_delivery_pct
FROM orders;

-- 6. Monthly order trend
SELECT
  DATE_FORMAT(order_date, '%Y-%m') AS month,
  COUNT(*) AS orders,
  SUM(order_value) AS order_value
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- 7. Category performance
SELECT
  p.category,
  COUNT(o.order_id) AS orders,
  SUM(o.order_value) AS order_value,
  ROUND(100.0 * SUM(o.status = 'Cancelled') / COUNT(*), 2) AS cancellation_rate_pct
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY order_value DESC;

-- 8. Late delivered orders
SELECT
  order_id,
  customer_id,
  promised_delivery,
  actual_delivery,
  DATEDIFF(actual_delivery, promised_delivery) AS delay_days
FROM orders
WHERE status = 'Delivered'
  AND actual_delivery > promised_delivery
ORDER BY delay_days DESC;

-- 9. Data quality check: duplicate order IDs
SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 10. Missing critical dates
SELECT COUNT(*) AS missing_promised_delivery
FROM orders
WHERE promised_delivery IS NULL;
