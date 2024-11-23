
create database walmart;

use walmart;


select *
from walmart_sales;

-- Question: What are the different payment methods, and how many transactions and
-- items were sold with each method?

SELECT
	payment_method,
    count(invoice_id) as total_transactions,
    sum(quantity) as total_items
FROM 
	walmart_sales
GROUP BY 
	payment_method;

-- Question: Which category received the highest average rating in each branch?

WITH average_rating_table AS (
SELECT 
	Branch, category, 
    round(avg(rating),2) as average_rating,
	dense_rank() over(partition by Branch order by round(avg(rating),2) desc) as rnk
FROM walmart_sales
GROUP BY Branch, category
)

SELECT 
	Branch, category, 
    average_rating as highest_average_rating
FROM 
	average_rating_table
WHERE 
	rnk = 1;

-- Question: What is the busiest day of the week for each branch based on transaction volume?

WITH transaction_volume_table AS 
	(
	SELECT 
		Branch, dayname(date) as name_of_day, 
		count(*) as no_of_transaction,
		dense_rank() over(partition by Branch order by count(*) desc) as rnk
	FROM 
		walmart_sales
	GROUP BY 
		Branch, dayname(date)
)

SELECT 
	Branch, name_of_day, no_of_transaction
FROM 
	transaction_volume_table
WHERE 
	rnk = 1;

-- Question: How many items were sold through each payment method?

SELECT 
	payment_method, sum(quantity) as total_items_sold
FROM 
	walmart_sales
GROUP BY 
	payment_method
ORDER BY 
	total_items_sold DESC;
 
-- Question: What are the average, minimum, and maximum ratings for each category in each city? 
 
SELECT 
	City, category, 
	round(avg(rating),2) as average_rating, round(min(rating),2) as minimum_rating,
	round(max(rating),2) as maximum_rating
FROM
	walmart_sales
GROUP BY 
	City, category
ORDER BY 
	City, category ASC;
 
-- Question: What is the total profit for each category, ranked from highest to lowest?
-- Consider total profit as (unit_price * quantity * profit_margin) 
SELECT 
	category, round(sum(total_profit),2) as profit
FROM ( 
	SELECT 
		category, (unit_price * quantity * profit_margin) as total_profit
	FROM 
		walmart_sales ) as total_profit_query
GROUP BY 
	category
ORDER BY 
	profit DESC;
 
-- Question: What is the most frequently used payment method in each branch?

SELECT 
	Branch, payment_method
FROM (
	SELECT 
		Branch, payment_method, count(payment_method) as most_frequent,
		rank() over(partition by Branch order by count(payment_method) desc) as rnk  
	FROM 
		walmart_sales
	GROUP BY
		Branch, payment_method ) as frequent_query
WHERE 
	rnk = 1
ORDER BY 
	Branch;


-- Question: How many transactions occur in each shift (Morning, Afternoon, Evening) across branches? 

WITH time_shift_table AS (
	SELECT *,
	CASE 
		WHEN extract(hour from time) < 12 THEN 'Morning'
		WHEN extract(hour from time) between 12 and 17 THEN 'Afternoon'
	ELSE 'Evening' END AS time_shift   
	FROM 
		walmart_sales)
SELECT 
	Branch, time_shift, count(invoice_id) as no_of_transaction
FROM 
	time_shift_table
GROUP BY 
	Branch, time_shift
ORDER BY 
	Branch;

-- Question:Which branches experienced the largest decrease in revenue compared to the previous year
-- Identify the top 5 branches with highest decrease ratio in revenue compare to last year
-- (current year 2023 last year 2022) 
-- revenue decrease ratio formula = last_year_rev - curr_year_rev / last_year_rev * 100 

WITH last_year_revenue AS
	(
    SELECT 
		Branch, round(sum(total)) as revenue
	FROM 
		walmart_sales
	WHERE 
		extract(year from date) = 2022 
	GROUP BY 
		Branch
),

curr_year_revenue AS
	(
    SELECT 
		Branch, round(sum(total)) as revenue
    FROM 
		walmart_sales
    WHERE 
		extract(year from date) = 2023
    GROUP BY 
		Branch
)

SELECT 
	last_year.Branch, last_year.revenue as ls_revenue, curr_year.revenue as cs_revenue,
	round(((last_year.revenue - curr_year.revenue) / last_year.revenue) * 100,2) as revenue_ratio
FROM 
	last_year_revenue as last_year
JOIN 
	curr_year_revenue as curr_year on last_year.Branch = curr_year.Branch
WHERE 
	last_year.revenue > curr_year.revenue
ORDER BY  
	revenue_ratio DESC
LIMIT 5;


 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 









 