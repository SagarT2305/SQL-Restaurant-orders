
--  select * from order_details;
--  select * from menu_items;

-- View the menu_items table and write a query to find the number of items on the menu?
	select distinct count(*) as cnt_of_menu_items
	from menu_items;


--What are the least and most expensive items on the menu?
	
	select 'most_exp' as type, item_name
	from menu_items
	where price=(select max(price) from menu_items)
	union
	select 'least_exp' as type, item_name
	from menu_items
	where price=(select min(price) from menu_items)


--How many Italian dishes are on the menu? 
	select *--count(*) as cnt 
	from menu_items
	where category='Italian' order by price

--What are the least and most expensive Italian dishes on the menu?
	
	select 'most_exp' as type, item_name
	from menu_items
	where category='Italian' and price=(select max(price) from menu_items where category='Italian')
	union
	select 'least_exp' as type, item_name
	from menu_items
	where category='Italian' and price=(select min(price) from menu_items where category='Italian')
	

--How many dishes are in each category? What is the average dish price within each category?
	
	select category, count(*) as dish_cnt, round(avg(price),2) as avg_price
	from menu_items
	group by category


--View the order_details table. What is the date range of the table?
	
	select min(order_date) as min_date, max(order_date) as max_date,
	datediff(day,min(order_date) , max(order_date)) as diff
	from order_details

-- How many orders were made within this date range? How many items were ordered within this date range?
	select count(distinct order_id) as cnt_of_orders, 
		   count( item_id) as cnt_of_items,
		   count(distinct item_id) as cnt_of_distinct_items
	from order_details 
	

--Which orders had the most number of items?

	with cte as (
	select order_id, count(item_id) as cnt, 
	dense_Rank() over (order by count(item_id) desc) as rnk
	from order_details  
	group by order_id 
	)

	select order_id from cte where rnk=1


--How many orders had more than 12 items?
	select count(order_id) cnt from (
	select order_id, count(item_id) as cnt
	from order_details  
	group by order_id ) a
	where cnt>12


--Combine the menu_items and order_details tables into a single table.
	 select o.*,m.item_name, m.category, m.price 
	 from menu_items m
	 left join order_details o on m.menu_item_id = o.item_id


--What were the least and most ordered items? What categories were they in?
	
	with cte as( 
	select m.item_name, count(*) cnt, m.category ,
	dense_rank() over(order by count(*) ) rn1asc,
	dense_rank() over(order by count(*) desc ) rn1desc
	 from menu_items m
	 left join order_details o on m.menu_item_id = o.item_id
	 group by m.item_name,m.category 
	)
	select category, item_name, 'least_ordered_item' as type
	from cte where rn1asc=1
	union
	select category, item_name, 'most_ordered_item' as type
	from cte where rn1desc=1


--What were the top 5 orders that spent the most money?
	select order_id , amount from 
	(select o.order_id, sum(m.price) as amount,
	dense_rank() over(order by sum(m.price) desc ) rn
	 from menu_items m
	 left join order_details o on m.menu_item_id = o.item_id
	 group by o.order_id) a
	 where rn<=5



--View the details of the highest spend order. Which specific items were purchased?
	with cte as (
	select order_id , amount from 
	(select o.order_id,	sum(m.price) as amount,
	dense_rank() over(order by sum(m.price) desc ) rn
	 from menu_items m
	 left join order_details o on m.menu_item_id = o.item_id
	 group by o.order_id) a
	 where rn=1)

	 select o.*,m.item_name, m.category, m.price 
	 from menu_items m
	 left join order_details o on m.menu_item_id = o.item_id
	 where o.order_id = (select order_id from cte)
	
