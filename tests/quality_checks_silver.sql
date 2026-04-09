/* 
=======================================================================================
Quality Checks
=======================================================================================
Script Purpose: 
	This script performs various quality checks for data consistency, accuracy, and
	standardization across the 'silver' schemas. It includes checks for: 
		- Null or Duplicate primary keys.
		- Unwanted spaces in string files.
		- Data standardization and consistency.
		- Invalid date ranges and orders.
		- Data consistency between related fields.
Usage Notes:
	- Run these checks after loading Silver Layer.
	- Investigate and resolve any discrepancies found during the checks
=======================================================================================
*/

-- =============================================
-- Checking 'silver.crm_cust_info'
-- =============================================
----- Check for NULLS or Duplicate in Primary Key 
----- Expectation: No Resutls
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 or cst_id IS NULL

----- Check for unwanted Spaces
----- Expectation: No Results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

----- Data Standardization & Consistency 
SELECT DISTINCT cst_material_status
FROM silver.crm_cust_info


-- =============================================
-- Checking 'silver.crm_prd_info'
-- =============================================
----- Check for NULLs or Negative number
----- Expectation: No Results
SELECT prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

----- Check for Invalid Date Orders
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


-- =============================================
-- Checking 'silver.crm_sales_details'
-- =============================================
---- Check for Invalid Dates 
SELECT 
NULLIF(sls_due_dt, 0) AS ls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8


---- Check for Invalid Dates Orders
SELECT 
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

---- Check Data Consistency: Between Sales, Quantity, Price
-- >> Sales = Quantity * Price
-- >> Values must be not NULL, zero, or negative
SELECT DISTINCT 
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL or sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0

-- =============================================
-- Checking 'silver.erp_cust_az12'
-- =============================================
---- Identify Out-Of-Range Dates 
SELECT DISTINCT 
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

---- Data Standarlization & Consistency 
SELECT DISTINCT gen 
FROM bronze.erp_cust_az12 

-- =============================================
-- Checking 'silver.erp_loc_a101'
-- =============================================
-- Data Standardization & Consistency 
SELECT DISTINCT cntry 
FROM silver.erp_loc_a101
ORDER BY cntry

-- =============================================
-- Checking 'silver.erp_px_cat_g1v2'
-- =============================================
-- Check for Unwanted Spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance)

--Data Standardization & Consistency 
SELECT DISTINCT maintenance 
FROM silver.erp_px_cat_g1v2 
