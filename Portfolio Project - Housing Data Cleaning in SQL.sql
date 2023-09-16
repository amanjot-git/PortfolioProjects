/*
	Cleaning Housing Data in SQL Queries

*/

-- Key things to do while data cleaning are : 
-- 1. Check for Date Format
-- 2. Check for any issues in Address
-- 3. Check for any empty field or anomaly
-- 4. Check for unused columns
-- 5. Check for duplicates

SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]

--------------------------------------------------------------------------------------------------------------------------

-- 1.	Standardizing Date Format


SELECT SaleDate
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]

-- As I have imported csv file, so the date format we have is just Date. But originally the excel file had DateTime as the datatype
--In order to update Datetime to Date, UPDATE and ALTER are used

--Add new colum SaleDateUpdated and then change the datatype

--ALTER TABLE [dbo].[NashvilleHousingData]
--ADD SaleDateUpdated Date

--UPDATE [dbo].[NashvilleHousingData]
--SET SaleDateUpdated=CONVERT (Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- 2.	Populate Property Address data

-- Firstly, Find how many records are there in data where Property address is missing.
-- I found 29 such records

SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]
  WHERE PropertyAddress IS NULL

-- Secondly, Update those empty data to actual Property Address data

-- For doing research on how to update PropertyAddress, I checked for patterns according to ParcelID

SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]
 -- WHERE PropertyAddress IS NULL
 ORDER BY ParcelID

 -- I found that there are Parcels with same ParcelID going to exact same Property Address
 -- Therefore, I one ParcelID has address but another ParcelID which is same but doesnt have Property Address, it should take the one where address is present

 --We join the table with itself using ParcelID and Unique ID as key

 
SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousingData] d1
  JOIN [PortfolioProject].[dbo].[NashvilleHousingData] d2
  ON d1.ParcelID=d2.ParcelID
  AND d1.UniqueID<>d2.UniqueID

  -- There are 17,318 records where same ParcelID but different UniqueID is going to same PropertyAddress.
  -- We just need the ones where Property Address is missing
 
 SELECT 
	d1.ParcelID
	,d1.PropertyAddress
	,d2.ParcelID
	,d2.PropertyAddress
	,ISNULL(d1.PropertyAddress,d2.PropertyAddress)
  FROM [PortfolioProject].[dbo].[NashvilleHousingData] d1
  JOIN [PortfolioProject].[dbo].[NashvilleHousingData] d2
  ON d1.ParcelID=d2.ParcelID
  AND d1.UniqueID<>d2.UniqueID
  WHERE d1.PropertyAddress IS NULL

-- Now update the change in data

UPDATE d1
SET PropertyAddress=ISNULL(d1.PropertyAddress,d2.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousingData] d1
  JOIN [PortfolioProject].[dbo].[NashvilleHousingData] d2
  ON d1.ParcelID=d2.ParcelID
  AND d1.UniqueID<>d2.UniqueID
  WHERE d1.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- 3.	Breaking out Address into Individual Columns (Address, City, State)
--There are , separating Address city and state

SELECT PropertyAddress
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]

SELECT
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
	,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
	--,SUBSTRING() AS State
 FROM [PortfolioProject].[dbo].[NashvilleHousingData]




 --Make the change in db using ALTER AND UPDATE


ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousingData]
ADD SplitAddress NVARCHAR(255)

UPDATE [PortfolioProject].[dbo].[NashvilleHousingData]
SET SplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousingData]
ADD SplitCity NVARCHAR(255)

UPDATE [PortfolioProject].[dbo].[NashvilleHousingData]
SET SplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 

-- I renamed columns SplitAddress and SplitCity to PropertySplitAddress and PropertySplitCity respectively as I had to clean Owner address as well. 

-- There is another function to retuen specific object : PARSENAME ('object_name' , object_piece )


--For example
--SELECT 
--  PARSENAME('PortfolioDB.dbo.PortfolioProject.CovidDeaths', 4) AS [Server],
--  PARSENAME('PortfolioDB.dbo.PortfolioProject.CovidDeaths', 3) AS [Schema],
--  PARSENAME('PortfolioDB.dbo.PortfolioProject.CovidDeaths', 2) AS [Database],
--  PARSENAME('PortfolioDB.dbo.PortfolioProject.CovidDeaths', 1) AS [Table];

--OUTPUT
--	Server		Schema		Database			Table
--PortfolioDB	dbo			PortfolioProject	CovidDeaths


-- I used PARSENAME AND REPLACE to obtain Split Owner Address 

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [PortfolioProject].[dbo].[NashvilleHousingData]


-- Making actual changes

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousingData]
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE [PortfolioProject].[dbo].[NashvilleHousingData]
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousingData]
ADD OwnerSplitCity NVARCHAR(255)

UPDATE [PortfolioProject].[dbo].[NashvilleHousingData]
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousingData]
ADD OwnerSplitState NVARCHAR(255)

UPDATE [PortfolioProject].[dbo].[NashvilleHousingData]
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]

--------------------------------------------------------------------------------------------------------------------------


-- 4.	Change 1 and 0 to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant, COUNT(SoldAsVacant)
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]
GROUP BY SoldAsVacant
ORDER BY 2

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousingData]
ADD SoldAsVacantUpdated NVARCHAR(255)

UPDATE [PortfolioProject].[dbo].[NashvilleHousingData]
SET SoldAsVacantUpdated=CONVERT (NVARCHAR(255),SoldAsVacant)

SELECT
	SoldAsVacant
	,CASE When SoldAsVacantUpdated = '1' THEN 'Yes'
	   When SoldAsVacantUpdated = '0' THEN 'No'
	   ELSE SoldAsVacantUpdated
	   END
	FROM [PortfolioProject].[dbo].[NashvilleHousingData]



-- To make actual changed in database

UPDATE [PortfolioProject].[dbo].[NashvilleHousingData]
SET SoldAsVacantUpdated=
	CASE When SoldAsVacantUpdated = '1' THEN 'Yes'
	   When SoldAsVacantUpdated = '0' THEN 'No'
	   ELSE SoldAsVacantUpdated
	   END

SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5.	Remove Duplicates

-- It is although not a standard practice to delete records from database. So I  just found that which and how many are duplicate records


SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]

-- I can use, ROW_NUMBER, RANK, DENSE_RANK to do the task

SELECT *
	,ROW_NUMBER()OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate , LegalReference ORDER BY UniqueID)AS rownum
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]
ORDER BY ParcelID

-- If ParcelID , Address, Sale Date is same, then I assumed it is same data


-- Using CTE, I rewrite the above query
WITH FindingDuplicatesCTE AS(
SELECT *
	,ROW_NUMBER()OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate , LegalReference ORDER BY UniqueID)AS rownum
  FROM [PortfolioProject].[dbo].[NashvilleHousingData]
--ORDER BY ParcelID
)

SELECT  * FROM FindingDuplicatesCTE
WHERE rownum > 1
ORDER BY PropertyAddress


-- There are 104 records with Same ParcelID, PropertyAddress, SalePrice, SaleDate , LegalReference with at least one existing record each

SELECT *
FROM [PortfolioProject].[dbo].[NashvilleHousingData]


---------------------------------------------------------------------------------------------------------

-- 6.	Delete Unused Columns

-- I don't need some columns like OwnerAddress, TaxDistrict, PropertyAddress, SaleDate as either I have the updated version of them  or they are althogether of no use in my analysis

ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousingData]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate