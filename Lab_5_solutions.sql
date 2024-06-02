-- Write SQL queries to perform the following tasks using the Sakila database:
USE sakila;
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

-- Find list of film_id for "Hunchback Impossible"
SELECT film_id, title FROM sakila.film
WHERE title = "HUNCHBACK IMPOSSIBLE";

-- Find inventory_id list for selected film_id
SELECT inventory_id FROM sakila.inventory
WHERE film_id IN (SELECT film_id FROM sakila.film
WHERE title = "HUNCHBACK IMPOSSIBLE");

-- Count entries in inventory and join to display title
SELECT a.title AS Title, COUNT(b.inventory_id) AS Number_in_inventory FROM sakila.film AS a
JOIN sakila.inventory AS b
ON a.film_id = b.film_id
WHERE a.film_id IN (SELECT a.film_id FROM sakila.film
WHERE a.title = "HUNCHBACK IMPOSSIBLE")
GROUP BY a.title;

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.

-- Calculate average length of films
SELECT AVG(length) FROM sakila.film;

-- Use subquery to filter global title list and use ORDER BY to confirm
SELECT title, length FROM sakila.film
WHERE length > (SELECT AVG(length) FROM sakila.film)
ORDER BY length DESC;

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".

-- Get film_id for Alone Trip: 17
SELECT film_id FROM sakila.film
WHERE title = "Alone Trip";

-- Match film_id to generate list of actor_ids
SELECT actor_id FROM sakila.film_actor
WHERE film_id IN (SELECT film_id FROM sakila.film
WHERE title = "Alone Trip");

-- Match list of actor_ids to generate full names of actors
SELECT CONCAT(first_name," ", last_name) AS Actors_in_Alone_Trip FROM sakila.actor
WHERE actor_id IN (SELECT actor_id FROM sakila.film_actor
WHERE film_id IN (SELECT film_id FROM sakila.film
WHERE title = "Alone Trip"));

-- Bonus:

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.

-- Identify family category id: 8
SELECT category_id FROM sakila.category
WHERE name = "Family";

-- Get list of film_ids under category_id 8
SELECT film_id FROM sakila.film_category
WHERE category_id = (SELECT category_id FROM sakila.category
WHERE name = "Family");

-- Get list of titles that correspond to the list of film_ids
SELECT title AS title FROM sakila.film
WHERE film_id IN (SELECT film_id FROM sakila.film_category
WHERE category_id = (SELECT category_id FROM sakila.category
WHERE name = "Family"));

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.

-- Get list using subqueries - skips out null values
SELECT CONCAT(first_name," ", last_name) AS Name, email FROM sakila.customer
WHERE address_id IN (SELECT address_id FROM sakila.address
WHERE city_id IN (SELECT city_id FROM sakila.city
WHERE country_id = (SELECT country_id FROM sakila.country
WHERE country = "Canada")));

-- Get list using joins - includes null values
SELECT CONCAT(d.first_name," ", d.last_name) AS Name, d.email, b.city, a.country FROM sakila.country AS a
LEFT JOIN sakila.city AS b
ON a.country_id = b.country_id
LEFT JOIN sakila.address AS c
ON b.city_id = c.city_id
LEFT JOIN sakila.customer AS d
ON c.address_id = d.address_id
WHERE a.country = "Canada";

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

-- Find most prolific actor by actor_id: 107
SELECT actor_id, COUNT(film_id) AS No_of_films FROM sakila.film_actor
GROUP BY actor_id
ORDER BY No_of_films DESC
LIMIT 1;

-- List films starred in 
SELECT title FROM sakila.film
WHERE film_id IN (SELECT film_id FROM sakila.film_actor
WHERE actor_id = 107);

-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

-- Find most profitable customer_id: 526
SELECT customer_id, SUM(amount) AS Total_payments_$ FROM sakila.payment
GROUP BY customer_id
ORDER BY Total_payments_$ DESC
LIMIT 1;

-- Match id to rentals via inventory table
SELECT title FROM sakila.film
	WHERE film_id IN (
		SELECT film_id FROM sakila.inventory
			WHERE inventory_id IN (SELECT inventory_id FROM sakila.rental
				WHERE customer_id IN (SELECT customer_id FROM (SELECT customer_id, SUM(amount) AS Total_payments_$ FROM sakila.payment
				GROUP BY customer_id
				ORDER BY Total_payments_$ DESC
				LIMIT 1) AS c)));

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.

-- Calculate average amount spent by clients
SELECT SUM(amount)/COUNT(DISTINCT customer_id) AS Average_spent FROM sakila.payment;

-- Use average figure to filter table
SELECT customer_id, SUM(amount) AS total_amount_spent FROM sakila.payment 
GROUP BY customer_id 
HAVING total_amount_spent > (SELECT SUM(amount)/COUNT(DISTINCT customer_id) AS Average_spent FROM sakila.payment)
ORDER BY total_amount_spent DESC;


