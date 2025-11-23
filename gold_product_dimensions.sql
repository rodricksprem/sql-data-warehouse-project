
select prd_key, count(*) from 
(
select 
 pi.prd_id ,
    pi.prd_key ,
    pi.prd_nm ,
    pi.cat_id,
    pc.cat,
    pc.SUBCAT,

    pi.prd_cost ,
    pi.prd_line ,
    pi.prd_start_dt ,
    pc.MAINTENANCE

from silver.crm_prd_info  pi
left join silver.erp_px_cat_g1v2 pc 
on pi.cat_id = pc.id 
where pi.prd_end_dt is NULL -- to select only current products and ignore the hisorical data
)t group by prd_key 
having count(*) > 1 -- check for duplicates


create view gold.dim_products as 
select 
ROW_NUMBER() over (order by pi.prd_start_dt,pi.prd_key) as product_key,
 pi.prd_id as product_id,
    pi.prd_key as product_number,
    pi.prd_nm as product_name,
    pi.cat_id as category_id,
    pc.cat as category,
    pc.SUBCAT as subcategory,

    pc.MAINTENANCE as maintenance,
    pi.prd_cost as cost,
    pi.prd_line as product_line,
    pi.prd_start_dt as start_date

from silver.crm_prd_info  pi
left join silver.erp_px_cat_g1v2 pc 
on pi.cat_id = pc.id 
where pi.prd_end_dt is NULL 




