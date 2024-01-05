select * from nashvilleHousing

--standarlize Date format
select SaleDate , convert(Date,SaleDate)
from nashvilleHousing

Update nashvillehousing
set SaleDate = convert(Date,SaleDate)

alter table nashvilleHousing
add SaleDateConverted Date


Update nashvillehousing
set SaleDateConverted = convert(Date,SaleDate)



--populate property address data
select *
from nashvilleHousing
--where PropertyAddress is null
order by ParcelID


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing a 
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


--breaking down address into individual columns (address, city, state)
select PropertyAddress 
from nashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from nashvilleHousing


alter table nashvilleHousing
add PropertySplitAddress Nvarchar(255)

Update nashvillehousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table nashvilleHousing
add PropertySplitCity Nvarchar(255)

Update nashvillehousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))


select *
from nashvilleHousing

select OwnerAddress
from nashvilleHousing

select 
PARSENAME(REPLACE(owneraddress,',','.'),3) as OwnerSplitAddress,
PARSENAME(REPLACE(owneraddress,',','.'),2) as OwnerSplitCity,
PARSENAME(REPLACE(owneraddress,',','.'),1) as OwnerSplitState 
from NashvilleHousing

alter table nashvilleHousing
add OwnerSplitAddress Nvarchar(255)

Update nashvillehousing
set OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3) 

alter table nashvilleHousing
add OwnerSplitCity Nvarchar(255)

Update nashvillehousing
set OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2) 


alter table nashvilleHousing
add OwnerSplitState Nvarchar(255)

Update nashvillehousing
set OwnerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1) 

select *
from nashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select soldAsVacant, Case 
when soldAsVacant = 'Y' Then 'Yes'
when soldAsVacant = 'N' Then 'No'
else SoldAsVacant
end
from NashvilleHousing
where SoldAsVacant = 'N' or SoldAsVacant = 'Y'


Update NashvilleHousing
set SoldAsVacant = Case 
when soldAsVacant = 'Y' Then 'Yes'
when soldAsVacant = 'N' Then 'No'
else SoldAsVacant
end


--Remove Duplicates
With RowNumCTE As (
select * ,
   ROW_NUMBER() OVER (
   Partition by ParcelID, propertyAddress, SalePrice, SaleDate, LegalReference
   Order by uniqueId) row_num
from NashvilleHousing
--order by parcelID
)
Delete
--select * 
from RowNumCTE
where row_num>1
--order by PropertyAddress



--Delete unused columns
select *
from nashvilleHousing


alter table nashvilleHousing
DROP Column ownerAddress, propertyAddress, taxDistrict, saleDate

