/*
=====================================================================
Create Database and Schemas
=====================================================================
Scripts Purpose
	This script creates a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped and recreated. Aditionally, the script sets up three schemas
	withing the dabase: 'bronze', 'silver', and 'gold'.

WARNING:
	Runing this script will drop the entire 'DatsWarehouse' datagase if it exists.
	All data in the database will be permanently deleted. Proceed with cautio
	and ensure you have proper backups before runing this script.
*/

USE master;
GO

-- Drop and recreeate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- Create Database 'DataWarehouse'

USE master;

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
