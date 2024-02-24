Use cleaningDataSet

--- create a backup of the table 


select * into dbo.housingTable_bckup from [dbo].[Housing Table];

select * from  dbo.housingTable_bckup ;

--------------------------------------------------
select count(*) from [cleaningDataSet].[dbo].[Housing Table] /* count the total rows */

select * from [cleaningDataSet].[dbo].[Housing Table];

select [UniqueID ] , count(*) from [cleaningDataSet].[dbo].[Housing Table] 
group by [UniqueID ] having count(*) > 1;

select top 100 [SaleDate] from 
[cleaningDataSet].[dbo].[Housing Table] ;
--------------------------------------------------


/*	STANDARDIZING THE DATE COLUMN*/
select [SaleDate], convert(date,[SaleDate]) AS ConvertedDate FROM 
[cleaningDataSet].[dbo].[Housing Table] ; 

--------------------------------------------------

/*ALTER THE DATATYPE OF DATE COLUMN*/
ALTER TABLE [cleaningDataSet].[dbo].[Housing Table] ALTER COLUMN [SaleDate] DATE;


SELECT * FROM [cleaningDataSet].[dbo].[Housing Table] WHERE [PropertyAddress] IS NULL;

--------------------------------------------------

/* To extract address from column propertyAddress and create a column PropertyAddWithoutCity*/

select PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1 ) as PropertyAddwithoutCity  
from [dbo].[Housing Table]

alter table  [dbo].[Housing Table] add PropertyAddWithoutCity nvarchar(255);


update [dbo].[Housing Table] set PropertyAddWithoutCity = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1 )

select top 10 * from [dbo].[Housing Table];
--------------------------------------------------

/* To extract city from column propertyAddress and create a column PropertyCity*/


select PropertyAddress, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress,1)+1,len(PropertyAddress) ) as PropertyCity  
from [dbo].[Housing Table]


alter table  [dbo].[Housing Table] add PropertyCity nvarchar(255);


update [dbo].[Housing Table] set PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress,1)+1,len(PropertyAddress) ) 

select top 10 * from [dbo].[Housing Table];

--------------------------------------------------
--Split Onwer Address 

SELECT PARSENAME(REPLACE(OwnerAddress,',' , '.'),3) as address,
PARSENAME(REPLACE(OwnerAddress,',' , '.'),2) as city,
PARSENAME(REPLACE(OwnerAddress,',' , '.'),1) as state 
from [dbo].[Housing Table]

or 


/*select OwnerAddress, SUBSTRING(OwnerAddress,1,CHARINDEX(',',PropertyAddress,1)-1)  as OwnerAddr  
from [dbo].[Housing Table]
*/
alter table [dbo].[Housing Table] add OwnerAdd nvarchar(255)

--update [dbo].[Housing Table] set OwnerAdd =  SUBSTRING(OwnerAddress,1,CHARINDEX(',',PropertyAddress,1)-1) 

update [dbo].[Housing Table] set OwnerAdd =  PARSENAME(REPLACE(OwnerAddress,',' , '.'),3) 

--

--Split Onwer City 

/*select OwnerAddress, SUBSTRING(OwnerAddress,CHARINDEX(',',PropertyAddress,1)+1, len(OwnerAddress))  as OwnerCity
from [dbo].[Housing Table]*/


alter table [dbo].[Housing Table] add OwnerCity nvarchar(255)

--update [dbo].[Housing Table] set OwnerCity = SUBSTRING(OwnerAddress,CHARINDEX(',',PropertyAddress,1)+1, len(OwnerAddress)) ;

update [dbo].[Housing Table] set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',' , '.'),2) 


--Split Onwer State 

alter table [dbo].[Housing Table] add OwnerState nvarchar(255)

update [dbo].[Housing Table] set OwnerState = PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)

----------------------------------



--- delete duplicate rows 
with rn_cte as (
  select *, row_number() over ( partition by  ParcelID, PropertyAddress, SaleDate, SalePrice, legalReference order by UniqueID ) as rn from 
   [dbo].[Housing Table]

) 
--select count(*) from rn_cte where rn > 1; --1577

delete from rn_cte where rn > 1;

-------------------------------

--- delete unused columns 

Alter table  [dbo].[Housing Table] drop column 
PropertyAddress,OwnerAddress, TaxDistrict;

-------------------------------

--- Update the SoldasVacant column with Yes or No values

select distinct(SoldAsVacant) from [dbo].[Housing Table] 


select SoldAsVacant , case when SoldAsVacant ='N' then 'No' 
                       when SoldAsVacant ='Y' then 'Yes'
					   else SoldAsVacant 
					   end 
from [dbo].[Housing Table] ;

update [dbo].[Housing Table]  set SoldAsVacant = case when SoldAsVacant ='N' then 'No' 
                       when SoldAsVacant ='Y' then 'Yes'
					   else SoldAsVacant 
					   end ;









