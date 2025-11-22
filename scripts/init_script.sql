use master;
go
if exists (select 1 from sys.databases where name='Datawarehouse')
  drop database datawarehouse
create database datawarehouse;
go
use datawarehouse;
go
create schema bronze;
go
create schema silver;
GO
create schema gold;