/* Most/Least Common payment type */
SELECT payment_type, COUNT(payment_type) as total_payment FROM olist_database.payments
GROUP BY payment_type
ORDER BY total_payment DESC;

/*Location with Most/Least Customers*/
Select customer_city, customer_state, COUNT(customer_unique_id) as total_unique_customers 
FROM olist_database.customers
GROUP BY customer_city, customer_state
ORDER by total_unique_customers DESC;


/*Location with Most/Least Customers*/
Select seller_city, seller_state, COUNT(seller_id) as total_sellers 
FROM olist_database.sellers
GROUP BY seller_city, seller_state
ORDER by total_sellers DESC;

/*Most/Least popular products_category ordered*/
WITH get_product_eng_name AS (
    SELECT p.product_id, p.product_category_name, 
    pc.product_category_name_english as eng_name
    FROM olist_database.products as p 
    JOIN olist_database.product_category as pc 
    ON p.product_category_name = pc.product_category_name
)
SELECT gp.eng_name, COUNT(oi.order_id) as total_ordered 
FROM olist_database.order_items as oi
JOIN get_product_eng_name as gp
ON oi.product_id = gp.product_id
GROUP BY gp.eng_name
ORDER BY total_ordered DESC;

WITH get_product_eng_name AS (
    SELECT p.product_id, p.product_category_name, 
    pc.product_category_name_english as eng_name
    FROM olist_database.products as p 
    JOIN olist_database.product_category as pc 
    ON p.product_category_name = pc.product_category_name
)
/* Most/Least popular product ordered*/
Select p.product_id, p.eng_name, COUNT(oi.order_id) as total_order
FROM get_product_eng_name as p
JOIN olist_database.order_items as oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.eng_name
ORDER BY total_order DESC;

/* Most/Least Profitable products */
WITH get_product_eng_name AS (
    SELECT p.product_id, p.product_category_name, 
    pc.product_category_name_english as eng_name
    FROM olist_database.products as p 
    JOIN olist_database.product_category as pc 
    ON p.product_category_name = pc.product_category_name
)
SELECT p.product_id, p.eng_name, SUM(oi.price - oi.freight_value) as profit
FROM get_product_eng_name as p
JOIN olist_database.order_items as oi
ON oi.product_id = p.product_id 
GROUP BY p.product_id, p.eng_name
ORDER BY profit DESC;

/* Most/Least Profitable product_category */
WITH get_product_eng_name AS (
    SELECT p.product_id, p.product_category_name, 
    pc.product_category_name_english as eng_name
    FROM olist_database.products as p 
    JOIN olist_database.product_category as pc 
    ON p.product_category_name = pc.product_category_name
)
SELECT p.eng_name, SUM(oi.price - oi.freight_value) as profit
FROM get_product_eng_name as p
JOIN olist_database.order_items as oi
ON oi.product_id = p.product_id 
GROUP BY p.eng_name
ORDER BY profit DESC;
