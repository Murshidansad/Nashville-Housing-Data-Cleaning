----------------------------------------------------------------------------------------------------------------------------
# Nashville Housing Data Cleaning
----------------------------------------------------------------------------------------------------------------------------
SELECT *
 FROM portfolioproject.`nashville housing`;
 
 # Populate Property Address Data
 
 select  * 
 from portfolioproject.`nashville housing`
 where PropertyAddress !=''
 order by ParcelID;
 
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ifnull (b.PropertyAddress, a.PropertyAddress)
from portfolioproject.`nashville housing` a
join portfolioproject.`nashville housing` b
    on a.ParcelID = b.ParcelID
    and a.UniqueID != b.UniqueID
where a.PropertyAddress = '';

update portfolioproject.`nashville housing` a
join portfolioproject.`nashville housing` b
    on a.ParcelID = b.ParcelID
    and a.UniqueID != b.UniqueID
set a.PropertyAddress = ifnull(b.PropertyAddress, a.PropertyAddress)
where a.PropertyAddress = '';

# Breaking out Address into individual columns (Address, City, State)

select PropertyAddress
from portfolioproject.`nashville housing`;

select substring(PropertyAddress, 1, locate(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, locate(',', PropertyAddress) + 1 , length(PropertyAddress)) as Address
from portfolioproject.`nashville housing`;

alter table `nashville housing`
add PropertySplitAddress nvarchar(255);

update portfolioproject.`nashville housing`
set PropertySplitAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress)-1);

alter table `nashville housing`
add PropertySplitCity nvarchar(255);

update portfolioproject.`nashville housing`
set PropertySplitCity = substring(PropertyAddress, locate(',', PropertyAddress) + 1 , length(PropertyAddress));

Select *
From portfolioproject.`nashville housing`;

# Breaking out OwnerAddress into individual columns (Address, City, State)

select OwnerAddress
from portfolioproject.`nashville housing`;

select substring_index(OwnerAddress,',',1) AS Address
,substring_index(substring_index(OwnerAddress, ',', 2),',', -1) AS Address
,substring_index(OwnerAddress,',', -1) AS Address
from portfolioproject.`nashville housing`;

alter table `nashville housing`
add OwnerSplitAddress nvarchar(255);

update portfolioproject.`nashville housing`
set OwnerSplitAddress = substring_index(OwnerAddress,',',1);

alter table `nashville housing`
add OwnerSplitCity nvarchar(255);

update portfolioproject.`nashville housing`
set OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2),',', -1);

alter table `nashville housing`
add OwnerSplitState nvarchar(255);

update portfolioproject.`nashville housing`
set OwnerSplitState = substring_index(OwnerAddress,',', -1);

Select *
From portfolioproject.`nashville housing`;


# Change Y and N to Yes and No in "Sold as Vacant" Field

select Distinct (SoldAsVacant), Count(SoldAsVAcant)
From portfolioproject.`nashville housing`
Group by SoldAsVacant
Order by 2;

Select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     End
From portfolioproject.`nashville housing`;

Update portfolioproject.`nashville housing`
Set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     End;

# Remove Duplicates
# Find rows with same ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference

with RowNumCTE as(
Select *,	
         row_number() over(
		 partition by ParcelID,
         PropertyAddress,
         SalePrice,
         SaleDate,
         LegalReference
         order by UniqueID
         ) row_num
From portfolioproject.`nashville housing`
-- order by ParcelID
)
-- Delete those rows that occur more than once ( row_num>1) are duplicates 
Delete From portfolioproject.`nashville housing`
using portfolioproject.`nashville housing` 
join RowNumCTE on portfolioproject.`nashville housing`.UniqueID = RowNumCTE.UniqueID
where RowNumCTE.row_num > 1;

select * 
From portfolioproject.`nashville housing`;

# Drop unused columns

alter table `nashville housing`
drop column OwnerAddress, 
drop column TaxDistrict,
drop column  PropertyAddress;

