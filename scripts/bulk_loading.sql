use datawarehouse;
go
--https://medium.com/coach-neelon/bulk-insert-with-sql-server-on-amazon-rds-7b813a909b9f
-- refer the above docuemnt to load the filr to RDS sql server
exec msdb.dbo.rds_download_from_s3
 @s3_arn_of_file='arn:aws:s3:::sqlserverdwdemobucket/cust_info.csv',
 @rds_file_path='D:\S3\bucket-name\cust_info.csv',
 @overwrite_file=1;


 exec msdb.dbo.rds_download_from_s3
 @s3_arn_of_file='arn:aws:s3:::sqlserverdwdemobucket/prd_info.csv',
 @rds_file_path='D:\S3\bucket-name\prd_info.csv',
 @overwrite_file=1;


 exec msdb.dbo.rds_download_from_s3
 @s3_arn_of_file='arn:aws:s3:::sqlserverdwdemobucket/sales_details.csv',
 @rds_file_path='D:\S3\bucket-name\sales_details.csv',
 @overwrite_file=1;



 exec msdb.dbo.rds_download_from_s3
 @s3_arn_of_file='arn:aws:s3:::sqlserverdwdemobucket/CUST_AZ12.csv',
 @rds_file_path='D:\S3\bucket-name\CUST_AZ12.csv',
 @overwrite_file=1;


 exec msdb.dbo.rds_download_from_s3
 @s3_arn_of_file='arn:aws:s3:::sqlserverdwdemobucket/LOC_A101.csv',
 @rds_file_path='D:\S3\bucket-name\LOC_A101.csv',
 @overwrite_file=1;


 exec msdb.dbo.rds_download_from_s3
 @s3_arn_of_file='arn:aws:s3:::sqlserverdwdemobucket/PX_CAT_G1V2.csv',
 @rds_file_path='D:\S3\bucket-name\PX_CAT_G1V2.csv',
 @overwrite_file=1;
 




truncate table bronze.crm_cust_info;
go
bulk insert bronze.crm_cust_info
from 'D:\S3\bucket-name\cust_info.csv'
with (
    firstrow = 2,
    fieldterminator=',',
    tablock
);
go 
select count(*) from bronze.crm_cust_info;
go
truncate table bronze.crm_prd_info;
go
bulk insert bronze.crm_prd_info
from 'D:\S3\bucket-name\prd_info.csv'
with (
    firstrow = 2,
    fieldterminator=',',
    tablock
)
select count(*) from bronze.crm_prd_info;
go
truncate table bronze.crm_sales_details;
go

bulk insert bronze.crm_sales_details
from 'D:\S3\bucket-name\sales_details.csv'
with (
    firstrow = 2,
    fieldterminator=',',
    tablock
);
go
select count(*) from bronze.crm_sales_details;
go
truncate table bronze.erp_loc_a101;
go
bulk insert bronze.erp_loc_a101
from 'D:\S3\bucket-name\LOC_A101.csv'
with (
    firstrow = 2,
    fieldterminator=',',
    tablock
);
go
select count(*) from bronze.erp_loc_a101;
go
truncate table bronze.erp_cust_az12;
go
bulk insert bronze.erp_cust_az12
from 'D:\S3\bucket-name\CUST_AZ12.csv'
with (
    firstrow = 2,
    fieldterminator=',',
    tablock
);
go
select count(*) from bronze.erp_cust_az12;

go
truncate table bronze.px_cat_g1v2;
go
bulk insert bronze.erp_px_cat_g1v2
from 'D:\S3\bucket-name\PX_CAT_G1V2.csv'
with (
    firstrow = 2,
    fieldterminator=',',
    tablock
);
go
select count(*) from bronze.erp_px_cat_g1v2;
