create table brands(
brand_id int,
brand_name varchar(20)
);

-- Table Name 'categories' 

create table categories
(
category_id int,
category_name varchar(20)
);

-- Table Name 'customers' 

create table customers
(
customer_id int,
first_name varchar(20),
last_name varchar(20),
phone varchar(30),
email varchar(50),
street varchar(50),
city varchar(50),
state varchar(10),
zip_code int
);

-- Table Name 'order_items' 

create table order_items
(
order_id int,
item_id int,
product_id int,
quantity int,
list_price float,
discount float
);

-- Table Name 'orders'


create table orders
(
order_id int,
customer_id int,
order_status int,
order_date date,
required_date date,
shipped_date date,
store_id int,
staff_id int
);

-- Table Name 'products'

create table products
(
product_id int,
product_name varchar(60),
brand_id int,
category_id int,
model_year int,
list_price float
);

-- Table Name 'staff' 

create table staff
(
staff_id int,
first_name varchar(20),
last_name varchar(30),
email varchar(50),
phone varchar(80),
active int,
store_id int,
manager_id varchar(10)
);

-- Table Name 'stocks'

create table stocks
(
store_id int,
product_id int,
quantity int
);

-- Table Name 'stores'

create table stores
(
store_id int,
store_name varchar(30),
phone varchar(50),
email varchar(40),
street varchar(50),
city varchar(40),
state varchar(10),
zip_code int
);

-- Which Bike Store is most popular for sales and numbers of staffs of the stores

select st.store_name , count(o.order_id) as count_of_sales , count( distinct s.staff_id)as Number_of_staffs
from stores st
join orders o
on o.store_id = st.store_id
join staff s
on s.staff_id =o.staff_id
group by 1
order by 2 desc

-- List Top Five customer bought most expensive Bike(dollar)

select c.first_name,c.last_name, o.order_id,oi.list_price as Price 
from customers c
join orders o 
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
group by o.order_id,c.first_name,c.last_name,Price 
order by Price desc
limit 5

-- Top 3 Brands of bike which got highest Orders

select b.brand_name, count(o.order_id) as Number_of_orders
from brands b
join products pc
on b.brand_id = p.brand_id
join order_items oi
on p.product_id = oi.product_id
join orders o
on oi.order_id = o.order_id
group by 1
order by 2 desc
limit 3

-- Count number of Bikes has not shipped for each Brands

select b.brand_name , count(o.order_id) as Number_of_items_not_shipped 
from brands b 
join products p
on p.brand_id = b.brand_id
join order_items oi
on oi.product_id = p.product_id
join orders o
on o.order_id = oi.order_id
where shipped_date is null
group by 1
order by 2 desc

-- Bike brand sales across different cities

select b.brand_name , c.city , count(o.order_id) as number_of_orders,

ROW_Number() over(partition by  b.brand_name order by count(o.order_id) desc) as rank
from brands b 
join products p
on p.brand_id = b.brand_id
join order_items oi
on oi.product_id = p.product_id
join orders o
on oi.order_id = o.order_id
join customers c
on c.customer_id = o.customer_id
group by  b.brand_name,c.city

-- Every year sales of bikes from each store


SELECT 
      s.store_name, b.brand_name ,
      TO_CHAR(o.order_date, 'YYYY') AS years, 
      ROUND(SUM(oi.list_price)) AS yearly_Sales
  from stores s
  join orders o
  on s.store_id = o.store_id
  join order_items oi
  on oi.order_id = o.order_id
  join products p
  on p.product_id = oi.product_id
  join brands b
  on b.brand_id = p.brand_id
  GROUP BY s.store_name, b.brand_name,years
  order by  s.store_name 
  
 -- Monthly sales of each bike brands and 1 year total revenue

 WITH MonthlySales AS (
    SELECT 
        b.brand_name, 
        TO_CHAR(o.order_date, 'MM') AS months, 
        ROUND(SUM(oi.list_price)) AS Monthly_Sales
    FROM brands b
    JOIN products p ON p.brand_id = b.brand_id
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    GROUP BY b.brand_name, TO_CHAR(o.order_date, 'MM')
)
SELECT 
    brand_name, 
    months, 
    Monthly_Sales,
    SUM(Monthly_Sales) OVER(
        PARTITION BY brand_name 
        ORDER BY months::INTEGER
    ) AS Cumulative_Sales 
FROM MonthlySales
ORDER BY brand_name, months::INTEGER;

