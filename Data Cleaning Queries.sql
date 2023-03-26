--CLEANING DATA

Select *
From [Portfolio Projects].. Nashville


--STANDARDISE DATE FORMAT

Select SaleDate,CONVERT(date,SaleDate)
From Nashville

Alter Table Nashville
Add SaleDateConverted Date


Update Nashville
Set SaleDateConverted=CONVERT(date,SaleDate)

Select SaleDateConverted
From Nashville

--POPULATE PROPERTY ADDRESS DATA

Select PropertyAddress
From Nashville
where PropertyAddress is null

Select *
From Nashville
where PropertyAddress is null

Select *
From Nashville
order by ParcelID --- we find that there are double parcel id

----self join 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From Nashville a
JOIN Nashville b
 On a.ParcelID=b.ParcelID
 And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

----populating the address
 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville a
JOIN Nashville b
 On a.ParcelID=b.ParcelID
 And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville a
JOIN Nashville b
 On a.ParcelID=b.ParcelID
 And a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


--BREAKING OUT PROPERTY ADDRESS INTO DIFFERENT COLUMNS (ADDRESS,CITY,STATE)

Select
SUBSTRING(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1, LEN(propertyaddress)) as address
From Nashville


Alter Table Nashville
Add PropertySplitAddress nvarchar(255)

Update Nashville
Set PropertySplitAddress=SUBSTRING(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter Table Nashville
Add PropertySplitCity nvarchar(255)

Update Nashville
Set PropertySplitCity=SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1, LEN(propertyaddress))

Select * 
From Nashville


--BREAKING OUT OWNER ADDRESS INTO DIFFERENT COLUMNS (ADDRESS,CITY,STATE)

Select
PARSENAME(REPLACE(owneraddress, ',','.'),3),
PARSENAME(REPLACE(owneraddress, ',','.'),2),
PARSENAME(REPLACE(owneraddress, ',','.'),1)
From Nashville


Alter Table Nashville
Add OwnerSplitAddress nvarchar(255)

Update Nashville
Set OwnerSplitAddress=PARSENAME(REPLACE(owneraddress, ',','.'),3)

Alter Table Nashville
Add OwnerSplitCity nvarchar(255)

Update Nashville
Set OwnerSplitCity=PARSENAME(REPLACE(owneraddress, ',','.'),2)

Alter Table Nashville
Add OwnerSplitState nvarchar(255)

Update Nashville
Set OwnerSplitState=PARSENAME(REPLACE(owneraddress, ',','.'),1)

Select * 
From Nashville


-- CHANGING 'Y' AND 'N' TO YES AND NO IN SOLDASVACANT

Select Distinct(SoldAsVacant),COUNt(SoldAsVacant)
From Nashville
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant='Y' then 'Yes'
     When SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
	 End
From Nashville

Update Nashville
Set SoldAsVacant=Case When SoldAsVacant='Y' then 'Yes'
                      When SoldAsVacant='N' then 'No'
	                  Else SoldAsVacant
	                  End

-- REMOVE DUPLICATES

With RowNumCTE
As
(
Select *,
ROW_NUMBER() Over (
             Partition By ParcelId,
			              PropertyAddress,
						  SalePrice,
						  SaleDate,
						  LegalReference
						  Order By
						  UniqueID
						  )
						  row_num

From Nashville
)

Select *
From RowNumCTE
Where row_num >1
Order by PropertyAddress

With RowNumCTE
As
(
Select *,
ROW_NUMBER() Over (
             Partition By ParcelId,
			              PropertyAddress,
						  SalePrice,
						  SaleDate,
						  LegalReference
						  Order By
						  UniqueID
						  )
						  row_num

From Nashville
)

Delete
From RowNumCTE
Where row_num >1


--DELETE UNUSED COLUMNS

Alter Table Nashville
Drop Column PropertyAddress, OwnerAddress

Alter Table Nashville
Drop Column SaleDate

Select*
From Nashville

