select * 
from [Portfolio project]..NashvilleHousing

-- Standardize data format

select saledate, convert(date,saledate)
from [Portfolio project]..NashvilleHousing

update NashvilleHousing
set saledate = CONVERT(date,saledate)

alter table NashvilleHousing
alter column saledate date

alter table NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted = CONVERT(date,saledate)

-- Populate property address data

select *
from [Portfolio project]..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress,b.PropertyAddress)
from [Portfolio project]..NashvilleHousing a 
join [Portfolio project]..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.propertyaddress,b.PropertyAddress)
from [Portfolio project]..NashvilleHousing a 
join [Portfolio project]..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out adress into individual comlumns

select PropertyAddress
from [Portfolio project]..NashvilleHousing
order by ParcelID


select
SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) -1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) +1, len(propertyaddress)) as address
from [Portfolio project]..NashvilleHousing

alter table NashvilleHousing
add propertysplitaddress nvarchar(255)

update NashvilleHousing
set propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) -1)

alter table NashvilleHousing
add propertysplitcity nvarchar(255)

update NashvilleHousing
set propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) +1, len(propertyaddress))

select *
from [Portfolio project]..NashvilleHousing

select 
PARSENAME(replace(owneraddress, ',','.'),3),
PARSENAME(replace(owneraddress, ',','.'),2),
PARSENAME(replace(owneraddress, ',','.'),1)

from [Portfolio project]..NashvilleHousing

alter table NashvilleHousing
add ownersplitaddress nvarchar(255)

update NashvilleHousing
set ownersplitaddress = PARSENAME(replace(owneraddress, ',','.'),3)

alter table NashvilleHousing
add ownersplitcity nvarchar(255)

update NashvilleHousing
set ownersplitcity = PARSENAME(replace(owneraddress, ',','.'),2)

alter table NashvilleHousing
add ownersplitstate nvarchar(255)

update NashvilleHousing
set ownersplitstate = PARSENAME(replace(owneraddress, ',','.'),1)

select *
from [Portfolio project]..NashvilleHousing

-- Change Y and N to Yes and No in 'Sold as vacant' field

select distinct(SoldAsVacant), count(soldasvacant)
from [Portfolio project]..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'y' then 'Yes'
when SoldAsVacant = 'n' then 'No'
else SoldAsVacant
end
from [Portfolio project]..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'y' then 'Yes'
when SoldAsVacant = 'n' then 'No'
else SoldAsVacant
end

-- Remove duplicates
select *
from [Portfolio project]..NashvilleHousing
order by 1

with rownumcte as (
select *,
ROW_NUMBER() over (
partition by parcelid,
propertyaddress,
saleprice,
saledate,
legalreference
order by uniqueid
) row_num
from [Portfolio project]..NashvilleHousing)
select * from rownumcte
where row_num >1
--order by PropertyAddress