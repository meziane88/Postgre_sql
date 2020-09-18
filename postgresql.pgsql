-- Exploration avec DISTINCT COUNT et GROUP BY
--============================================

SELECT * from film;

-- Différentes notes (colonne rating) des Etats_unis.
SELECT DISTINCT rating FROM film;

-- Différents taux de location (colonne rental_rate)
SELECT DISTINCT rental_rate FROM film;

-- Nbre des différents rating 
SELECT count(*), rating FROM film GROUP BY rating; 

-- Nbre des différents rental_rate
SELECT count(*), rental_rate FROM film GROUP BY rental_rate ORDER BY rental_rate;

-- Commande EXTRACT
--=================
SELECT * FROM rental;

-- Nbre de Rentals selon la date 
SELECT rental_date, count(rental_id) AS total_rentals
FROM rental
GROUP by rental_date
order by total_rentals DESC;

-- Extraire soit l'année soit le mois
SELECT EXTRACT(YEAR FROM rental_date), 
EXTRACT(MONTH FROM rental_date), 
count(rental_id) as total_rentals,
count(DISTINCT customer_id) as unique_rental,
round(1.0 * count(rental_id)/count(DISTINCT customer_id), 2) as average
FROM rental
GROUP by 1, 2;

-- Exploration avec WHERE
--=======================
SELECT * from customer;
SELECT * from address; 

-- L'email d'une personne qui s'appel 'Goria' 'Cook
SELECT email FROM customer WHERE first_name = 'Gloria' AND last_name = 'Cook'; 

-- Récupérer la discription d'un film dont le titre est 'Texas Watch'
SELECT description from film WHERE title = 'Texas Watch'; 

-- récuperation d'un numéro de téléphone à patir d'une adresse _group_concat
SELECT phone FROM address WHERE address = '270 Toulon Boulevard';

-- Commande IN
--============
    -- WHERE colonne IN (valeur1, valeur2 ...);
    -- WHERE colonne1 IN (SELECT colonne2 FROM table);
    -- NOT IN

SELECT * from rental;

-- les return_date des clinets 1 et 2
SELECT customer_id, rental_id, return_date
FROM rental
where customer_id in(1,2)
order by return_date desc; 

-- les return_date sauf celles des clinets 1 et 2
SELECT customer_id, rental_id, return_date
FROM rental
where customer_id not in(1,2)
order by return_date desc; 

-- La commande LIKE
--==================

-- client dont le nom commence par 'Jen'
    -- 'Jen%' commence avec Jen 
SELECT first_name, last_name
FROM customer
WHERE first_name like 'Jen%'; 

    -- 'Jen_' commence avec Jen avec une seule lettre en plus à la fin
SELECT first_name, last_name
FROM customer
WHERE first_name like 'Jen__';

SELECT first_name, last_name
FROM customer
WHERE first_name like 'Jenn_';

SELECT first_name, last_name
FROM customer
WHERE first_name like '%er_';

SELECT first_name, last_name
FROM customer
WHERE first_name like '%er___';

    -- Nbre d'acteur dont le nom commence par P 
 SELECT count(first_name) from actor  where first_name like 'P%';

    -- les film qui conntiennent Truman dans leur titre
SELECT title from film where title like '%Truman%';

    -- client qui a le plus grand customer id et dont le prénon commence par 'E' et a un adress id inférieur à 500
SELECT first_name, last_name 
from customer 
where last_name like 'E%' and address_id < 500
order by customer_id desc 
limit 1;  


-- Challenge GROUP BY
--===================

    -- l'équipe qui a obtenue le plus de paiements
SELECT * from payment;
SELECT sum(amount), staff_id, count(amount) FROM payment group by staff_id;

SELECT rating, round(avg(replacement_cost), 2) AS avg_replacement_cost
FROM film
GROUP BY rating;

    -- les 5 clients qui ont dépensé le plus d'argent dans notre magasin.
SELECT * from payment;

SELECT customer_id, sum(amount)
FROM payment
GROUP BY customer_id
order by sum(amount) desc
LIMIT 5;

-- Challenge HAVING il s'applique sur des colonnes virtuelles crée avec des fonction d'agregation
SELECT rating, round(avg(rental_rate), 2)
from film
where rating in ('R', 'G', 'PG')
group by rating
HAVING avg(rental_rate) > 3;

    -- Clients qui totalisent au moins 30 transaction de payement (table payment)
SELECT * from payment; 
SELECT customer_id, count(amount)
FROM payment
GROUP BY customer_id
HAVING count(amount) > 30
order by count(amount) desc;

    -- Notations (R, PG ....) dont la durée de location moyenne est supérieure à 5 jours _group_concat
SELECT * from film; 
SELECT rating, ROUND(avg(rental_duration), 2)
FROM film
GROUP BY rating
HAVING AVG(rental_duration) > 5;

    -- Les IDCLIENTS qui ont payés plus de 110 $ à l'équipe staff 2         
SELECT customer_id, SUM(amount), staff_id
FROM payment
GROUP BY customer_id, staff_id
HAVING SUM(amount) > 110 AND staff_id = 2;

-- LES JOINTURES 
    -- INNER JOIN
SELECT payment.customer_id, first_name, last_name, email, SUM(amount)
FROM customer
INNER JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY payment.customer_id, first_name, last_name, email
HAVING SUM(amount) > 100
ORDER BY SUM(amount) DESC;

SELECT store_id, title, COUNT(title) AS number_at_store
FROM inventory
INNER JOIN film ON inventory.film_id = film.film_id
GROUP BY store_id, title
ORDER BY TITLE;

SELECT title, name
FROM FILM 
INNER JOIN language ON language.language_id = film.language_id;


    -- La liste de tous les titres des films avec leurs categories et langues

SELECT F.film_id, F.title, C.name AS CATEGORIE, L.name AS LANGUE
FROM film F
INNER JOIN film_category FC ON FC.film_id = F.film_id
INNER JOIN category C ON C.category_id = FC.category_id
INNER JOIN language L ON L.language_id = F.language_id;



----- CHALLLENGE MARKETING 1 : LES FILMS QUI RAPPORTENT LE PLUS

SELECT * FROM film;
SELECT COUNT(distinct rental_id) FROM rental;
SELECT * FROM inventory;
SELECT F.title ,count(rental_id) as number_of_rentals, rental_rate, (rental_rate * count(rental_id)) as recette_film
FROM film F
INNER JOIN inventory I ON F.film_id = I.film_id
INNER JOIN rental R ON R.inventory_id = I.inventory_id
GROUP BY title, rental_rate
ORDER BY recette_film desc;

----- CHALLENGE MARKETING 2: QUEL EST LE MAGASIN QUI A VENDU LE PLUS :
SELECT * FROM staff;
SELECT S.staff_id AS magasin ,SUM(amount) AS recette_magasin
FROM payment P
INNER JOIN staff S ON P.staff_id = S.staff_id
GROUP BY S.staff_id
ORDER BY S.staff_id DESC;

SELECT store_id, SUM(P.amount) AS revenue
FROM inventory I
INNER JOIN rental R ON R.inventory_id = I.inventory_id
INNER JOIN payment P ON P.rental_id = R.rental_id
GROUP BY store_id
ORDER BY REVENUE DESC;

----- CHALLENGE MARKETING 3 : NOMBRE DE LOCATIONS FILMS D'ACTION, COMEDIES ET ANIMATION
SELECT C.name, COUNT(rental_id) AS number_of_rentals
FROM category C
INNER JOIN film_category FC ON FC.category_id = C.category_id 
INNER JOIN film F ON FC.film_id = F.film_id
INNER JOIN inventory I ON F.film_id = I.film_id
INNER JOIN rental R ON R.inventory_id = R.inventory_id
WHERE C.name IN ('Action', 'Comedy', 'Animation')
GROUP BY C.name 
ORDER BY number_of_rentals DESC
 ;

 ----- CHALLENGE MARKETING 4 : OFFRE PROMO A TOUS LES CLIENT QUI ONT + DE 40 LOCATION
SELECT C.customer_id, C.first_name, C.last_name,C.email, COUNT(R.rental_id) AS number_of_rentals
FROM customer C
INNER JOIN rental R ON C.customer_id = R.customer_id
GROUP BY C.customer_id, C.first_name, C.last_name, C.email
HAVING COUNT(R.rental_id) >= 40
ORDER BY number_of_rentals;
 -----

