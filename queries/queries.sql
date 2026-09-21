/*-------------------------------------------------------------------------------------------------*/
/* Most/Least Common payment type */
/*-------------------------------------------------------------------------------------------------*/
COPY(
SELECT payment_type, COUNT(payment_type) as total_payment FROM olist_database.payments
GROUP BY payment_type
ORDER BY total_payment DESC
) TO 'data/queried_data/Common_Payment.csv' (HEADER, DELIMITER ',');


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
    Row_Number() OVER(PARTITION BY delivered_date ORDER BY total_ordered ASC, profit DESC) as ranked_ordered 
    FROM get_delivered_date
    where delivered_date IS NOT NULL
)
SELECT delivered_date, product_id, eng_name, total_ordered as least_ordered, profit as least_profit, 
ranked_ordered
FROM ranked_product
where ranked_ordered = 1
ORDER BY delivered_date ASC
) TO 'data/queried_data/Least_Popular_Product_Ordered_Trend.csv' (HEADER, DELIMITER ',');



/*---------------------------------------------------------------------------------------------*/
/* Most Profited Product By Year */
/*---------------------------------------------------------------------------------------------*/
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
    SELECT delivered_date, product_id, eng_name, total_ordered, profit, (profit * total_ordered) as most_profited,
    ROW_NUMBER() OVER(PARTITION BY delivered_date ORDER BY (profit * total_ordered) DESC) as ranked_profit
    FROM get_delivered_date 
    where delivered_date IS NOT NULL
)
SELECT delivered_date, product_id, eng_name, total_ordered, profit, most_profited
ranked_profit
FROM ranked_product
Where ranked_profit = 1
ORDER BY delivered_date ASC
) TO 'data/queried_data/Most_Popular_Product_Profited_Trend.csv' (HEADER, DELIMITER ',');


/*---------------------------------------------------------------------------------------------*/
/* Least Profited Product */
/*---------------------------------------------------------------------------------------------*/

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
    SELECT delivered_date, product_id, eng_name, total_ordered, profit, (profit * total_ordered) as least_profited,
    Row_Number() OVER(PARTITION BY delivered_date ORDER BY (profit * total_ordered)) as ranked_profits
    FROM get_delivered_date
    where delivered_date IS NOT NULL
)
SELECT delivered_date, product_id, eng_name, total_ordered, profit, least_profited
ranked_profits
FROM ranked_product
where ranked_profits = 1
ORDER BY delivered_date ASC
) TO 'data/queried_data/Least_Popular_Product_Profited_Trend.csv' (HEADER, DELIMITER ',');

/*-------------------------------------------------------------------------------------------*/
/*Profit Trend*/
/*-------------------------------------------------------------------------------------------*/
COPY(
    SELECT STRFTIME(o.order_delivered_customer_date, '%Y-%m'), SUM(oi.freight_value + oi.price) as profit 
    FROM olist_database.order_items as oi
    JOIN olist_database.orders as o
    ON o.order_id = oi.order_id
    GROUP BY 1
) TO 'data/queried_data/Profit_Trend.csv' (HEADER, DELIMITER ',');

/*-------------------------------------------------------------------------------------------*/
/*Unique Brazil GeoLocations*/
/*-------------------------------------------------------------------------------------------*/
COPY(
Select DISTINCT MAX(geolocation_zip_code_prefix), geolocation_state, geolocation_city
,MAX(geolocation_lat), MAX(geolocation_lng)
FROM olist_database.geolocation
GROUP BY 2,3
) TO 'data/queried_data/geolocations.csv' (FORMAT CSV,HEADER, DELIMITER ',', FORCE_QUOTE *);

/*-------------------------------------------------------------------------------------------*/
/*Total Unique Customers per Location with parallels*/
/*-------------------------------------------------------------------------------------------*/
COPY(
WITH get_unique_customers AS(
    Select customer_zip_code_prefix, customer_city, customer_state, 
    COUNT(customer_unique_id) as total_unique_customers,
    FROM olist_database.customers 
    GROUP BY 1,2,3
    ORDER by total_unique_customers DESC
)
Select c.customer_zip_code_prefix, c.customer_city, c.customer_state, c.total_unique_customers,
MAX(g.geolocation_lat) as single_lat, MAX(g.geolocation_lng) as single_lng
FROM get_unique_customers c
JOIN olist_database.geolocation g ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
GROUP BY 1,2,3,4
ORDER by total_unique_customers DESC
) TO 'data/queried_data/Customer_Location.csv' (HEADER, DELIMITER ',');

/*-------------------------------------------------------------------------------------------------*/
/*Location with Most/Least Sellers with parallels*/
/*-------------------------------------------------------------------------------------------------*/

COPY(
WITH get_total_unique_sellers AS(
    Select s.seller_zip_code_prefix,s.seller_city, s.seller_state, COUNT(s.seller_id) as total_sellers,
    FROM olist_database.sellers s
    GROUP BY 1,2,3
    ORDER by total_sellers DESC
)
Select s.seller_zip_code_prefix,s.seller_city, s.seller_state, s.total_sellers,
MAX(g.geolocation_lat) as single_lat, MAX(g.geolocation_lng) as single_lng
FROM get_total_unique_sellers s
JOIN olist_database.geolocation g ON g.geolocation_zip_code_prefix = s.seller_zip_code_prefix
GROUP BY 1,2,3,4
ORDER by total_sellers DESC
) TO 'data/queried_data/Seller_Location.csv' (HEADER, DELIMITER ',');

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

COPY(
Select DISTINCT geolocation_zip_code_prefix, geolocation_state, geolocation_city
,MAX(geolocation_lat), MAX(geolocation_lng)
FROM olist_database.geolocation
GROUP BY 1,2,3
) TO 'data/queried_data/geolocations.csv' (FORMAT CSV,HEADER, DELIMITER ',', FORCE_QUOTE *);


Select p.product_id, o.freight_value + o.price From olist_database.products p 
JOIN olist_database.order_items o 
ON o.product_id = p.product_id
WHERE p.product_id = '1bdf5e6731585cf01aa8169c7028d6ad'
