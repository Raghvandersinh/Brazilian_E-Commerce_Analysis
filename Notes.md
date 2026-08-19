Olist Data Strcuture:
customers: 

|Name|Type|
|----|----|
|customer_id|String|
|customer_unique_id|String|
|customer_zip_code_prefix|String|
|customer_city|String|
|customer_state|String|

geolocation:

|Name|Type|
|----|----|
|geolocation_zip_code_prefix|String|
|geolocation_lat|Float|
|geolocation_lng|Float|
|geolocation_city|String|
|geolocation_state|String|

order_items:

|Name|Type|
|----|----|
|order_id|String|
|order_item_id|int|
|product_id|String|
|seller_id|String|
|shipping_limit_date|DateTime|
|price|Float|
|freight_value|Float|

order_payments:

|Name|Type|
|----|----|
|order_id|String|
|payment_sequential|int|
|payment_type|String|
|payment_installments|int|
|payment_value|Float|

order_reviews:

|Name|Type|
|----|----|
|review_id|String|
|order_id|String|
|review_score|int|
|review_comment_title|String|
|review_comment_message|String|
|review_creation_date|DateTime|
|review_answer_timestamp|DateTime|

orders:

|Name|Type|
|----|----|
|order_id|String|
|customer_id|String|
|order_status|String|
|order_purchase_timestamp|DateTime|
|order_approved_at|DateTime|
|order_delivered_carrier_date|DateTime|
|order_delivered_customer_date|DateTime|
|order_estimated_delivery_date|DateTime|

products:

|Name|Type|
|----|----|
|product_id|String|
|product_category_name|String|
|product_name_lenght|Int|
|product_description_lenght|Int|
|product_photos_qty|Int|
|product_weight_g|Int|
|product_length_cm|Int|
|product_height_cm|Int|
|product_width_cm|Int|

sellers:

|Name|Type|
|----|----|
|seller_id|String|
|seller_zip_code_prefix|String|
|seller_city|String|
|seller_state"|String|

product_category_name_translation.csv