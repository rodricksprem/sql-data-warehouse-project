
create view gold.fact_sales AS 
 select 
sd.sls_ord_num as order_number  ,
dp.product_key , -- surrogate key
dc.customer_key , -- surrogate key
sls_order_dt as order_date,
sls_due_dt as due_date,
sls_ship_dt as shipping_date,
sls_sales as sales_amount,
sls_quantity as quantity,
sls_price as price
 from silver.crm_sales_details sd 
 left join gold.dim_products dp  -- to build fact table
 on sd.sls_prd_key=dp.product_number 
 left join gold.dim_customers dc -- to build fact table
 on sd.sls_cust_id=dc.customer_id  

-- check if dimension are succefully joined with facts
 select * from gold.fact_sales s
 left join gold.dim_customers c 
 on s.customer_key=c.customer_key
 left join gold.dim_products p 
 on s.product_key=p.product_key