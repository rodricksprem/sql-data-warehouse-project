use datawarehouse;
go
-- check for nulls and duplicates in primary key

select cst_id,count(*) from bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null;

-- remove duplicates
select 
    cst_id,
    cst_key ,
    cst_first_name,
    cst_last_name ,
    cst_marital_status ,
    cst_gndr,
    cst_create_date
from(
select *,
row_number() over (partition by cst_id order by cst_create_date desc) as rank_customer
from bronze.crm_cust_info where cst_id is not null
)t where t.rank_customer=1

--check for unwanted spaces

select cst_first_name
from bronze.crm_cust_info where cst_first_name != trim(cst_first_name);

select cst_last_name
from bronze.crm_cust_info where cst_last_name != trim(cst_last_name);


select cst_gndr
from bronze.crm_cust_info where cst_gndr != trim(cst_gndr);

-- remove unwanted spaces
select 
    cst_id,
    cst_key ,
    trim(cst_first_name),
    trim(cst_last_name),
    cst_material_status ,
    cst_gndr,
    cst_create_date
from(
select *,
row_number() over (partition by cst_id order by cst_create_date desc) as rank_customer
from bronze.crm_cust_info where cst_id is not null
)t where t.rank_customer=1

-- data standardization & normalization (low cardinality)
select distinct(cst_gndr) from bronze.crm_cust_info;

-- replace M and F for gender with full word, remove duplicates from cst_id, remove black spaces from names
if object_id('silver.crm_cust_info','U') is not NULL   

    truncate table silver.crm_cust_info
go 
insert into silver.crm_cust_info (
     cst_id,
    cst_key ,
    cst_first_name,
    cst_last_name,
    cst_marital_status ,
    cst_gndr,
    cst_create_date) 
select 
    cst_id,
    cst_key ,
    trim(cst_first_name) as cst_first_name,
    trim(cst_last_name) as cst_last_name ,
    case 
        when upper(Trim(cst_marital_status))='M' then 'Married'
        when upper(Trim(cst_marital_status))='S' then 'Single'
        else 'n/a'
    end  cst_marital_status,
    case 
        when upper(Trim(cst_gndr))='M' then 'Male'
        when upper(Trim(cst_gndr))='F' then 'Female'
        else 'n/a'
    end cst_gndr,
    cst_create_date
from(
select *,
row_number() over (partition by cst_id order by cst_create_date desc) as rank_customer
from bronze.crm_cust_info where cst_id is not null
)t where t.rank_customer=1
    

select * from silver.crm_cust_info;
