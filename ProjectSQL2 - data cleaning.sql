create database if not exists Housing;

use Housing;

-- creating table

create table NashvilleHousing
( UniqueID varchar(255),
ParcelID varchar(255),
LandUse varchar(255),
PropertyAddress varchar(255),
SaleDate varchar(255),
SalePrice varchar(255),
LegalReference varchar(255),
SoldAsVacant varchar(255),
OwnerName varchar(255),
OwnerAddress varchar(255),
Acreage varchar(255),
TaxDistrict varchar(255),
LandValue varchar(255),
BuildingValue varchar(255),
TotalValue varchar(255),
YearBuilt varchar(255),
Bedrooms varchar(255),
FullBath varchar(255),
HalfBath varchar(255));

-- filling data into created table

select * from NshvilleHousing;

SHOW VARIABLES LIKE "secure_file_priv";

secure_file_priv   C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NashvilleHousingData.csv' into table NashvilleHousing
fields terminated by ','
ENCLOSED BY '"'
ignore 1 lines;



-- altering table

select * from NashvilleHousing;

alter table NashvilleHousing modify column SaleDate date;

-- populating property address data

select PropertyAddress 
from NashvilleHousing
where PropertyAddress = '';

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID;

update NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
    set a.PropertyAddress = b.PropertyAddress
    where a.PropertyAddress = '';
    
select * from NashvilleHousing;

-- breaking out address into individual columns - address, city and state
    
    -- property address

select
substring(PropertyAddress, 1, locate(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, locate(',', PropertyAddress) + 1, length(PropertyAddress)) as Address
from NashvilleHousing;

Alter table NashvilleHousing
add PropertySplitAddress varchar(255);

Update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress) - 1);


Alter table NashvilleHousing
add PropertySplitCity varchar(255);

Update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, locate(',', PropertyAddress) + 1, length(PropertyAddress));

select * from NashvilleHousing;

    -- owner address

select 
SPLIT_STRING(OwnerAddress,',',1),
SPLIT_STRING(OwnerAddress,',',2),
SPLIT_STRING(OwnerAddress,',',3)
from NashvilleHousing;

-- creating a function to split string

DROP FUNCTION IF EXISTS SPLIT_STRING;

DELIMITER $

CREATE FUNCTION 
   SPLIT_STRING ( s VARCHAR(1024) , del CHAR(1) , i INT)
   RETURNS VARCHAR(1024)
   DETERMINISTIC -- always returns same results for same input parameters
    BEGIN

        DECLARE n INT ;

        -- get max number of items
        SET n = LENGTH(s) - LENGTH(REPLACE(s, del, '')) + 1;

        IF i > n THEN
            RETURN NULL ;
        ELSE
            RETURN SUBSTRING_INDEX(SUBSTRING_INDEX(s, del, i) , del , -1 ) ;        
        END IF;

    END
$

DELIMITER ;

Alter table NashvilleHousing
add OwnerSplitAddress varchar(255);

Update NashvilleHousing
set OwnerSplitAddress = SPLIT_STRING(OwnerAddress,',',1);


Alter table NashvilleHousing
add OwnerSplitCity varchar(255);

Update NashvilleHousing
set OwnerSplitCity = SPLIT_STRING(OwnerAddress,',',2);


Alter table NashvilleHousing
add OwnerSplitState varchar(255);

Update NashvilleHousing
set OwnerSplitState = SPLIT_STRING(OwnerAddress,',',3);

select * from NashvilleHousing;


-- changing Y and N to Yes and No in SoldAsVacant column

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end;
 
 -- removing duplicates

 with RowNumCTE as(
 select *,
 row_number() over (
 partition by ParcelID,
			  PropertyAddress,
              SalePrice,
              SaleDate,
              LegalReference
              order by
				UniqueID
                ) row_num2
from NashvilleHousing
)
select *
from RowNumCTE
where row_num2 > 1;
-- order by PropertyAddress


alter table NashvilleHousing 
drop column row_num;

                             
select * from (
 Select *, row_number() over (
 partition by ParcelID,
			  PropertyAddress,
              SalePrice,
              SaleDate,
              LegalReference
              order by
				UniqueID) as row_num1
                from NashvilleHousing)
                as temp_table 
                where row_num1 >1;
                
delete from NashvilleHousing where UniqueID in (
 Select UniqueID from (select *, row_number() over (
 partition by ParcelID,
			  PropertyAddress,
              SalePrice,
              SaleDate,
              LegalReference
              order by
				UniqueID) as row_num1
                from NashvilleHousing)
                as temp_table 
                where row_num1 >1);
                
Select * from NashvilleHousing;


-- deleting unused columns 

alter table NashvilleHousing 
drop column OwnerAddress;

alter table NashvilleHousing 
drop column PropertyAddress;

alter table NashvilleHousing 
drop column TaxDistrict;