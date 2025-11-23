--change over time analysis ( measure / date dimension)
select month(order_date) ,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
group by month(order_date)
order by month(order_date)

select year(order_date),
month(order_date) ,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by year(order_date),month(order_date)
order by  year(order_date),month(order_date)


select format(order_date,'yyyy-MMM'),
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by format(order_date,'yyyy-MMM')
order by  format(order_date,'yyyy-MMM')

-- cumulative anlysis (cumulative measure /  date dimension) 

--calculate the total sales per month and running total of sales over time

select 
order_date,
t.total_sales ,
sum(t.total_sales) over (order by order_date) as running_total_sals
from(


select DATEADD(month, DATEDIFF(month, 0, order_date), 0) as order_date,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by DATEADD(month, DATEDIFF(month, 0, order_date), 0)
)t


select 
order_date,
t.total_sales ,
sum(t.total_sales) over (partition by order_date order by order_date ) as running_total_sales
from(

select 
order_date,
DATEDIFF(month, 0, order_date) ,
DATEADD(month, DATEDIFF(month, 0, order_date), 0)
from gold.fact_sales;

select DATEADD(month, DATEDIFF(month, 0, order_date), 0) as order_date,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by DATEADD(month, DATEDIFF(month, 0, order_date), 0)
)t



-- performance analysiss
 -- compare current measure with target measure
with yearly_product_sales as 
(
select 

year(fs.order_date) as order_date,
dp.product_name as product_name,
sum(fs.sales_amount) as current_sales
from gold.fact_sales fs
left join gold.dim_products dp
on dp.product_key = fs.product_key
group by year(fs.order_date),
dp.product_name
)

select order_date,product_name,current_sales ,
avg(current_sales) over (partition by product_name) as average_sales_per_product,
current_sales - avg(current_sales) over (partition by product_name) as diff_avg,
case when current_sales < avg(current_sales) over (partition by product_name) then 'Below Average'
     when current_sales > avg(current_sales) over (partition by product_name) then 'Above Average'
    else 'Average'
end as avg_comparaision_result,
lag(current_sales) over(partition by product_name order by order_date) as previousyearsaleamount,
current_sales - lag(current_sales) over(partition by product_name order by order_date) as diff_between_years,
case when current_sales < lag(current_sales) over(partition by product_name order by order_date) then 'Descreasing'
     when current_sales > lag(current_sales) over(partition by product_name order by order_date) then 'Increasing'
    else 'Normal'
end as year_over_result
from yearly_product_sales order by order_date,product_name



--part-to-whole proportinal anlysis

--which categories contribute to overall sales
with total_sales_per_category as 
(
select 

dp.category as category,
sum(fs.sales_amount) as total_sales
from gold.fact_sales fs
left join gold.dim_products dp
on dp.product_key = fs.product_key 
group by dp.category
) 
select
category,
total_sales,

sum(total_sales) over () total_sals_of_all_categories,
round((cast (total_sales as float)/sum(total_sales) over () )*100,2) as percentage_of_contribution

from total_sales_per_category order by total_sales

--Data segmentation
-- measure by measure (total products by sales range , total customers by age) . build new category based on segements

with cost_range_segregation as
(
select 
product_key,
product_name,
cost,
case when cost<100 then 'below 100'
     when cost between 100 and 500 then '100-500'
     when cost between 500 and 1000 then '500-1000'
     else 'Ábove 1000'
end cost_range
from gold.dim_products
)
select 
product_key,
product_name,
count(product_name) as total_products
from cost_range_segregation
group by cost_range
order by total_products DESC


with 
customer_spening_record as(
select 
dc.customer_key,
dc.first_name,
sum(fs.sales_amount) as customer_spend_amount,
min(fs.order_date) as first_order,
max(fs.order_date) as last_order,
DATEDIFF(year,min(fs.order_date),max(fs.order_date)) as customertenure
from gold.dim_customers dc 
left join gold.fact_sales fs
on fs.customer_key=dc.customer_key
group by 

dc.customer_key,
dc.first_name
),
 generate_customer_segment as 
 (select 
customer_key,
first_name,
case when customertenure>=12 and customer_spend_amount>5000 then 'VIP'
     when customertenure>=12 and customer_spend_amount<=5000 then 'Regular'
    else 'new'
end as customer_segement
from customer_spening_record
 )
 select
  customer_segement , 
  count(customer_key) 
  from generate_customer_segment 
  group by customer_segement

