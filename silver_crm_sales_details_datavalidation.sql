use datawarehouse;

select 
sls_ord_num,
sls_prd_key,
sls_cust_id ,
sls_order_dt ,
sls_ship_dt ,
sls_due_dt ,
sls_sales ,
sls_quantity,
sls_price from bronze.crm_sales_details 
where sls_ord_num is null or  len(sls_ord_num) =0

select 
sls_ord_num,
sls_prd_key,
sls_cust_id ,
sls_order_dt ,
sls_ship_dt ,
sls_due_dt ,
sls_sales ,
sls_quantity,
sls_price from bronze.crm_sales_details 
where sls_ord_num != Trim(sls_ord_num) -- check space


select 
sls_ord_num,
sls_prd_key,
sls_cust_id ,
sls_order_dt ,
sls_ship_dt ,
sls_due_dt ,
sls_sales ,
sls_quantity,
sls_price from bronze.crm_sales_details 
where sls_prd_key not in  (select prd_key from silver.crm_prd_info) -- check integrity

select 
sls_ord_num,
sls_prd_key,
sls_cust_id ,
sls_order_dt ,
sls_ship_dt ,
sls_due_dt ,
sls_sales ,
sls_quantity,
sls_price from bronze.crm_sales_details 
where sls_cust_id not in  (select cst_id from silver.crm_cust_info)-- check integrity


select 
sls_ord_num,
sls_prd_key,
sls_cust_id ,
case when sls_order_dt <=0 or len(sls_order_dt)!=8 then  NULL
else cast(cast(sls_order_dt as varchar) as date)
end as sls_order_dt,
case when sls_ship_dt <=0 or len(sls_ship_dt)!=8 then  NULL
else cast(cast(sls_ship_dt as varchar) as date)
end as sls_ship_dt,
sls_due_dt ,
sls_sales ,
sls_quantity,
sls_price from bronze.crm_sales_details 
where sls_order_dt<=0 or sls_order_dt is null or len(sls_order_dt) < 8

select 
sls_ord_num,
sls_prd_key,
sls_cust_id ,
case when sls_order_dt <=0 or len(sls_order_dt)!=8 then  NULL
else cast(cast(sls_order_dt as varchar) as date)
end as sls_order_dt,
case when sls_ship_dt <=0 or len(sls_ship_dt)!=8 then  NULL
else cast(cast(sls_ship_dt as varchar) as date)
end as sls_ship_dt,
sls_due_dt ,
case when sls_sales is null or sls_sales<0 then sls_price*sls_quantity
    else sls_sales
end as sls_sales,

sls_quantity,
case when sls_price <0 then abs(sls_price)
    when sls_price is null or sls_price =0 then sls_sales/sls_quantiry
    else sls_price
end as sls_price
from bronze.crm_sales_details 
where sls_due_dt<=0 or sls_due_dt is null or len(sls_due_dt) < 8

-- check ship date is 
select 
sls_ord_num,
sls_prd_key,
sls_cust_id ,
case when sls_order_dt <=0 or len(sls_order_dt)!=8 then  NULL
else cast(cast(sls_order_dt as varchar) as date)
end as sls_order_dt,
case when sls_ship_dt <=0 or len(sls_ship_dt)!=8 then  NULL
else cast(cast(sls_ship_dt as varchar) as date)
end as sls_ship_dt
from bronze.crm_sales_details
where sls_ship_dt<sls_order_dt or sls_due_dt<sls_order_dt


insert into silver.crm_sales_details 
(

sls_ord_num,
sls_prd_key,
sls_cust_id ,
sls_order_dt,
sls_ship_dt,
sls_due_dt ,
sls_sales,
sls_quantity,
sls_price

)
select 
sls_ord_num,
sls_prd_key,
sls_cust_id ,
case when sls_order_dt <=0 or len(sls_order_dt)!=8 then  NULL
else cast(cast(sls_order_dt as varchar) as date)
end as sls_order_dt,
case when sls_ship_dt <=0 or len(sls_ship_dt)!=8 then  NULL
else cast(cast(sls_ship_dt as varchar) as date)
end as sls_ship_dt,
case when sls_due_dt <=0 or len(sls_due_dt)!=8 then  NULL
else cast(cast(sls_due_dt as varchar) as date)
end as sls_due_dt ,
case when sls_sales is null or sls_sales<0  or sls_sales != abs(sls_price)*sls_quantity then abs(sls_price)*sls_quantity
    else sls_sales
end as sls_sales,
sls_quantity,
case when sls_price <0 then abs(sls_price)
    when sls_price is null or sls_price =0 then sls_sales/nullif(sls_quantity,0)
    else sls_price
end as sls_price
from bronze.crm_sales_details 