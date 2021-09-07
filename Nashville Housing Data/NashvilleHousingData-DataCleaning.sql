Select * 
From PortfolioProject.dbo.[Nashville-Housing];


--Standardize date format

ALTER TABLE PortfolioProject.dbo.[Nashville-Housing]
Add SalesDate Date;

Update PortfolioProject.dbo.[Nashville-Housing]
SET SalesDate = CONVERT(date,SaleDate);

Select SaleDate,SalesDate
From PortfolioProject.dbo.[Nashville-Housing];


----Populate Property Address date

Select *
From PortfolioProject.dbo.[Nashville-Housing]
--where PropertyAddress is NULL;
order by ParcelID;


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Nashville-Housing] a
JOIN PortfolioProject.dbo.[Nashville-Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL;


Update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.[Nashville-Housing] a
JOIN PortfolioProject.dbo.[Nashville-Housing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL;


Select *
From PortfolioProject.dbo.[Nashville-Housing]
order by ParcelID;


---Breaking Address into Columns (Address,City,State)


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress))+1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.[Nashville-Housing]


ALTER TABLE PortfolioProject.dbo.[Nashville-Housing]
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.[Nashville-Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1);

ALTER TABLE PortfolioProject.dbo.[Nashville-Housing]
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.[Nashville-Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress))+1, LEN(PropertyAddress));


Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From PortfolioProject.dbo.[Nashville-Housing];



---Breaking Owner Address into Columns (Address,City,State)


Select OwnerAddress
From PortfolioProject.dbo.[Nashville-Housing];


Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.[Nashville-Housing];


ALTER TABLE PortfolioProject.dbo.[Nashville-Housing]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.[Nashville-Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


ALTER TABLE PortfolioProject.dbo.[Nashville-Housing]
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.[Nashville-Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE PortfolioProject.dbo.[Nashville-Housing]
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.[Nashville-Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


Select OwnerAddress,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
from PortfolioProject.dbo.[Nashville-Housing];


---Change Y and N to Yes and No in 'Sold As Vacant' field
Select Distinct(SoldAsVacant),Count(SoldAsVacant)
from PortfolioProject.dbo.[Nashville-Housing]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
from PortfolioProject.dbo.[Nashville-Housing]


UPDATE PortfolioProject.dbo.[Nashville-Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END


--Remove Duplicates
WITH RowNumCTE as
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
				 ) row_num
From PortfolioProject.dbo.[Nashville-Housing]
)
--Select *
--FROM RowNumCTE
--where row_num > 1

DELETE
From RowNumCTE
where row_num > 1
--Order by PropertyAddress;


--- Delete unused columns

Select *
From PortfolioProject.dbo.[Nashville-Housing]; 

ALTER TABLE PortfolioProject.dbo.[Nashville-Housing]
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict;