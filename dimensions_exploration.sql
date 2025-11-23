--Dimensions expolaration

select distinct country from gold.dim_customers; -- explore countries
select distinct category, subcategory , product_name from gold.dim_products order by 1,2,3

--Date exploration 

select min(order_date) as first_order_date from gold.dim_products;


select max(order_date) as last_order_date from gold.dim_products

select datediff(year,min(order_date), max(order_date)) as order_range_in_years from gold.dim_products

select datediff(month,min(order_date), max(order_date)) as order_range_in_months from gold.dim_products


select max(birth_date) as youngest_birthdate,datediff(year,max(birth_date),getdate()) as age_of_youngestcustomer, 
min(birth_date) as oldest_birthdate ,datediff(year,min(birth_date),getdate()) as age_of_oldestcustomer from gold.dim_customers


-- measures exploration - find the key metrics (using aggregations)

--find the total sales
select sum(sales_amount) as totalsales from  gold.fact_sales;

-- how many items are sold
select sum(quantity) as totalitmssold from gold.fact_sales

--finf the average selling price
select AVG(price) as averagesellingprice from gold.fact_sales;
--find total number of orders
select count(order_number) from gold.fact_sales;

select count(distinct order_number) from gold.fact_sales;

--find total number of products

select count(product_key) from gold.dim_products;
select count(distinct product_key) from gold.dim_products

--find total number of customers

select count(customer_key) from gold.dim_customers


--find total number of customers placed orders

select count(distinct customer_key) from gold.fact_sales



--find the total sales
select 'Total Sales ' as measure_name, sum(sales_amount) as measure_value from  gold.fact_sales
union ALL

select 'Total Items sold ' , sum(quantity) as measure_value from  gold.fact_sales

union all
--finf the average selling price
select 'Average selling price ', AVG(price) from gold.fact_sales

union all
--find total number of orders
select 'Total number of orders ', count(distinct order_number)  from gold.fact_sales
union ALL


--find total number of products
select 'Total number of Products ', count(distinct product_key)  from gold.dim_products
union ALL

--find total number of customers
select 'Total number of Customer ', count(customer_key)  from gold.fact_sales
union ALL


--find total number of customers placed orders

select 'Total number of Customer placed orders', count(distinct customer_key) from gold.fact_sales

--magnitude exploaration

--Find total customers by countries

select country, count(customer_key) as total_customers from gold.dim_customers group by country order by total_customers desc
--find total customer by gender
select gender, count(customer_key) as total_customers from gold.dim_customers group by gender order by total_customers desc
--find the total products by category
select category, count(product_key) as total_products  from gold.dim_products group by category order by total_products desc
--what is the average cost in each category
select category, avg(cost) as average_cost from gold.dim_products group by category order by average_cost desc

-- what is the total reverue generated for each category
select 
 dp.category , sum(fs.sales_amount) as total_revenue
from gold.dim_products dp 
left join gold.fact_sales fs
on dp.product_key=fs.product_key
group by dp.category 
order by total_revenue DESC

-- what is the total reverue generated for each customer ( high cardinality dimension with high number of unique values ex:customer , product , address)
select 
dc.customer_key,
dc.first_name,
 dc.last_name , sum(fs.sales_amount) as total_revenue
from gold.dim_customers dc 
left join gold.fact_sales fs
on dc.customer_key=fs.customer_key
group by dc.customer_key, dc.first_name,dc.last_name
order by total_revenue DESC

-- what is the distibution of sold items actos country -- low cardinality dimension with low number of unique values (ex:country,category, gender)
select 
dc.country, sum(fs.sales_amount) as total_revenue
from gold.dim_customers dc 
left join gold.fact_sales fs
on dc.customer_key=fs.customer_key
group by dc.country
order by total_revenue DESC




--ranking (rank dimension by measure)

-- which 5 products generate highest revenue
select top 5
 dp.product_key,dp.product_name , sum(fs.sales_amount) as total_revenue
from gold.dim_products dp 
left join gold.fact_sales fs
on dp.product_key=fs.product_key
group by dp.product_key,dp.product_name 
order by total_revenue DESC

-- which 5 products generate worst perforing product in terms of sales
select top 5
 dp.product_key,dp.product_name , sum(fs.sales_amount) as total_revenue
from gold.dim_products dp 
left join gold.fact_sales fs
on dp.product_key=fs.product_key
group by dp.product_key,dp.product_name 
order by total_revenue asc

select 
* 
from 
(
select 
 dp.product_key,
 dp.product_name , 
sum(fs.sales_amount) as total_revenue,
row_number() over( order by sum(fs.sales_amount) desc ) as rank_products
from gold.dim_products dp 
left join gold.fact_sales fs
on dp.product_key=fs.product_key
group by dp.product_key,dp.product_name 
)t where t.rank_products <=5


select 
* 
from 
(
select 
 dc.customer_key
 dc.first_name ,
 dc.last_name, 
sum(fs.sales_amount) as total_revenue,
row_number() over( order by sum(fs.sales_amount) desc ) as rank_products,
row_number() over( order by count(distinct(fs.order_number) asc ) as rank_customer
from gold.dim_customers dc 
left join gold.fact_sales fs
on dc.customer_key=fs.customer_key
group by dc.customer_key,
 dc.first_name ,
 dc.last_name,
)t where t.rank_products <=10 or t.rank_customer <=3