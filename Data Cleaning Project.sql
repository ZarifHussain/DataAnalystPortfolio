select *
from [PortfolioProject]..[HousingProject] 


-- Standardize Sale Date Format 

alter table HousingProject alter column SaleDate date (table updated with)
select *
from HousingProject

-------------------------------------------------------

--Remove Null Property Address Data 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from HousingProject a
join HousingProject b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from HousingProject a
join HousingProject b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


-------------------------------------------------------


--- Seperate out Address into Individual Columns (Address, City, State)
select *
from HousingProject

select SUBSTRING (propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, substring (propertyaddress, CHARINDEX(',', PropertyAddress) +1, LEN(propertyaddress)) as Address
from HousingProject

--alter table housingproject add FirstLineofAddress nvarchar(255)
--alter table housingproject add City nvarchar(255)

update HousingProject 
	set FirstLineofAddress = SUBSTRING (propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 

update HousingProject 
	set City = Substring (propertyaddress, CHARINDEX(',', PropertyAddress) +1, LEN(propertyaddress))

Select FirstLineofAddress, City
from HousingProject

--Alternative and Quicker Way using parsename:
--select PARSENAME (replace(owneraddress, ',', '.'),3)
--, PARSENAME (replace(owneraddress, ',', '.'),2)
--, PARSENAME (replace(owneraddress, ',', '.'), 1)
--from HousingProject
------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), COUNT(soldasvacant)
from HousingProject
group by SoldAsVacant
order by 2

select soldasvacant, case 
			when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
			end
from HousingProject

update HousingProject
set soldasvacant = case 
			when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
			end







---------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS(
Select ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num, *
From HousingProject
)

select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from HousingProject

alter table housingproject
drop column taxdistrict, yearbuilt, fullbath, halfbath