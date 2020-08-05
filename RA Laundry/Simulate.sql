USE RALaundry

--SIMULASI TRANSAKSI

--1. Transaksi Service (Customer menggunakan jasa cuci pakaian)

--KASUS 1

--Ada seorang pelanggan tetap bernama Ria Natalia.
--Dia ingin mencuci beberapa pakaiannya yang diantaranya rok linen cl005 dan cardigan polyester cl015. 
--Jasa cuci yang ingin dia gunakan adalah Laundry Service.
--Seorang staff bernama Anto Lubis menerima barang pelanggan dan memproses barang tersebut ke dalam sistem.
--Anto perlu mengambil data pelanggan tersebut.

SELECT * FROM MsCustomer WHERE CustomerName LIKE 'Ria Natalia'

--Setelah itu, Anto membuat struk pembayaran yang didalamnya terdapat beberapa informasi penting dan sebagai surat pengambilan barang.
--Di dalam struk tersebut tertulis nomor struk, nama staff yang bertanggung jawab, nama pelanggan, tanggal cetak struk, jasa cuci yang diinginkan, harga yang ditentukan oleh staff, dan jenis baju

INSERT INTO TrService VALUES ('SR017','ST002','CU009','2019-12-15','Laundry Service')
INSERT INTO DetailService VALUES ('SR017','CL005',25000.00),('SR017','CL015',30000.00)





--KASUS 2
--Di hari yang sama, ada seorang pelanggan baru bernama Thania Lesmana ingin menggunakan jasa dry cleaning dengan kode CL003, CL007, CL009, dan sebuah jaket berbahan katun yang belum terdaftar dalam sistem.
--Seorang staff bernama Sinta(ST001) menerima barang pelanggan dan memproses barang tersebut ke dalam sistem.
--Karena Thania Lesmana merupakan pelanggan baru, maka Sinta meminta beberapa data pribadi untuk dimasukkan ke dalam sistem.

INSERT INTO MsCustomer VALUES ('CU016', 'Thania Lesmana', 'Female', 'Jl. K.H. Syahdan No. 14', '1997-09-15')

-- setelah memasukkan data pelanggan, Sinta memasukan informasi mengenai jaket
INSERT INTO MsClothes (ClothesID,ClothesType,ClothesName) VALUES ('CL022', 'Cotton', 'Jaket')

-- lalu dibuatlah sebuah struk pembayaran
INSERT INTO TrService VALUES ('SR018','ST001','CU016','2019-12-15','Dry Cleaning Service')
INSERT INTO DetailService VALUES ('SR018','CL003',30000.00),('SR018','CL007',20000.00),('SR018','CL009',23000.00)




--KASUS 3
--Ada seorang pelanggan tetap bernama Peter(CU011).
--Dia ingin mencuci beberapa pakaiannya dengan kode : CL020, CL011, CL012, CL014. 
--Jasa cuci yang ingin dia gunakan adalah Ironing Service.
--Peter ingin hasil cuciannya dikirimkan ke tempat tinggal barunya di Jl. Rawa Belong No. 10 yang sebelumnya tidak tersimpan dalam sistem RALaundry
--Seorang staff bernama Helena Fransiska (ST010) menerima barang pelanggan dan memproses barang tersebut ke dalam sistem.
--Anto perlu mengambil data pelanggan tersebut dan melakukan perubahan pada bagian alamat pelanggan.

SELECT * FROM MsCustomer WHERE CustomerName LIKE 'Peter'

UPDATE MsCustomer
SET CustomerAddress = 'Jl. Rawa Belong No. 10'
WHERE CustomerName LIKE 'Peter'

-- pembuatan struk
INSERT INTO TrService VALUES ('SR019','ST010','CU011','2019-12-16','Ironing Service')
INSERT INTO DetailService VALUES ('SR019','CL020',20000.00),('SR019','CL011',15000.00),('SR019','CL012',23000.00),('SR019','CL014',10000.00)







--2. Transaksi Purchase (Stok alat dan bahan)

--KASUS 1
--Ada vendor baru (VE011) dengan nama PT. Setia Selalu yang beralamat di Jl. Penggangsaan Timur No. 10 dan no telp 08123452345 menawarkan penjualan barang detergen, pemutih pakaian, dan pewangi pakaian dengan harga terjangkau
INSERT INTO MsVendor VALUES ('VE011', 'PT. Setia Selalu', 'Jl. Penggangsaan Timur No. 10', '08123452345')

--Staff ST003 melakukan sedikit pembelian untuk mencoba apakah barang milik vendor tersebut bagus
INSERT INTO TrPurchase VALUES('PU017','ST003','VE011','2019-12-10')
INSERT INTO DetailPurchase VALUES ('PU017','MA004',1),('PU017','MA005',2),('PU017','MA008',2)




--KASUS 2
-- staff ST007 membeli plastik packing 100 pcs melalui vendor langganan yang terkenal, dengan kode vendor VE006 seperti yang terdaftar dalam sistem.
SELECT * FROM MsVendor WHERE VendorID LIKE'VE006'

INSERT INTO TrPurchase VALUES ('PU018','ST007','VE006','2019-12-08')
INSERT INTO DetailPurchase VALUES ('PU018','MA009',100)

-- namun ternyata vendor tersebut tidak menjual plastik, sehingga data transaksi harus dibuang dan dibuat kembali untuk membeli pada vendor VE002
DELETE FROM DetailPurchase
WHERE PurchaseID LIKE 'PU018'

DELETE FROM TrPurchase
WHERE PurchaseID LIKE 'PU018'

INSERT INTO TrPurchase VALUES ('PU018','ST007','VE002','2019-12-08')
INSERT INTO DetailPurchase VALUES ('PU018','MA009',100)




--KASUS 3
-- Staff ST010 membeli sebuah mesin cuci karena kebutuhan laundry yang semakin meningkat.
-- Ia membeli mesin tersebut melalui vendor VE006 yang ternyata sudah berganti no telp ke no. 0898768756
-- Agar staff lain tidak kesulitan, maka staff ST010 melakukan perubahan pada data VE006

UPDATE MsVendor
SET VendorPhoneNumber = 0898768756
WHERE VendorID LIKE 'VE006'

--Staff tersebut pun memesan mesin cuci melalui vendor tersebut. PEmbelian yang dilakukan oleh staff akan masuk ke dalam pembukuan
SELECT * FROM MsVendor WHERE VendorID LIKE'VE006'

INSERT INTO TrPurchase VALUES ('PU019','ST007','VE006','2019-12-18')
INSERT INTO DetailPurchase VALUES ('PU019','MA001',1)
