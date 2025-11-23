
use datawarehouse;
go

create view gold.dim_customers AS 

select 
ROW_NUMBER() over (order by ci.cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_first_name as first_name,
ci.cst_last_name as last_name,
ci.cst_marital_status as marital_status,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr  -- data integration as both gender related columns  from two tables contain different value 
     else COALESCE(ca.gen,'n/a')
end as gender,

la.cntry as country,
ca.bdate as birth_date,
ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca 
on ci.cst_key=ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key=la.cid


-- check if duplicate record created after the joins

select cst_id,count(*) FROM
(
    select ci.cst_id,
ci.cst_key,
ci.cst_first_name,
ci.cst_last_name,
ci.cst_marital_status,
ci.cst_gndr,
ci.cst_create_date,
ca.bdate,
ca.gen,
la.cntry
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca 
on ci.cst_key=ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key=la.cid

)t group by cst_id having count(*) > 1 

-- check for mismatch to do data integration between genders columns from two different tables
select ci.cst_gndr,
ca.gen 
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca 
on ci.cst_key=ca.cid
where ci.cst_gndr != ca.gen
order by ci.cst_gndr,ca.gen




select * from gold.dim_customers


