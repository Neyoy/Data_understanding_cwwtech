--CLEANING DATA IN SQL

SELECT *
FROM NashvilleHousing


--Standadize date format

ALTER Table NashvilleHousing
alter column SaleDate date


UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)


--Populate property address data

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
  ON A.ParcelID = B.ParcelID
  AND A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress IS NULL 

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
  ON A.ParcelID = B.ParcelID
  AND A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress IS NULL 


--Breaking out address into individual column(address,city,state)

SELECT PropertyAddress
FROM NashvilleHousing


SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS Address
FROM NashvilleHousing


ALTER Table NashvilleHousing
Add ProperySplitAddress Nvarchar(255);

 UPDATE NashvilleHousing
SET ProperySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER Table NashvilleHousing
Add ProperySplitcity Nvarchar(255);

 UPDATE NashvilleHousing
SET ProperySplitcity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) 


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Varchar(255);  

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Varchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Varchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)





--Change N and Y to No and Yes in "Sold As Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) 
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 



--Remove duplicate

With RowNumCTE AS (
SELECT *,
       ROW_NUMBER() OVER (
       PARTITION BY  ParcelID,
	                 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
	   ORDER BY UniqueID
	   ) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



--Delete unuse Column

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate,OwnerAddress


