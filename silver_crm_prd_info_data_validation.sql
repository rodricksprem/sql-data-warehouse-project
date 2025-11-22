use datawarehouse;

select prd_id, count(*)
from bronze.crm_prd_info
GROUP by prd_id
having count(*)>1 or prd_id is null

select prd_id, prd_key, replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id
from bronze.crm_prd_info
where replace(SUBSTRING(prd_key,1,5),'-','_') not in (select distinct(id) from bronze.erp_px_cat_g1v2)

select prd_id, prd_key, replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
SUBSTRING(prd_key,7,len(prd_key)) as prd_key
from bronze.crm_prd_info
where SUBSTRING(prd_key,7,len(prd_key))  in (select distinct(sls_prd_key) from bronze.crm_sales_details)

select prd_nm
from bronze.crm_prd_info
where prd_nm!=Trim(prd_nm); -- no blankspaces


select prd_cost
from bronze.crm_prd_info
where prd_cost is null or prd_cost < 0

insert into silver.crm_prd_info (prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
select 
prd_id,  
replace(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
SUBSTRING(prd_key,7,len(prd_key)) as prd_key,
prd_nm,
ISNULL(prd_cost,0) as prd_cost,
case upper(trim(prd_line))
    when 'M' then 'Mountain' 
    when 'R' then 'Road'
    when 'S' then 'Other Sales'
    when 'T' then 'Touring'
    else 'n/a'
end as prd_line,
cast(prd_start_dt as date) prd_start_dt, 
cast(LEAD(prd_start_dt) over ( partition by prd_key order BY prd_start_dt) -1 as date) as prd_end_dt
from bronze.crm_prd_info


select prd_id,
prd_key, 
cast(prd_start_dt as date) prd_start_dt, 
cast(LEAD(prd_start_dt) over ( partition by prd_key order BY prd_start_dt) -1 as date) as prd_end_dt
from bronze.crm_prd_info where prd_end_dt < prd_start_dt 


