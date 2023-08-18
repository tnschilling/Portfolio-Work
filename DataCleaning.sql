Select *
From Portfolio1.dbo.housing_data


-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From Portfolio1..housing_data

ALTER TABLE housing_data
Add SaleDateConverted Date;

Update housing_data
Set SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate PropertyAddress Data Where Null

Select *
From housing_data
Where PropertyAddress is null

Select ParcelID, PropertyAddress, SaleDate
From housing_data

Select a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio1..housing_data a
Join Portfolio1..housing_data b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio1..housing_data a
Join Portfolio1..housing_data b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null



-- PropertyAddress transformation --> Address, City to seperate columns

Select PropertyAddress
From housing_data

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From housing_data

ALTER TABLE housing_data
Add SplitAddress Nvarchar(255);

Update housing_data
Set SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE housing_data
Add SplitCity Nvarchar(255);

Update housing_data
Set SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



-- OwnerAddress transformation --> Address, City, State to seperate columns

Select OwnerAddress
From housing_data

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From housing_data


ALTER TABLE housing_data
Add OwnerSplitAddress Nvarchar(255);

Update housing_data
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE housing_data
Add OwnerSplitCity Nvarchar(255);

Update housing_data
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE housing_data
Add OwnerSplitState Nvarchar(255);

Update housing_data
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- SoldAsVacant --> 'Y', 'N' to 'Yes', 'No'

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From housing_data
Group by SoldAsVacant

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From housing_data

Update housing_data
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END




-- Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num
From housing_data
)
Select *
From RowNumCTE
Where row_num > 1




-- Delete Unused Columns

Select *
From housing_data

ALTER TABLE housing_data
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict