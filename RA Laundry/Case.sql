--CASE

USE RALaundry

EXEC sp_msforeachtable "SELECT * FROM ?"


--1
SELECT  
	c.CustomerID, 
	c.CustomerName,
	[TotalTransactionPrice] = SUM(ServicePrice)
FROM MsCustomer c, TrService ts, DetailService ds
WHERE c.CustomerID=ts.CustomerId AND 
	ts.ServiceID= ds.ServiceID AND 
	DATENAME(MONTH,ServiceDate)='July' AND 
	c.CustomerGender LIKE 'Male'
GROUP BY c.CustomerID, c.CustomerName


--2
SELECT
	StaffName,
	PurchaseDate,
	[TotalTransaction]
FROM MsStaff ms, (
	SELECT 
		StaffID,
		PurchaseDate,
		[TotalTransaction]=COUNT(PurchaseID)
	FROM TrPurchase
	GROUP BY StaffID,PurchaseDate
) AS tp
WHERE ms.StaffID=tp.StaffID AND
	TotalTransaction > 1 AND
	StaffName LIKE '%o%'


--3
SELECT
	VendorName,
	[PurchaseDate]=CONVERT(VARCHAR,PurchaseDate,107),
	[TotalTransaction] = COUNT(tr.PurchaseID),
	[TotalPurchasePrice] = SUM(PurchaseQty*MaterialPrice)
FROM MsVendor mv JOIN TrPurchase tr
	ON mv.VendorID =tr.VendorID JOIN DetailPurchase dp 
	ON tr.PurchaseID = dp.PurchaseID JOIN MsMaterial mm
	ON mm.MaterialID = dp.MaterialID
WHERE VendorName LIKE 'PT.%' AND
	DATENAME(DAY,PurchaseDate) % 2 !=0
GROUP BY VendorName, [PurchaseDate]


--4
SELECT
	StaffName,
	MaterialName,
	[TotalTransaction] = COUNT(tp.PurchaseID),
	[TotalQuantity] =CAST([TotalQuantity] AS VARCHAR) + ' pcs'
FROM MsStaff ms JOIN TrPurchase tp
	ON ms.StaffID = tp.StaffID JOIN 
	(
		SELECT 
			PurchaseID,
			MaterialID,
			[TotalQuantity]= SUM(PurchaseQty)
		FROM DetailPurchase
		GROUP BY PurchaseID, MaterialID
	) AS dp
	ON tp.PurchaseID = dp.PurchaseID JOIN MsMaterial mm
	ON dp.MaterialID = mm.MaterialID
WHERE DATENAME(MONTH,PurchaseDate) = 'July' AND
	[TotalQuantity] < 9
GROUP BY StaffName, MaterialName, [TotalQuantity] 

--atau--
SELECT
	StaffName,
	MaterialName,
	[TotalTransaction] = COUNT(tp.PurchaseID),
	[TotalQuantity] =CAST(SUM(PurchaseQty) AS VARCHAR) + ' pcs'
FROM MsStaff ms JOIN TrPurchase tp
	ON ms.StaffID = tp.StaffID JOIN DetailPurchase dp
	ON tp.PurchaseID = dp.PurchaseID JOIN MsMaterial mm
	ON mm.MaterialID = dp.MaterialID
WHERE DATENAME(MONTH,PurchaseDate) = 'July'
GROUP BY StaffName, MaterialName
HAVING SUM(PurchaseQty) <9


--5 
SELECT
	[MaterialID]= REPLACE(mm.MaterialID,'MA','Material '),
	--[MaterialID] = STUFF(MaterialID,1,2,'Material '),
	[MaterialName]= UPPER(MaterialName),
	PurchaseDate,
	[Quantity] = PurchaseQty
FROM TrPurchase tp, DetailPurchase dp, MsMaterial mm, (
		SELECT [Average] = AVG(PurchaseQty)
		FROM DetailPurchase
	) AS av
WHERE 
	tp.PurchaseID=dp.PurchaseID AND
	dp.MaterialID = mm.MaterialID AND
	MaterialType = 'Supplies' AND
	PurchaseQty > Average
ORDER BY MaterialID ASC


--6
SELECT
	StaffName,
	CustomerName,
	[ServiceDate] = CONVERT(VARCHAR,ServiceDate,106)
FROM MsCustomer mc, TrService ts,(
	SELECT StaffID, StaffName, StaffSalary
	FROM MsStaff
	WHERE CHARINDEX(' ', StaffName)=0
) AS ms
WHERE 
	ms.StaffID = ts.StaffID AND
	ts.CustomerID = mc.CustomerID AND
	StaffSalary > (
	SELECT [AvgSalary] = AVG(StaffSalary)
	FROM MsStaff
	)


--7
SELECT 
	ClothesName,
	[TotalTransaction] = CAST([TotalTransactions] AS VARCHAR) + ' transaction',
	[ServiceType],
	ServicePrice
FROM (
	SELECT 
		ClothesID,
		[TotalTransactions]=COUNT(ts.ServiceID),
		[ServiceType] = SUBSTRING(ServiceType,1,CHARINDEX(' ',ServiceType)-1),
		ServicePrice
	FROM TrService ts JOIN DetailService ds
		ON ts.ServiceID = ds.ServiceID
	GROUP BY ClothesID, [ServiceType], ServicePrice
) AS ds, MsClothes mc 
WHERE 
	ds.ClothesID = mc.ClothesID AND
	ServicePrice < (
		SELECT [AveragePrice] = AVG(ServicePrice)
		FROM DetailService
	) AND
	ClothesType LIKE 'Cotton'


--8
SELECT 
	[StaffFirstName]=SUBSTRING(StaffName,1,CHARINDEX(' ',StaffName)-1),
	VendorName,
	--[VendorPhoneNumber]= REPLACE(VendorPhoneNumber,'08','+628'),
	--[VendorPhoneNumber]= STUFF(VendorPhoneNumber,1,2,'+628'),
	[VendorPhoneNumber]= '+628' + SUBSTRING(VendorPhoneNumber,3,LEN(VendorPhoneNumber)),
	[TotalTransaction] = COUNT(tp.PurchaseID)
FROM MsVendor mv, TrPurchase tp, DetailPurchase dp,
(
	SELECT *
	FROM MsStaff
	WHERE StaffName LIKE '% %' 
	--AND StaffName NOT LIKE '% % %'
) AS ms
WHERE 
	ms.StaffID = tp.StaffID AND
	tp.VendorID = mv.VendorID AND
	dp.PurchaseID = tp.PurchaseID AND
	PurchaseQty > (
		SELECT [Average] = AVG(PurchaseQty) 
		FROM DetailPurchase
	)
GROUP BY StaffName, VendorName, VendorPhoneNumber

--9
--ALTER VIEW ViewMaterialPurchase
CREATE VIEW ViewMaterialPurchase
AS 
SELECT
	MaterialName,
	[MaterialPrice] = 'Rp. ' + CAST(CAST(CAST(MaterialPrice AS INT)AS SMALLMONEY)AS VARCHAR),
	[TotalTransaction],
	[TotalPrice]
FROM  MsMaterial mm,
(
	SELECT
		dp.MaterialID,
		[TotalTransaction] = COUNT (PurchaseID),
		[TotalPrice] = SUM(PurchaseQty*MaterialPrice)
	FROM DetailPurchase dp JOIN MsMaterial mm ON dp.MaterialID = mm.MaterialID
	GROUP BY dp.MaterialID
) as dp
WHERE 
	dp.MaterialID = mm.MaterialID AND
	MaterialType LIKE 'Supplies' AND
	[TotalTransaction] >2

DROP VIEW ViewMaterialPurchase

SELECT * FROM ViewMaterialPurchase


--10
--ALTER VIEW ViewMaleCustomerTransaction
CREATE VIEW ViewMaleCustomerTransaction
AS
SELECT
	--ts.ServiceID,
	CustomerName,
	ClothesName,
	[TotalTransaction]= COUNT(ts.ServiceID),
	[TotalPrice] = SUM(ServicePrice)
FROM MsCustomer mcu, MsClothes mcl, TrService ts, 
(
	SELECT 
		ServiceID,
		ClothesID,
		ServicePrice
	FROM DetailService
) AS ds
WHERE 
	mcu.CustomerID = ts.CustomerID AND
	ts.ServiceID = ds.ServiceID AND
	ds.ClothesID = mcl.ClothesID AND
	CustomerGender LIKE 'Male' AND
	ClothesType IN ('Wool','Linen')
GROUP BY CustomerName, ClothesName

SELECT * FROM ViewMaleCustomerTransaction

DROP VIEW ViewMaleCustomerTransaction