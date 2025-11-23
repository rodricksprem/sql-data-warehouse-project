use datawarehouse;


 
select 
case when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
else cid 
end as cid,
bdate,
gen
 from bronze.erp_cust_az12 where cid not in (select cst_key from silver.crm_cust_info)

 insert into silver.erp_cust_az12
(cid,
BDATE,
GEN)
select 
case when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
else cid 
end as cid,
case when bdate <'1924-01-01' or bdate > getdate() then NULL
else BDATE
end as bdate,
case when upper(trim(gen)) in ('M','MALE')  then 'Male'
     when upper(trim(gen)) in ('F','FEMALE') then 'Female'
     else 'n/a'
end as gen
 from bronze.erp_cust_az12;



select 
replace(cid,'-','') as cid,
CNTRY from
bronze.erp_loc_a101

select distinct(cntry) from bronze.erp_loc_a101

insert into silver.erp_loc_a101 (cid,cntry)
select 
replace(cid,'-','') as cid,
case 
    when Trim(CNTRY)='DE' then 'Germany'
    when Trim(CNTRY) in ('US','United States') then 'United States'
    when trim(CNTRY)='' or CNTRY is null then 'n/a'
    else trim(cntry)
end as cntry
from 
bronze.erp_loc_a101

select 
id,
cat,
SUBCAT,
MAINTENANCE
 FROM
bronze.erp_px_cat_g1v2

select id from bronze.erp_px_cat_g1v2 where trim(id) not in (select cat_id from silver.crm_prd_info) -- co_pd

select cat from bronze.erp_px_cat_g1v2 where trim(cat)!=cat or cat is null -- check null or spaces

select SUBCAT from bronze.erp_px_cat_g1v2 where trim(SUBCAT)!=SUBCAT or SUBCAT is null -- check null or spaces

select MAINTENANCE from bronze.erp_px_cat_g1v2 where trim(MAINTENANCE)!=MAINTENANCE or MAINTENANCE is null -- check null or spaces

select distinct(cat) from bronze.erp_px_cat_g1v2

select distinct(SUBCAT) from bronze.erp_px_cat_g1v2


insert into silver.erp_px_cat_g1v2
(id,
cat,
SUBCAT,
MAINTENANCE)
select 
id,
cat,
SUBCAT,
MAINTENANCE
 FROM
bronze.erp_px_cat_g1v2

