SELECT*
FROM NashvilleHousing


-- This is Standadising the date format--

SELECT SaleDate, CONVERT(DATE,SaleDate) 
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate);

ALTER TABLE Nashvillehousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate);

Select SaleDateConverted
From NashvilleHousing;


--Populating the Property Address Data--

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

--Inner join the same table to remove the duplicates -- 
SELECT NashA.ParcelID, NashA.PropertyAddress, NashB.ParcelID,NashB.PropertyAddress, ISNULL(NashA.PropertyAddress,NashB.PropertyAddress)
FROM NashvilleHousing NashA
JOIN NashvilleHousing NashB
	ON NashA.ParcelID = NashB.ParcelID
	AND NashA.[UniqueID ]<> NashB.[UniqueID ]
WHERE NashA.PropertyAddress IS NULL

Update NashA
SET PropertyAddress = ISNULL(NashA.PropertyAddress,NashB.PropertyAddress)
FROM NashvilleHousing NashA
JOIN NashvilleHousing NashB
	ON NashA.ParcelID = NashB.ParcelID
	AND NashA.[UniqueID ]<> NashB.[UniqueID ]
WHERE NashA.PropertyAddress IS NULL

-- Dividing the Address into Individual Columns (Adress ,City and State) 

Select PropertyAddress
From NashvillHousing 

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress ,CHARINDEX(',' ,PropertyAddress)+1 ,LEN(PropertyAddress)) AS City
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(225);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(225);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress ,CHARINDEX(',' ,PropertyAddress)+1 ,LEN(PropertyAddress))

SELECT*
FROM NashvilleHousing 

--- Splitting the Owner Address using PARSENAME-- 


Select OwnerAddress
From NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress ,',', '.' ),3) as OwnerAddress
,PARSENAME(REPLACE(OwnerAddress ,',', '.' ),2)  as OwnerCity
,PARSENAME(REPLACE(OwnerAddress ,',', '.' ),1)  as OwnerState
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(225);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress ,',', '.' ),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(225);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress ,',', '.' ),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(225);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress ,',', '.' ),1)

SELECT*
FROM NashvilleHousing


--Chaning Y and N to Yes and No in (Sold as Vacant) Field--

SELECT DISTINCT SoldAsVacant , COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 

SELECT SoldAsVacant 
,CASE WHEN SoldAsVacant  = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END

FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant  = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END


-- Removing Duplicates--
WITH RowNumCTE As(
SELECT * ,
	ROW_Number () OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num


FROM SQLProject..NashvilleHousing
ORDER BY ParcelID
)
SELECT* 
FROM RowNumCTE
WHERE row_num >1 
ORDER BY PropertyAddress



--- DELETE Columns -- ( Used for accidently created columns) 

SELECT* 
FROM SQLProject..NashvilleHousing

ALTER TABLE  SQLProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress , SaleDate
