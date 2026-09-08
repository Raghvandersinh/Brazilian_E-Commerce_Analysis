/*-------------------------------------------------------------------------------------------------*/
/* Most/Least Common payment type */
/*-------------------------------------------------------------------------------------------------*/
COPY(
SELECT payment_type, COUNT(payment_type) as total_payment FROM olist_database.payments
GROUP BY payment_type
ORDER BY total_payment DESC
) TO 'data/queried_data/Common_Payment.csv' (HEADER, DELIMITER ',');

/*-------------------------------------------------------------------------------------------------*/
/*Location with Most/Least Customers*/
/*-------------------------------------------------------------------------------------------------*/

COPY(
Select customer_city, customer_state, COUNT(customer_unique_id) as total_unique_customers 
FROM olist_database.customers
GROUP BY customer_city, customer_state
ORDER by total_unique_customers DESC
) TO 'data/queried_data/Customer_Location.csv' (HEADER, DELIMITER ',');

/*-------------------------------------------------------------------------------------------------*/
/*Location with Most/Least Customers*/
/*-------------------------------------------------------------------------------------------------*/

COPY(
Select seller_city, seller_state, COUNT(seller_id) as total_sellers 
FROM olist_database.sellers
GROUP BY seller_city, seller_state
ORDER by total_sellers DESC
) TO 'data/queried_data/Seller_Location.csv' (HEADER, DELIMITER ',');

/*-------------------------------------------------------------------------------------------------*/
/*Most/Least popular products_category ordered*/
/*-------------------------------------------------------------------------------------------------*/

COPY(
WITH get_product_eng_name AS (
    SELECT p.product_id, p.product_category_name, 
    pc.product_category_name_english as eng_name
    FROM olist_database.products as p 
    JOIN olist_database.product_category as pc 
    ON p.product_category_name = pc.product_category_name
)
SELECT gp.eng_name,COUNT(oi.order_id) as total_ordered,
SUM(oi.price + oi.freight_value) as product_value,
ROW_NUMBER() OVER(ORDER BY COUNT(oi.order_id) ASC, SUM(oi.price + oi.freight_value) DESC) as ranked
FROM olist_database.order_items as oi
JOIN get_product_eng_name as gp
ON oi.product_id = gp.product_id
GROUP BY gp.eng_name
) TO 'data/queried_data/Popular_Product_Category.csv' (HEADER, DELIMITER ',');

/*-------------------------------------------------------------------------------------------------*/
/* Most/Least popular product ordered*/
/*-------------------------------------------------------------------------------------------------*/

COPY(
WITH get_product_eng_name AS (
    SELECT p.product_id, p.product_category_name, 
    pc.product_category_name_english as eng_name
    FROM olist_database.products as p 
    JOIN olist_database.product_category as pc 
    ON p.product_category_name = pc.product_category_name
)

Select p.product_id, p.eng_name, COUNT(oi.order_id) as total_order,
SUM(oi.price + oi.freight_value) as product_value,
ROW_NUMBER() OVER(ORDER BY COUNT(oi.order_id) ASC, SUM(oi.price + oi.freight_value) DESC) as ranked
FROM get_product_eng_name as p
JOIN olist_database.order_items as oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.eng_name
) TO 'data/queried_data/Popular_Product.csv' (HEADER, DELIMITER ',');

/*-------------------------------------------------------------------------------------------------*/
/* Products with best and worst reviews */
/*-------------------------------------------------------------------------------------------------*/
COPY(
WITH get_product_eng_name AS (
    SELECT p.product_id, p.product_category_name, 
    pc.product_category_name_english as eng_name
    FROM olist_database.products as p 
    JOIN olist_database.product_category as pc 
    ON p.product_category_name = pc.product_category_name
),
get_ordered_product AS(
    SELECT gp.product_id, gp.eng_name, oi.order_id 
    FROM get_product_eng_name gp
    JOIN olist_database.order_items oi ON gp.product_id = oi.product_id
),
get_order_review AS (
    SELECT gop.product_id, gop.eng_name, orr.review_score, orr.review_comment_message,
    orr.review_comment_title, 
    COUNT(review_id) OVER(PARTITION BY gop.product_id, orr.review_score) as count_score
    FROM get_ordered_product gop
    JOIN olist_database.order_reviews orr 
    ON orr.order_id = gop.order_id
)
SELECT * FROM get_order_review
) TO 'data/queried_data/Product_Review.csv' (HEADER, DELIMITER ',');
/*-------------------------------------------------------------------------------------------------*/
/*Most Product Ordered by year*/
/*-------------------------------------------------------------------------------------------------*/
COPY(
WITH get_product_eng_name AS (
    SELECT p.product_id, p.product_category_name,
    pc.product_category_name_english as eng_name
    FROM olist_database.products as p 
    JOIN olist_database.product_category as pc 
    ON p.product_category_name = pc.product_category_name
),
get_product_order_id AS (
    SELECT gp.eng_name, oi.order_id, gp.product_id, SUM(oi.freight_value + oi.price) as profit
    FROM olist_database.order_items as oi
    JOIN get_product_eng_name as gp
    ON oi.product_id = gp.product_id
    GROUP BY 1,2,3
),
get_delivered_date AS (
    SELECT STRFTIME(o.order_delivered_customer_date, '%Y-%m') as delivered_date, gp.eng_name, gp.product_id,
    gp.profit, COUNT(o.order_id) as total_ordered
    FROM olist_database.orders as o
    JOIN get_product_order_id as gp
    ON gp.order_id = o.order_id
    GROUP BY 1,2,3,4
    ORDER BY delivered_date
),
ranked_product AS (
    SELECT delivered_date, product_id, eng_name, total_ordered, profit,
    ROW_NUMBER() OVER(PARTITION BY delivered_date ORDER BY total_ordered DESC, profit DESC) as ranked_ordered 
    FROM get_delivered_date 
    where delivered_date IS NOT NULL
)
SELECT delivered_date, product_id, eng_name, total_ordered as most_ordered, profit as most_profit,
ranked_ordered
FROM ranked_product
Where ranked_ordered = 1
ORDER BY delivered_date ASC
) TO 'data/queried_data/Most_Popular_Product_Ordered_Trend.csv' (HEADER, DELIMITER ',');

/*-------------------------------------------------------------------------------------------------*/
/*Least Product Ordered by year*/
/*-------------------------------------------------------------------------------------------------*/
COPY(
WITH get_product_eng_name AS (
    SELECT p.product_id, p.product_category_name,
    pc.product_category_name_english as eng_name
    FROM olist_database.products as p 
    JOIN olist_database.product_category as pc 
    ON p.product_category_name = pc.product_category_name
),
get_product_order_id AS (
    SELECT gp.eng_name, oi.order_id, gp.product_id, SUM(oi.freight_value + oi.price) as profit
    FROM olist_database.order_items as oi
    JOIN get_product_eng_name as gp
    ON oi.product_id = gp.product_id
    GROUP BY 1,2,3
),
get_delivered_date AS (
    SELECT STRFTIME(o.order_delivered_customer_date, '%Y-%m') as delivered_date, gp.eng_name, gp.product_id,
    gp.profit, COUNT(o.order_id) as total_ordered
    FROM olist_database.orders as o
    JOIN get_product_order_id as gp
    ON gp.order_id = o.order_id
    GROUP BY 1,2,3,4
    ORDER BY delivered_date
),
ranked_product AS (
    SELECT delivered_date, product_id, eng_name, total_ordered, profit,
    Row_Number() OVER(PARTITION BY delivered_date ORDER BY total_ordered, profit) as ranked_ordered 
    FROM get_delivered_date
    where delivered_date IS NOT NULL
)
SELECT delivered_date, product_id, eng_name, total_ordered as least_ordered, profit as least_profit, 
ranked_ordered
FROM ranked_product
where ranked_ordered = 1
ORDER BY delivered_date ASC
) TO 'data/queried_data/Least_Popular_Product_Ordered_Trend.csv' (HEADER, DELIMITER ',');



/*-------------------------------------------------------------------------------------------*/
/*TEST*/
/*-------------------------------------------------------------------------------------------*/

WITH get_product_eng_name AS (
    SELECT p.product_id, p.product_category_name,
    pc.product_category_name_english as eng_name
    FROM olist_database.products as p 
    JOIN olist_database.product_category as pc 
    ON p.product_category_name = pc.product_category_name
),
get_product_order_id AS (
    SELECT gp.eng_name, oi.order_id, gp.product_id, SUM(oi.freight_value + oi.price) as profit
    FROM olist_database.order_items as oi
    JOIN get_product_eng_name as gp
    ON oi.product_id = gp.product_id
    GROUP BY 1,2,3
),
get_delivered_date AS (
    SELECT STRFTIME(o.order_delivered_customer_date, '%Y-%m') as delivered_date, gp.eng_name, gp.product_id,
    gp.profit, COUNT(o.order_id) as total_ordered
    FROM olist_database.orders as o
    JOIN get_product_order_id as gp
    ON gp.order_id = o.order_id
    GROUP BY 1,2,3,4
    ORDER BY delivered_date
)
SELECT DISTINCT delivered_date FROM get_delivered_date;