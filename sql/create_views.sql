-- =====================================================
-- Olist SQL + Power BI Project
-- File: create_views.sql
-- Database: PostgreSQL
-- Purpose: Create analytical views for Power BI dashboard
-- =====================================================

-- 1. Monthly revenue analysis
CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS order_month,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY order_month;

-- 2. Product category performance
CREATE OR REPLACE VIEW vw_product_category_performance AS
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS product_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
LEFT JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(t.product_category_name_english, p.product_category_name, 'unknown')
ORDER BY total_revenue DESC;

-- 3. State-wise revenue performance
CREATE OR REPLACE VIEW vw_state_revenue_performance AS
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- 4. Payment type performance
CREATE OR REPLACE VIEW vw_payment_type_performance AS
SELECT
    op.payment_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(*) AS total_payment_records,
    ROUND(SUM(op.payment_value), 2) AS total_payment_value,
    ROUND(AVG(op.payment_value), 2) AS average_payment_value,
    ROUND(AVG(op.payment_installments), 2) AS average_installments
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
GROUP BY op.payment_type
ORDER BY total_payment_value DESC;

-- 5. Customer repeat purchase behavior
CREATE OR REPLACE VIEW vw_customer_repeat_behavior AS
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        MIN(o.order_purchase_timestamp)::DATE AS first_order_date,
        MAX(o.order_purchase_timestamp)::DATE AS last_order_date,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    total_orders,
    first_order_date,
    last_order_date,
    total_spent,
    CASE
        WHEN total_orders = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type
FROM customer_orders;

-- 6. RFM customer segmentation
CREATE OR REPLACE VIEW vw_rfm_customer_segments AS
WITH customer_rfm AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp)::DATE AS last_purchase_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS monetary,
        (
            (SELECT MAX(order_purchase_timestamp)::DATE FROM orders)
            - MAX(o.order_purchase_timestamp)::DATE
        ) AS recency_days
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_rfm
)
SELECT
    customer_unique_id,
    last_purchase_date,
    recency_days,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    recency_score + frequency_score + monetary_score AS rfm_total_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
        WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
        WHEN recency_score = 1 AND frequency_score <= 2 THEN 'Lost Customers'
        ELSE 'Regular Customers'
    END AS customer_segment
FROM rfm_scores;

-- 7. Monthly new vs returning customers
CREATE OR REPLACE VIEW vw_monthly_new_returning_customers AS
WITH customer_first_order AS (
    SELECT
        c.customer_unique_id,
        MIN(DATE_TRUNC('month', o.order_purchase_timestamp)::DATE) AS first_order_month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
monthly_orders AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS order_month,
        c.customer_unique_id
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        DATE_TRUNC('month', o.order_purchase_timestamp)::DATE,
        c.customer_unique_id
)
SELECT
    mo.order_month,
    COUNT(DISTINCT CASE
        WHEN cfo.first_order_month = mo.order_month
        THEN mo.customer_unique_id
    END) AS new_customers,
    COUNT(DISTINCT CASE
        WHEN cfo.first_order_month < mo.order_month
        THEN mo.customer_unique_id
    END) AS returning_customers,
    COUNT(DISTINCT mo.customer_unique_id) AS total_active_customers
FROM monthly_orders mo
JOIN customer_first_order cfo
    ON mo.customer_unique_id = cfo.customer_unique_id
GROUP BY mo.order_month
ORDER BY mo.order_month;

-- 8. Delivery performance
CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    o.order_id,
    c.customer_state,
    o.order_purchase_timestamp::DATE AS purchase_date,
    o.order_delivered_customer_date::DATE AS delivered_date,
    o.order_estimated_delivery_date::DATE AS estimated_delivery_date,
    DATE_PART('day', o.order_delivered_customer_date - o.order_purchase_timestamp) AS actual_delivery_days,
    DATE_PART('day', o.order_estimated_delivery_date - o.order_purchase_timestamp) AS estimated_delivery_days,
    DATE_PART('day', o.order_delivered_customer_date - o.order_estimated_delivery_date) AS delivery_delay_days,
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On Time'
        ELSE 'Delayed'
    END AS delivery_status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL;

-- 9. Review satisfaction
CREATE OR REPLACE VIEW vw_review_satisfaction AS
SELECT
    r.review_score,
    CASE
        WHEN r.review_score >= 4 THEN 'Satisfied'
        WHEN r.review_score = 3 THEN 'Neutral'
        ELSE 'Dissatisfied'
    END AS satisfaction_group,
    COUNT(DISTINCT r.order_id) AS total_orders,
    ROUND(AVG(dp.actual_delivery_days)::NUMERIC, 2) AS avg_delivery_days,
    ROUND(AVG(dp.delivery_delay_days)::NUMERIC, 2) AS avg_delay_days
FROM order_reviews r
LEFT JOIN vw_delivery_performance dp
    ON r.order_id = dp.order_id
GROUP BY
    r.review_score,
    CASE
        WHEN r.review_score >= 4 THEN 'Satisfied'
        WHEN r.review_score = 3 THEN 'Neutral'
        ELSE 'Dissatisfied'
    END
ORDER BY r.review_score;

-- 10. Delivery by state
CREATE OR REPLACE VIEW vw_delivery_by_state AS
SELECT
    customer_state,
    COUNT(*) AS total_delivered_orders,
    ROUND(AVG(actual_delivery_days)::NUMERIC, 2) AS avg_delivery_days,
    ROUND(AVG(delivery_delay_days)::NUMERIC, 2) AS avg_delay_days,
    COUNT(CASE WHEN delivery_status = 'On Time' THEN 1 END) AS on_time_orders,
    COUNT(CASE WHEN delivery_status = 'Delayed' THEN 1 END) AS delayed_orders,
    ROUND(
        100.0 * COUNT(CASE WHEN delivery_status = 'On Time' THEN 1 END) / COUNT(*),
        2
    ) AS on_time_delivery_rate
FROM vw_delivery_performance
GROUP BY customer_state
ORDER BY on_time_delivery_rate DESC;
