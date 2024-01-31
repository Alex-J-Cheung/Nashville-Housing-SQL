/* 

Cleaning Data in SQL

*/

-- Looking at Full Data
Select *
FROM NashvilleHousing..Nashville


-- Standardize Sale Date

Select SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing..Nashville

ALTER TABLE Nashville
Add SaleDate2 Date;

Update Nashville
SET SaleDate2 = CONVERT(Date,SaleDate)

-- Checking to see if the changes went through 
Select SaleDate2
FROM NashvilleHousing..Nashville


--  Populating Property Address data

Select *
From NashvilleHousing..Nashville
--WHERE PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing..Nashville as a
Join NashvilleHousing..Nashville as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing..Nashville as a
Join NashvilleHousing..Nashville as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Splitting Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing..Nashville

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From NashvilleHousing..Nashville

ALTER TABLE Nashville
Add PropertySplitAddress Nvarchar(255);

ALTER TABLE Nashville
Add PropertySplitCity Nvarchar(255);

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From NashvilleHousing..Nashville


Select OwnerAddress
From NashvilleHousing..Nashville

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashvilleHousing..Nashville

ALTER TABLE Nashville
Add OwnerSplitAddress nvarchar(255);

ALTER TABLE Nashville
Add OwnerSplitCity nvarchar(255);

ALTER TABLE Nashville
Add OwnerSplitState nvarchar(255);

Update Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From NashvilleHousing..Nashville


-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldasVacant), Count(SoldasVacant)
From NashvilleHousing..Nashville
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
	 END
From NashvilleHousing..Nashville

Update Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
	 END

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing..Nashville
)
--DELETE
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From NashvilleHousing..Nashville


-- Drop Unused Columns

Select *
From NashvilleHousing..Nashville

ALTER TABLE Nashville
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate