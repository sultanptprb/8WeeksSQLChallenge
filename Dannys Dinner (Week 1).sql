/* --------------------
   Case Study Questions
   --------------------*/
   
USE dannys_diner;

-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) as total_spent FROM SALES
JOIN menu on sales.product_id = menu.product_id
GROUP BY customer_id
;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT( DISTINCT order_date) as Days FROM SALES
GROUP BY customer_id
;

-- 3. What was the first item from the menu purchased by each customer?
WITH ordered_sales AS (
  SELECT 
    sales.customer_id, 
    sales.order_date, 
    menu.product_name,
    RANK() OVER(
      PARTITION BY sales.customer_id 
      ORDER BY sales.order_date) AS ranks
  FROM sales
  JOIN menu
    ON sales.product_id = menu.product_id
)
SELECT 
  customer_id, 
  product_name
FROM ordered_sales
WHERE ranks = 1
GROUP BY customer_id, product_name
;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
  product_name,
  COUNT(sales.product_id) AS most_purchased_item
FROM sales
JOIN menu
  ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY most_purchased_item DESC
LIMIT 1
;

-- 5. Which item was the most popular for each customer?
WITH most_popular AS (
  SELECT 
    sales.customer_id, 
    menu.product_name, 
    COUNT(menu.product_id) AS order_count,
    RANK() OVER(
      PARTITION BY sales.customer_id 
      ORDER BY COUNT(sales.customer_id) DESC) AS ranks
  FROM menu
  JOIN sales
		ON menu.product_id = sales.product_id
  GROUP BY sales.customer_id, menu.product_name
)
SELECT 
  customer_id, 
  product_name, 
  order_count
FROM most_popular 
WHERE ranks = 1
;

-- 6. Which item was purchased first by the customer after they became a member?
WITH new_table AS(
	SELECT 
		sales.customer_id,
		order_date,
		join_date,
		product_name,
		RANK() OVER(
		  PARTITION BY sales.customer_id 
		  ORDER BY order_date) AS ranks
	FROM sales
	JOIN members 
		ON members.customer_id = sales.customer_id
	JOIN menu 
		ON sales.product_id = menu.product_id
	WHERE order_date >= join_date
)
SELECT 
	customer_id,
	order_date,
	product_name
FROM new_table
WHERE ranks = 1
;

-- 7. Which item was purchased just before the customer became a member?
WITH new_table AS(
	SELECT 
		sales.customer_id,
		order_date,
		join_date,
		product_name,
		RANK() OVER(
		  PARTITION BY sales.customer_id 
		  ORDER BY order_date) AS ranks
	FROM sales
	JOIN members 
		ON members.customer_id = sales.customer_id
	JOIN menu 
		ON sales.product_id = menu.product_id
	WHERE order_date < join_date
)
SELECT 
	customer_id,
	order_date,
	product_name
FROM new_table
WHERE ranks= 1
;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
	sales.customer_id,
	COUNT(product_name) as total_product,
    SUM(price) as total_price
FROM sales
JOIN members 
	ON members.customer_id = sales.customer_id
JOIN menu 
	ON sales.product_id = menu.product_id
WHERE order_date < join_date
GROUP BY sales.customer_id 
;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	customer_id,
	SUM(CASE
			WHEN product_name = 'sushi' THEN price*20
			ELSE price*10
		END) AS points
FROM menu
JOIN sales
	ON sales.product_id = menu.product_id
GROUP BY customer_id
;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT
	sales.customer_id,
	SUM(CASE
		WHEN order_date BETWEEN join_date AND join_date + 6 THEN price * 20
		WHEN product_name = 'sushi' THEN price*20
		ELSE price*10
	END) AS points
FROM menu
JOIN sales
	ON sales.product_id = menu.product_id
JOIN members
	ON members.customer_id = sales.customer_id
WHERE order_date <= '2021-01-31'
GROUP BY sales.customer_id
;

-- Thank You --