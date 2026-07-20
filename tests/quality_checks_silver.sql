/*
==========================================================================
Quality Checks
==========================================================================
Script Purpose:
  This script perfoms various quality checks for daa consistency, accuracy
  and standardization across the 'silver' schemas. It includes checks for:
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data stardardization and consistency.
  - Invalid date ranges and orders.
  - Data consistency between related fields.

Usage Note:
  - Run these checks after data loading Silver Layer
  - Investigate and resolve any discrepancies found during the checks.
==========================================================================
*/


--=================================================
-- Checking 'silver.crm_cust_info'
--=================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Results

SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


-- Check for unwanted Spaces
-- Expectation: No Results

SELECT
cst_firstname
FROM silver.crm_cust_info
where cst_firstname != trim(cst_firstname)

-- Data Standarization & Consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

--=================================================
-- Checking 'silver.crm_prd_info'
--=================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Results

SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted Spaces
-- Expectation: No Results

SELECT
prd_nm
FROM silver.crm_prd_info
where prd_nm != trim(prd_nm)

-- Check for NULLS or Negative Number
-- Expectation: No Results

SELECT
prd_cost
FROM silver.crm_prd_info
where prd_cost IS NULL OR prd_cost < 0

-- Data Standarization & Consistency

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders
SELECT
*
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--=================================================
-- Checking 'silver.crm_sales_details'
--=================================================
-- Check for Invalid Dates
SELECT
sls_order_dt
FROM silver.crm_sales_details
WHERE LEN(sls_order_dt) != 10
OR sls_ship_dt< sls_order_dt

-- Check for Invalid Dates Order
SELECT
sls_order_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt< sls_order_dt or sls_order_dt > sls_due_dt

-- Check Data consistency: Between Sales, Qualrity and Price
-->> Sales = Qualtity * Price
-->> Values must not be NULL, zero, or negaive.

SELECT
sls_sales as old_sls_sales,
sls_quantity,
sls_price as old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
	 ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <=0 
	 THEN sls_sales / NULLIF(sls_quantity,0)
	 ELSE sls_price
END AS sls_price
FROM silver.crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price)
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales,
sls_quantity,
sls_price

--=================================================
-- Checking 'silver.erp_cust_az12'
--=================================================
-- Identify Out-of-Range Date

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate<'1926-01-01' OR bdate > GETDATE()

-- Data Standardization & Consistency

SELECT
gen
FROM silver.erp_cust_az12

--=================================================
-- Checking 'silver.erp_loc_a101'
--=================================================
-- Data Normalization & Consistency
SELECT
	DISTINCT(cntr)
FROM silver.erp_loc_a101

--=================================================
-- Checking 'silver.erp_px_cat_g1v2'
--=================================================
-- Check for unwanted spaces
SELECT
	*	
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)

-- Data Standardization & Consistency
SELECT
	DISTINCT(subcat)
FROM silver.erp_px_cat_g1v2
