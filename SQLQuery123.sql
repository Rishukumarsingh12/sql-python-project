
--SELECT * FROM sqlpython_db.dbo.data;



-- Find top 10 highest generating revenue products
SELECT top 10 product_id,SUM(sale_price) as 'total_sales'
FROM sqlpython_db.dbo.data
group by product_id
order by total_sales desc;



--select top 5 highest selling products in each region
with cte as(
SELECT  product_id,region,SUM(sale_price) as 'total_sales'
FROM sqlpython_db.dbo.data 
group by region , product_id
)
select * from 
(
select *
, ROW_NUMBER() over(partition by region order by total_sales desc) as row_num
from cte
) A
where row_num<=5;





--Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as (
select distinct YEAR(order_date) as order_year, MONTH(order_date) as order_month, SUM(sale_price) as total_sales
from sqlpython_db.dbo.data
group by YEAR(order_date),MONTH(order_date)
--order by YEAR(order_date),MONTH(order_date);
)
select order_month
, sum(case when order_year = 2022 then total_sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then total_sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;




--For each category which month had highest category
with cte as (
select category,FORMAT(order_date,'yyyy-MM') as order_year_month,SUM(sale_price) as total_sales
from sqlpython_db.dbo.data
group by category, FORMAT(order_date,'yyyy-MM')
--order by category, FORMAT(order_date,'yyyy-MM')
)
select * from (
select *,
ROW_NUMBER() over(partition by category order by total_sales desc) as row_num
from cte) A
where row_num<=1;




--which sub-category has the highest growth by profit from year 2022 to 2023
with cte as (
select sub_category, YEAR(order_date) as order_year, SUM(sale_price) as total_sales
from sqlpython_db.dbo.data
group by sub_category,YEAR(order_date)
--order by YEAR(order_date),MONTH(order_date);
)
, cte2 as (
select sub_category
, sum(case when order_year = 2022 then total_sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then total_sales else 0 end) as sales_2023
from cte
group by sub_category
--order by sub_category;
)
select top 1 * ,
100*(sales_2023-sales_2022)/sales_2022 as profit_growth
from cte2
order by profit_growth desc;

