-- -- -- -- -- -- Cleaning Data in SQL Queries -- -- -- -- -- --

SELECT *
FROM CleaningDataProject.dbo.NashvilleHousing;


-- -- -- -- -- -- Standardize Date Format -- -- -- -- -- -- 


SELECT SaleDate, CONVERT(Date,SaleDate)
FROM CleaningDataProject.dbo.NashvilleHousing;

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);


-- -- -- -- -- -- Populate propert Address Data -- -- -- -- -- --


SELECT *
FROM CleaningDataProject.dbo.NashvilleHousing


-- -- -- -- -- -- WHERE PropertyAddress IS NULL -- -- -- -- -- --


ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM CleaningDataProject.dbo.NashvilleHousing a
JOIN CleaningDataProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM CleaningDataProject.dbo.NashvilleHousing a
JOIN CleaningDataProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


-- -- -- -- -- -- Breaking out Address into Individual Columns (Address, City) for PropertyAddress -- -- -- -- -- --


SELECT PropertyAddress
FROM CleaningDataProject.dbo.NashvilleHousing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM CleaningDataProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress));



-- -- -- -- -- -- Breaking out Address into Individual Columns (Address, City, State) for OwnerAddress -- -- -- -- -- --


SELECT OwnerAddress
FROM CleaningDataProject.dbo.NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),       --PARSENAME only looks for '.', so you must replace ',' w/ '.'
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) 
FROM CleaningDataProject.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1);


-- -- -- -- -- -- Change Y and N to 'Yes' and 'No' in Sold as Vacant field -- -- -- -- -- --

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM CleaningDataProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN CAST(SoldAsVacant AS VARCHAR(3)) = 1 THEN 'Yes'
	WHEN CAST(SoldAsVacant AS VARCHAR(3)) = 0 THEN 'No'
	ELSE CAST(SoldAsVacant AS VARCHAR(3))
	END
FROM CleaningDataProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(3);

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = '1' THEN 'Yes'
		WHEN SoldAsVacant = '0' THEN 'No'
		ELSE SoldAsVacant
		END



-- -- -- -- -- -- Rounding Acreage to 2 Deciaml Places -- -- -- -- -- --


SELECT
ROUND(Acreage, 2)
FROM CleaningDataProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD AcreageRounded FLOAT;

UPDATE NashvilleHousing
SET AcreageRounded = ROUND(Acreage, 2);

-- -- -- -- -- -- Remove Duplicates -- -- -- -- -- --

WITH RowNumCTE AS(
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
FROM CleaningDataProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;


-- -- -- -- -- -- Delete Unused Coloumns -- -- -- -- -- --


ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate, Acreage;





