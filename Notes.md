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

"order_id","customer_id","order_status","order_purchase_timestamp","order_approved_at","order_delivered_carrier_date","order_delivered_customer_date","order_estimated_delivery_date"

|Name|Type|
|----|----|
|order_id|String|
|customer_id|String|
|order_status|String|
|order_purchase_timestamp|DateTime|
|order_approved_at|DateTime|
|order_delivered_carrier_date|DateTime|
|order_delivered_customer_date|DateTime|
|order_estimated_delivery_date|DateTime 