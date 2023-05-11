ALTER TABLE nashville_housing 
RENAME COLUMN "UniqueID " to "UniqueID";

-- standardize date format
SELECT "SaleDate"
FROM nashville_housing;

ALTER TABLE nashville_housing
ALTER COLUMN "SaleDate" TYPE date 
USING "SaleDate"::date;

-- populate property address data
-- looking at null values 
SELECT *
FROM nashville_housing 
WHERE "PropertyAddress" IS NULL;
-- why ProperttyAddress is null?
-- Examine ParcelID and PropertyAddress columns to identify pattern of missing values 
SELECT * 
FROM nashville_housing
ORDER BY "ParcelID";

WITH concat AS(
	SELECT "ParcelID" || ' - ' || COALESCE("PropertyAddress", '') AS concat 
	FROM nashville_housing
	WHERE "ParcelID" IN(
		SELECT DISTINCT "ParcelID" AS unique_parcel
		FROM nashville_housing
		WHERE "PropertyAddress" IS NULL)
	ORDER BY "ParcelID")
SELECT DISTINCT concat 
FROM concat
ORDER BY concat;

-- Using self join 
SELECT n1."ParcelID", n1."PropertyAddress", n2."ParcelID", n2."PropertyAddress", COALESCE(n1."PropertyAddress", n2."PropertyAddress")
FROM nashville_housing AS n1 
JOIN nashville_housing AS n2
	ON n1."ParcelID" = n2."ParcelID"
	AND n1."UniqueID" <> n2."UniqueID"
WHERE n1."PropertyAddress" IS NULL;

-- replace missing values in original dataset 
UPDATE nashville_housing AS n1
SET "PropertyAddress" = COALESCE(n1."PropertyAddress", n2."PropertyAddress")
FROM nashville_housing AS n2 
WHERE (n1."ParcelID" = n2."ParcelID") AND (n1."UniqueID" <> n2."UniqueID")
	AND n1."PropertyAddress" IS NULL;

-- alternative: using subquery
UPDATE nashville_housing AS n1
SET "PropertyAddress" = COALESCE(n1."PropertyAddress", (
	SELECT n2."PropertyAddress" 
	FROM nashville_housing AS n2
	WHERE n2."ParcelID" = n1."ParcelID" 
		AND n2."UniqueID" <> n1."UniqueID" 
		AND n2."PropertyAddress" IS NOT NULL 
	LIMIT 1
))
WHERE "PropertyAddress" IS NULL;

-- split the address into 2 columns: Address and City 
SELECT SPLIT_PART("PropertyAddress", ', ', 1) as property_split_address, SPLIT_PART("PropertyAddress", ',', 2) AS property_split_city
FROM nashville_housing;

ALTER TABLE nashville_housing 
ADD COLUMN property_split_address VARCHAR(255);
UPDATE nashville_housing 
SET property_split_address = SPLIT_PART("PropertyAddress", ', ', 1);

ALTER TABLE nashville_housing 
ADD COLUMN property_split_city VARCHAR(255);
UPDATE nashville_housing 
SET property_split_city = SPLIT_PART("PropertyAddress", ', ', 2); 

-- owner's address, city and state 
SELECT SPLIT_PART("OwnerAddress", ', ', 1)
as owner_split_address, 
		SPLIT_PART("OwnerAddress", ',', 2) AS owner_split_city,
		SPLIT_PART("OwnerAddress", ', ', 3) as owner_split_state
FROM nashville_housing;

ALTER TABLE nashville_housing 
ADD COLUMN owner_split_address VARCHAR(255); 
UPDATE nashville_housing 
SET owner_split_address = SPLIT_PART("OwnerAddress", ', ', 1);

ALTER TABLE nashville_housing 
ADD COLUMN owner_split_city VARCHAR(255); 
UPDATE nashville_housing 
SET owner_split_city = SPLIT_PART("OwnerAddress", ', ', 2);

ALTER TABLE nashville_housing 
ADD COLUMN owner_split_state VARCHAR(255); 
UPDATE nashville_housing 
SET owner_split_state = SPLIT_PART("OwnerAddress", ', ', 3);


-- Change Y and N to Yes and No respectively in SoldAsVacant column
SELECT DISTINCT "SoldAsVacant"
FROM nashville_housing;

UPDATE nashville_housing
SET "SoldAsVacant" = 
	CASE
		WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
		WHEN "SoldAsVacant" = 'N' THEN 'No'
		ELSE "SoldAsVacant"
		END;
		
-- Remove duplicates
-- Checking duplicates
WITH row_num_cte1 as(	
	SELECT *, ROW_NUMBER() OVER (PARTITION BY "ParcelID", "SaleDate", "SalePrice", "LegalReference") AS row_num
	FROM nashville_housing)
	
SELECT * 
FROM nashville_housing
WHERE "ParcelID" in 
	(SELECT "ParcelID" 
	FROM row_num_cte1
	WHERE row_num > 1)
ORDER BY nashville_housing."ParcelID";

-- Double checking duplicates
	-- retrieve column names instead of typing it 
SELECT '"' || STRING_AGG(column_name, '", "') || '"' AS columns
FROM information_schema.columns 
WHERE table_schema = 'public' AND 
	table_name = 'nashville_housing' AND 
	column_name NOT LIKE '%nique%'
GROUP BY table_name;

WITH row_num_cte2 AS (
	SELECT "ParcelID", "LandUse", "PropertyAddress", "SaleDate", "SalePrice", "LegalReference", "SoldAsVacant", "OwnerName", "OwnerAddress", "Acreage", "TaxDistrict", "LandValue", "BuildingValue", "TotalValue", "YearBuilt", "Bedrooms", "FullBath", "HalfBath", "property_split_address", "property_split_city", "owner_split_address", "owner_split_city", "owner_split_state",
		ROW_NUMBER() OVER (PARTITION BY "ParcelID", "LandUse", "PropertyAddress", "SaleDate", "SalePrice", "LegalReference", "SoldAsVacant", "OwnerName", "OwnerAddress", "Acreage", "TaxDistrict", "LandValue", "BuildingValue", "TotalValue", "YearBuilt", "Bedrooms", "FullBath", "HalfBath", "property_split_address", "property_split_city", "owner_split_address", "owner_split_city", "owner_split_state") AS row_num
	FROM nashville_housing)

SELECT * 
FROM nashville_housing 
WHERE "ParcelID" IN (
	SELECT "ParcelID"
	FROM row_num_cte2
	WHERE row_num > 1)
ORDER BY "ParcelID";

WITH row_num_cte1 as(	
	SELECT *, ROW_NUMBER() OVER (PARTITION BY "ParcelID", "SaleDate", "SalePrice", "LegalReference") AS row_num
	FROM nashville_housing), 
	
	row_num_cte2 AS (
	SELECT "ParcelID", "LandUse", "PropertyAddress", "SaleDate", "SalePrice", "LegalReference", "SoldAsVacant", "OwnerName", "OwnerAddress", "Acreage", "TaxDistrict", "LandValue", "BuildingValue", "TotalValue", "YearBuilt", "Bedrooms", "FullBath", "HalfBath", "property_split_address", "property_split_city", "owner_split_address", "owner_split_city", "owner_split_state",
		ROW_NUMBER() OVER (PARTITION BY "ParcelID", "LandUse", "PropertyAddress", "SaleDate", "SalePrice", "LegalReference", "SoldAsVacant", "OwnerName", "OwnerAddress", "Acreage", "TaxDistrict", "LandValue", "BuildingValue", "TotalValue", "YearBuilt", "Bedrooms", "FullBath", "HalfBath", "property_split_address", "property_split_city", "owner_split_address", "owner_split_city", "owner_split_state") AS row_num
	FROM nashville_housing)

SELECT * 
FROM nashville_housing 
WHERE "ParcelID" IN (
		SELECT "ParcelID"
		FROM row_num_cte1
		WHERE row_num > 1)
	AND "ParcelID" NOT IN (
		SELECT "ParcelID"
		FROM row_num_cte2
		WHERE row_num > 1)	
ORDER BY "ParcelID";

--  drop duplicated rows 
WITH row_num_cte2 AS (
	SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY "ParcelID", "LandUse", "PropertyAddress", "SaleDate", "SalePrice", "LegalReference", "SoldAsVacant", "OwnerName", "OwnerAddress", "Acreage", "TaxDistrict", "LandValue", "BuildingValue", "TotalValue", "YearBuilt", "Bedrooms", "FullBath", "HalfBath", "property_split_address", "property_split_city", "owner_split_address", "owner_split_city", "owner_split_state") AS row_num
	FROM nashville_housing)

DELETE FROM nashville_housing
WHERE "UniqueID" IN (
	SELECT "UniqueID"
	FROM row_num_cte2
	WHERE row_num > 1
	);
-- Delete unused columns
ALTER TABLE nashville_housing 
DROP COLUMN "OwnerAddress",
DROP COLUMN "PropertyAddress", 
DROP COLUMN "TaxDistrict";

SELECT * 
FROM nashville_housing;
