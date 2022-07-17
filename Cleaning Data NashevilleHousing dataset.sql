

------DATA CLEANING--------------------------


SELECT *
FROM PortfolioProjects.dbo.NashevilleHousing


--Standart Date Format------------------------


--Adding a new column in date format:
SELECT SaleDateConverted,
	CONVERT(Date, SaleDate)
FROM PortfolioProjects.dbo.NashevilleHousing

--chunk code:
UPDATE PortfolioProjects.dbo.NashevilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE PortfolioProjects.dbo.NashevilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProjects.dbo.NashevilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);



--Populate Property Address data------------------------


--I found NULL in Address column and explored that the same ParcelIdes have the same Addresses
SELECT *
FROM PortfolioProjects.dbo.NashevilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelId

--Use JOIN in order to get rid off NULL in Address column:
SELECT *
FROM PortfolioProjects.dbo.NashevilleHousing AS yesnull
JOIN PortfolioProjects.dbo.NashevilleHousing AS nonull
	ON yesnull.ParcelID = nonull.ParcelID
	AND yesnull.[UniqueID] <> nonull.[UniqueID]

--Checking the result:
SELECT yesnull.ParcelID, yesnull.PropertyAddress, nonull.ParcelID, nonull.PropertyAddress
JOIN PortfolioProjects.dbo.NashevilleHousing AS nonull
	ON yesnull.ParcelID = nonull.ParcelID
	AND yesnull.[UniqueID] <> nonull.[UniqueID]
WHERE yesnull.PropertyAddress IS NULL

--Update the table:
UPDATE yesnull
SET PropertyAddress = ISNULL(yesnull.PropertyAddress, nonull.PropertyAddress)
FROM PortfolioProjects.dbo.NashevilleHousing AS yesnull
JOIN PortfolioProjects.dbo.NashevilleHousing AS nonull
	ON yesnull.ParcelID = nonull.ParcelID
	AND yesnull.[UniqueID] <> nonull.[UniqueID]

-- Double checking the NULLS:
SELECT *
FROM PortfolioProjects.dbo.NashevilleHousing
WHERE PropertyAddress IS NULL


--Breaking out the Addres into Individual Columns (Address, City and State)------------------------

--We see that delimetr in Address is a comma:
SELECT PropertyAddress
FROM PortfolioProjects.dbo.NashevilleHousing
 
--Breaking the Address before comma:
 SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
 FROM PortfolioProjects.dbo.NashevilleHousing

--Breaking the address and City:
 SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
 FROM PortfolioProjects.dbo.NashevilleHousing

--Creating a new column Address(without a city):

ALTER TABLE PortfolioProjects.dbo.NashevilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProjects.dbo.NashevilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

--Creating a new column City(without an address):

ALTER TABLE PortfolioProjects.dbo.NashevilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProjects.dbo.NashevilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


---The result:
SELECT SaleDateConverted, PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProjects.dbo.NashevilleHousing


--Breaking the owner address, using PARSENAME.------------------------

--Onwner address has one dot and one comma:

SELECT OwnerAddress
FROM PortfolioProjects.dbo.NashevilleHousing

--Replacing comma to dot and breaking:

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM PortfolioProjects.dbo.NashevilleHousing

--Creating new columns from splitted OwnerAddress:

ALTER TABLE PortfolioProjects.dbo.NashevilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProjects.dbo.NashevilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3);


ALTER TABLE PortfolioProjects.dbo.NashevilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProjects.dbo.NashevilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2);

ALTER TABLE PortfolioProjects.dbo.NashevilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProjects.dbo.NashevilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1);

--checking the result:
SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProjects.dbo.NashevilleHousing


--Changing Y and N to Yes and No:--------------------

--checking variances and amount:
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects.dbo.NashevilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Changing:
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProjects.dbo.NashevilleHousing

UPDATE PortfolioProjects.dbo.NashevilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

--Remove duplicates.CTE---------------------------------------

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER 
	(
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
		) row_num
FROM PortfolioProjects.dbo.NashevilleHousing
)

--Erasing duplicates(104 rows will be affected):
DELETE
FROM RowNumCTE
WHERE row_num > 1

--Checking duplicates(code chunk above is commented):

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--Delete unused columns.--------------------------------------

ALTER TABLE PortfolioProjects.dbo.NashevilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

--checking the final result:
SELECT *
FROM PortfolioProjects.dbo.NashevilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------