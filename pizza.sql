
create database pizzahut;
use pizzahut;
show tables;
select * from pizzas;
select * from pizza_types;

create table orders (order_id int primary key not null  ,
 order_date date not null , order_time time not null);
 select * from orders;

 create table order_details(ordre_details_id int primary key not null , 
 order_id int not null , pizza_id text not null , quantity int not null);
select * from order_details;

-- 1- retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;  -- total_orders - 21350

-- 2- calculate the tatal revenue generated from pizza sales.
select round(sum(order_details.quantity * pizzas.price),2) as total_sales 
from order_details join pizzas on pizzas.pizza_id = order_details.pizza_id; -- total_sales - 817860

use pizzahut;
-- 3- identify the highest-priced pizza.
select pizza_types.name , pizzas.price from pizza_types join pizzas on
 pizza_types.pizza_type_id = pizzas.pizza_type_id
 order by pizzas.price desc limit 1;  -- The Greek Pizza - 35.95

-- second methord 
 SELECT * FROM pizzas ORDER BY price DESC LIMIT 1;

-- 4- Identity the most common pizza size ordered.
select quantity , count(ordre_details_id) from order_details group by quantity;
select pizzas.size , count(order_details.ordre_details_id) as order_count
from pizzas join order_details 
on pizzas.pizza_id = order_details.pizza_id group by pizzas.size 
order by order_count desc limit 1;  -- L-18526 
-- second methord
SELECT p.size, COUNT(*) AS order_count FROM order_details as od
JOIN pizzas as p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;

-- 5- list the top 5 most ordered pizza types along with their quantities.
select pizza_types.name , sum(order_details.quantity)as quantity from pizza_types
 join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id 
group by pizza_types.name order by quantity desc limit 5; 
-- second methord
SELECT p.pizza_type_id, SUM(od.quantity) AS total_quantity FROM order_details as od
JOIN pizzas as p ON od.pizza_id = p.pizza_id
GROUP BY p.pizza_type_id
ORDER BY total_quantity DESC
LIMIT 5;

-- the classic deluxe pizza 2453
-- the barbucue chicken pizza 2432
-- the hawailan pizza 2422
-- the pepperoni pizza 2418
-- the thai chicken pizza 2371

-- 6- join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category , sum(order_details.quantity)
 as quantity from pizza_types join pizzas on 
 pizza_types.pizza_type_id = pizzas.pizza_type_id join
 order_details on order_details.pizza_id = pizzas.pizza_id
 group by pizza_types.category order by quantity desc;
-- classic 14888 
-- supreme 11987
-- veggie 11649
-- chicken 11050

-- 7- detemine the distritution of orders by hour of the day.
select * from orders;
select hour(order_time) as hour, count(order_id)as order_count from orders
group by hour(order_time);
-- 12 2520
-- 13 2455
-- 18 2399
-- 17 2336
-- second methord
SELECT 
    EXTRACT(HOUR FROM order_time) AS hour,
    COUNT(*) AS order_count
FROM orders
GROUP BY hour
ORDER BY hour;

-- 8- join relevent tables to find the category-wise destrubution of pizzas.
use pizzahut;
select category , count(name) from pizza_types
group by category;
-- second methord
SELECT pt.category, COUNT(*) AS pizza_count
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY pizza_count DESC;


-- 9- group the orders by date and calulate the average number of pizzas ordered per day.
select round(avg(quantity),0) as avg_pizza_order_per_day from 
(select orders.order_date , sum(order_details.quantity)as quantity
from orders join order_details on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity; -- per day pizza order-138
-- second methord
select * from orders;
SELECT AVG(daily_total) AS average_pizzas_per_day
FROM (
    SELECT o.order_date, SUM(od.quantity) AS daily_total
    FROM order_details as od
    JOIN orders as o ON od.order_id = o.order_id
    GROUP BY o.order_date
) AS daily_orders;

-- 10- detarmine the top 3 most ordered pizza types based on revenue.
select pizza_types.name , sum(order_details.quantity * pizzas.price) as revenue
 from pizza_types join pizzas on pizza_types.pizza_type_id  = pizzas.pizza_type_id
 join order_details on order_details.pizza_id = pizzas.pizza_id
 group by pizza_types.name order by revenue desc limit 3;
 -- second methord
 SELECT pt.name AS pizza_type, SUM(od.quantity * p.price) AS revenue
FROM order_details as od
JOIN pizzas as p ON od.pizza_id = p.pizza_id
JOIN pizza_types as pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

 -- the thai chicken pizza -43434
 -- the barbecue chicken pizza-42768
 -- the california chicken pizza 41409
 
 -- 11- calculate the percentage contribution of each pizza type to total revenue.
 select pizza_types.category , round(sum(order_details.quantity * pizzas.price) / 
 (select round(sum(order_details.quantity * pizzas.price),2) as total_sales 
 from order_details join pizzas on pizzas.pizza_id = order_details.pizza_id)*100,2) as revenue
 from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join order_details on order_details.pizza_id = pizzas.pizza_id 
 group by pizza_types.category order by revenue desc;
 -- classic-26.91
 -- supreme-25.46
 -- chicken-23.96
 -- veggie-23.68
 use pizzahut;
 
 -- 12- analyze the cumulative revenue generated over time.
 select order_date , sum(revenue) over (order by order_date)as cum_revenue from
 (select orders.order_date , sum(order_details.quantity * pizzas.price) as revenue
 from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
 join orders on orders.order_id = order_details.order_id group by orders.order_date)
 as sales;
 
 -- 13- determine the top 3 most ordered pizza types based on revenue for each pizza category.
 select name , revenue from 
 (select category , name , revenue , rank() over(partition by category order by revenue desc ) as rn
 from
 (select pizza_types.category , pizza_types.name , sum((order_details.quantity) * pizzas.price)
 as revenue from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join order_details on order_details.pizza_id = pizzas.pizza_id group by pizza_types.category , 
 pizza_types.name ) as a) as b where rn <= 3;
 -- 12rows result
 
 use pizzahut;
 select * from orders;
 select * from pizzas;
 select * from pizza_types;
 select * from order_details;
 
 
 
 


 