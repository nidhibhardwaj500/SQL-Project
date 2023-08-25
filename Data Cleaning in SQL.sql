-- Cleaning Data in SQL

Use PortfolioProject
Select * from NashvilleHousing;

-- Standardise Date Format

Alter Table NashvilleHousing
Add Saledateconverted  Date;

Update NashvilleHousing
Set Saledateconverted = Convert (Date, Saledate);



--Populate Property Address Data
Select *
From NashvilleHousing
--where PropertyAddress is Null
order by ParcelID;

Use PortfolioProject
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a
Join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


Update a
Set PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a
Join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


-- Breaking out Address into individual columns (Address, City, State)
Select PropertyAddress
From NashvilleHousing

Use PortfolioProject
Select substring(propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From PortfolioProject.dbo.NashvilleHousing

Select owneraddress
from NashvilleHousing;

Use PortfolioProject
Select
PARSENAME(Replace(owneraddress, ',', '.'), 1),
PARSENAME(Replace(owneraddress, ',', '.'), 2),
PARSENAME(Replace(owneraddress, ',', '.'), 3)
from NashvilleHousing;

--Change Y and N to Yes and No in "Sold as Vacant" field
Use PortfolioProject
Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
from NashvilleHousing
Group by SoldAsVacant
Order by 2;

Use PortfolioProject
Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End
From NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
End
--From NashvilleHousing;

-- Remove Duplicates
With RowNumCTE As (
Select *,
ROW_NUMBER() over (
Partition By ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order By UniqueID
			 )
			 row_num
		
from NashvilleHousing
)
Select *  from RowNumCTE
Where row_num > 1
Order By PropertyAddress

--Delete Unused Columns
Use PortfolioProject
Select * from NashvilleHousing;

Use PortfolioProject
Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress;



