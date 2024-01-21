/*
Cleaning Data in SQL Queries
*/
SELECT *
FROM PortfolioProject.DBO.NashvilleHousing

-- STANDARDIZE DATE FORMAT



UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing 
ADD  SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted ,CONVERT(Date,SaleDate) AS SaleDate
FROM PortfolioProject.DBO.NashvilleHousing


--Populate Property Address Data

SELECT *
FROM PortfolioProject.DBO.NashvilleHousing
WHERE PropertyAddress is null


SELECT *
FROM PortfolioProject.DBO.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress
FROM PortfolioProject.DBO.NashvilleHousing a
JOIN PortfolioProject.DBO.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL   



SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.DBO.NashvilleHousing a
JOIN PortfolioProject.DBO.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL  

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.DBO.NashvilleHousing a
JOIN PortfolioProject.DBO.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

--Check the property address has no null values after the update of the address

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.DBO.NashvilleHousing a
JOIN PortfolioProject.DBO.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL  


--Breaking Out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.DBO.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address
FROM PortfolioProject.DBO.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
FROM PortfolioProject.DBO.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress) - 1) as Address
  , SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress) , LEN (PropertyAddress)) as Address
FROM PortfolioProject.DBO.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress) - 1) as Address
  , SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress) + 1, LEN (PropertyAddress)) as Address
FROM PortfolioProject.DBO.NashvilleHousing


ALTER TABLE NashvilleHousing 
ADD  PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress) - 1)

ALTER TABLE NashvilleHousing 
ADD  PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress) + 1, LEN (PropertyAddress))

SELECT *
FROM PortfolioProject.DBO.NashvilleHousing


SELECT OwnerAddress
FROM PortfolioProject.DBO.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) As City
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) As state
FROM PortfolioProject.DBO.NashvilleHousing



ALTER TABLE NashvilleHousing 
ADD  OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing 
ADD  OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE NashvilleHousing 
ADD  OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


SELECT *
FROM PortfolioProject.DBO.NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT  (SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing

SELECT DISTINCT  (SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
GROUP BY (SoldAsVacant)

SELECT DISTINCT  (SoldAsVacant), COUNT(SoldAsVacant) as NoSoldAsVacant 
From PortfolioProject.dbo.NashvilleHousing
GROUP BY (SoldAsVacant)
ORDER BY 2



SELECT SoldAsVacant
  , CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
         WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
From PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
         WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
From PortfolioProject.dbo.NashvilleHousing



SELECT DISTINCT  (SoldAsVacant), COUNT(SoldAsVacant) as NoSoldAsVacant 
From PortfolioProject.dbo.NashvilleHousing
GROUP BY (SoldAsVacant)
ORDER BY 2


-- Exploring DUPLICATES

WITH RowNumCTE AS (
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				        UniqueID
						)
						row_num
From PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--Deleting Duplicates


WITH RowNumCTE AS (
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				        UniqueID
						)
						row_num
From PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- CHECK FOR DUPLICATES

WITH RowNumCTE AS (
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				        UniqueID
						) row_num
From PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1



--Delete Unused Columns 

SELECT *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

SELECT *
From PortfolioProject.dbo.NashvilleHousing










