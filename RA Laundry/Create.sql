CREATE DATABASE RALaundry

USE RALaundry

CREATE TABLE MsStaff(
	StaffID VARCHAR(5) PRIMARY KEY NOT NULL CHECK(StaffID LIKE'ST[0-9][0-9][0-9]'),
	StaffName VARCHAR(50),
	StaffGender VARCHAR(10) CHECK(StaffGender IN('Male','Female')),
	StaffAddress VARCHAR(100),
	StaffSalary NUMERIC(9,2) CHECK(StaffSalary BETWEEN 1500000.00 AND 3000000.00)
)

CREATE TABLE MsCustomer(
	CustomerID VARCHAR(5) PRIMARY KEY NOT NULL CHECK(CustomerID LIKE'CU[0-9][0-9][0-9]'),
	CustomerName VARCHAR(50),
	CustomerGender VARCHAR(10) CHECK(CustomerGender IN ('Male','Female')),
	CustomerAddress VARCHAR(100),
	CustomerDOB DATE
)

CREATE TABLE MsMaterial(
	MaterialID VARCHAR(5) PRIMARY KEY NOT NULL CHECK(MaterialID LIKE'MA[0-9][0-9][0-9]'),
	MaterialName VARCHAR(50),
	MaterialType VARCHAR(20)CHECK(MaterialType IN('Equipment','Supplies')),
	MaterialPrice NUMERIC(10,2)
)

CREATE TABLE MsVendor(
	VendorID VARCHAR(5) PRIMARY KEY NOT NULL CHECK(VendorID LIKE'VE[0-9][0-9][0-9]'),
	VendorName VARCHAR(50),
	VendorAddress VARCHAR(100) CHECK(LEN(VendorAddress)>10),
	VendorPhoneNumber VARCHAR(15)
)

CREATE TABLE MsClothes(
	ClothesID VARCHAR(5) PRIMARY KEY NOT NULL CHECK(ClothesID LIKE'CL[0-9][0-9][0-9]'),
	ClothesName VARCHAR(50),
	ClothesType VARCHAR(20)CHECK(ClothesType IN('Cotton', 'Viscose', 'Polyester', 'Linen', 'Wool'))	
)

CREATE TABLE TrPurchase(
	PurchaseID VARCHAR(5) PRIMARY KEY NOT NULL CHECK(PurchaseID LIKE('PU[0-9][0-9][0-9]')),
	StaffID VARCHAR(5) FOREIGN KEY REFERENCES MsStaff(StaffID) ON UPDATE CASCADE ON DELETE CASCADE,
	VendorID VARCHAR(5) FOREIGN KEY REFERENCES MsVendor(VendorID),
	PurchaseDate DATE CHECK ( YEAR(PurchaseDate) = YEAR(GETDATE()))
)

CREATE TABLE DetailPurchase(
	PurchaseID VARCHAR(5) FOREIGN KEY REFERENCES TrPurchase(PurchaseID),
	MaterialID VARCHAR(5) FOREIGN KEY REFERENCES MsMaterial(MaterialID),
	PurchaseQty INT,
	PRIMARY KEY(PurchaseID,MaterialID)
)

CREATE TABLE TrService(
	ServiceID VARCHAR(5) PRIMARY KEY NOT NULL CHECK(ServiceID LIKE 'SR[0-9][0-9][0-9]'),
	StaffID VARCHAR(5) FOREIGN KEY REFERENCES MsStaff(StaffID) ON UPDATE CASCADE ON DELETE CASCADE,
	CustomerID VARCHAR(5) FOREIGN KEY REFERENCES MsCustomer(CustomerID) ON UPDATE CASCADE ON DELETE CASCADE ,
	ServiceDate DATE CHECK ( YEAR(ServiceDate) = YEAR(GETDATE())),
	ServiceType VARCHAR(20) CHECK (ServiceType IN('Laundry Service', 'Dry Cleaning Service', 'Ironing Service'))
)

CREATE TABLE DetailService(
	ServiceID VARCHAR(5) FOREIGN KEY REFERENCES TrService(ServiceID) ,
	ClothesID VARCHAR(5) FOREIGN KEY REFERENCES MsClothes(ClothesID),
	ServicePrice NUMERIC (8,2),
	PRIMARY KEY(ServiceID,ClothesID)
)

EXEC sp_MSforeachtable @command1 = "DROP TABLE ?"
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"