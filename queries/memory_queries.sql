COPY(
WITH count_star_reviews AS (
Select product_id, eng_name, review_score, COUNT(review_score) as star_review 
FROM 'data/queried_data/Product_Reviews_Eng.csv'
GROUP BY 1,2,3
Order By product_id DESC
),
get_total_review AS (
SELECT *, SUM(star_review) OVER(PARTITION BY product_id) as total_reviews 
FROM count_star_reviews 
)
Select *, 100 * star_review/NULLIF(total_reviews, 0) as review_percentile 
FROM get_total_review
ORDER BY product_id DESC
) TO 'data/queried_data/Product_Reviews_Eng_Review_Percentile.csv' (HEADER, DELIMITER ',');