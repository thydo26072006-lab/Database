-- TASK A: Thuc don, danh muc, ban va khuyen mai
-- SQL Server 2016+ / SSMS. Ban demo doc lap. Chay tren database moi.
-- Phien ban rut gon theo noi dung BTL2: khong thay the core SQL cua nhom.
IF DB_ID(N'coffee_pos_task_a') IS NULL EXEC(N'CREATE DATABASE coffee_pos_task_a');
GO
USE coffee_pos_task_a;
GO
CREATE TABLE KHU_VUC (
 MaKhuVuc NVARCHAR(30) NOT NULL PRIMARY KEY,
 TenKhuVuc NVARCHAR(150) NOT NULL
);
CREATE TABLE BAN (
 MaBan NVARCHAR(30) NOT NULL PRIMARY KEY,
 MaKhuVuc NVARCHAR(30) NOT NULL REFERENCES KHU_VUC(MaKhuVuc),
 TenBan NVARCHAR(100) NOT NULL,
 SoGhe INT NOT NULL CHECK(SoGhe>0),
 TrangThaiHoatDong NVARCHAR(20) NOT NULL DEFAULT N'HoatDong'
 CHECK(TrangThaiHoatDong IN (N'HoatDong',N'TamNgung'))
);
CREATE TABLE DANH_MUC_MON (
 MaDanhMuc NVARCHAR(30) NOT NULL PRIMARY KEY,
 MaDanhMucCha NVARCHAR(30) NULL REFERENCES DANH_MUC_MON(MaDanhMuc),
 TenDanhMuc NVARCHAR(150) NOT NULL
);
CREATE TABLE MON (
 MaMon NVARCHAR(30) NOT NULL PRIMARY KEY,
 MaDanhMuc NVARCHAR(30) NOT NULL REFERENCES DANH_MUC_MON(MaDanhMuc),
 TenMon NVARCHAR(150) NOT NULL,
 TrangThaiKinhDoanh NVARCHAR(20) NOT NULL DEFAULT N'DangBan'
 CHECK(TrangThaiKinhDoanh IN (N'DangBan',N'NgungBan'))
);
CREATE TABLE SIZE_MON (
 MaMon NVARCHAR(30) NOT NULL REFERENCES MON(MaMon),
 MaSize CHAR(1) NOT NULL CHECK(MaSize IN ('S','M','L')),
 TenSize NVARCHAR(50) NOT NULL,
 GiaBan DECIMAL(18,2) NOT NULL CHECK(GiaBan>=0),
 TrangThaiSize NVARCHAR(20) NOT NULL DEFAULT N'DangBan'
 CHECK(TrangThaiSize IN (N'DangBan',N'NgungBan')),
 CONSTRAINT PK_SIZE_MON PRIMARY KEY(MaMon,MaSize)
);
CREATE TABLE DON_HANG (
 MaDonHang NVARCHAR(30) NOT NULL PRIMARY KEY,
 MaBan NVARCHAR(30) NOT NULL REFERENCES BAN(MaBan),
 TrangThaiDonHang NVARCHAR(20) NOT NULL
 CHECK(TrangThaiDonHang IN (N'DangPhucVu',N'DaThanhToan',N'DaHuy'))
);
CREATE TABLE KHUYEN_MAI (
 MaKM NVARCHAR(30) NOT NULL PRIMARY KEY,
 TenKM NVARCHAR(150) NOT NULL,
 BatDau DATETIME2(0) NOT NULL,
 KetThuc DATETIME2(0) NOT NULL,
 HinhThuc NVARCHAR(20) NOT NULL CHECK(HinhThuc IN (N'GiamDon',N'GiamMon',N'MuaTang')),
 KichHoat BIT NOT NULL DEFAULT 0,
 ChiApDungThanhVien BIT NOT NULL DEFAULT 0,
 TuDongApDung BIT NOT NULL DEFAULT 0,
 NganSachToiDa DECIMAL(18,2) NULL CHECK(NganSachToiDa>0),
 SoLanToiDaMoiKhach INT NULL CHECK(SoLanToiDaMoiKhach>0),
 ThuTuUuTien INT NOT NULL DEFAULT 0 CHECK(ThuTuUuTien>=0),
 CHECK(BatDau<KetThuc)
);
CREATE TABLE DIEU_KIEN_KM (
 MaKM NVARCHAR(30) NOT NULL REFERENCES KHUYEN_MAI(MaKM),
 STTDieuKien INT NOT NULL CHECK(STTDieuKien>0),
 NguongTienDon DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK(NguongTienDon>=0),
 SoLuongMuaToiThieu INT NOT NULL DEFAULT 0 CHECK(SoLuongMuaToiThieu>=0),
 KieuUuDai NVARCHAR(30) NOT NULL CHECK(KieuUuDai IN (N'GiamTien',N'GiamPhanTram',N'DongGia',N'TangMon')),
 GiaTriUuDai DECIMAL(18,2) NULL CHECK(GiaTriUuDai>=0),
 TienGiamToiDa DECIMAL(18,2) NULL CHECK(TienGiamToiDa>=0),
 SoLuongUuDaiToiDa INT NULL CHECK(SoLuongUuDaiToiDa>0),
 ThuTuUuTien INT NOT NULL DEFAULT 0,
 CONSTRAINT PK_DIEU_KIEN_KM PRIMARY KEY(MaKM,STTDieuKien)
);
CREATE TABLE KM_MON_MUA (
 MaKM NVARCHAR(30) NOT NULL, STTDieuKien INT NOT NULL,
 MaMon NVARCHAR(30) NOT NULL REFERENCES MON(MaMon),
 CONSTRAINT PK_KM_MON_MUA PRIMARY KEY(MaKM,STTDieuKien,MaMon),
 CONSTRAINT FK_MUA_DK FOREIGN KEY(MaKM,STTDieuKien) REFERENCES DIEU_KIEN_KM(MaKM,STTDieuKien)
);
CREATE TABLE KM_MON_NHAN (
 MaKM NVARCHAR(30) NOT NULL, STTDieuKien INT NOT NULL,
 MaMon NVARCHAR(30) NOT NULL REFERENCES MON(MaMon),
 CONSTRAINT PK_KM_MON_NHAN PRIMARY KEY(MaKM,STTDieuKien,MaMon),
 CONSTRAINT FK_NHAN_DK FOREIGN KEY(MaKM,STTDieuKien) REFERENCES DIEU_KIEN_KM(MaKM,STTDieuKien)
);
GO
CREATE INDEX IX_MON_DANHMUC_TRANGTHAI ON MON(MaDanhMuc,TrangThaiKinhDoanh);
CREATE INDEX IX_SIZE_MON_GIA ON SIZE_MON(TrangThaiSize,GiaBan);
CREATE INDEX IX_BAN_KHUVUC_HOATDONG ON BAN(MaKhuVuc,TrangThaiHoatDong);
CREATE INDEX IX_KM_HIEULUC ON KHUYEN_MAI(KichHoat,BatDau,KetThuc);
CREATE UNIQUE INDEX UX_DONHANG_MOT_DON_DANG_PHUC_VU ON DON_HANG(MaBan) WHERE TrangThaiDonHang=N'DangPhucVu';
GO
CREATE TYPE dbo.SizeInput AS TABLE(
 MaSize CHAR(1) PRIMARY KEY,
 GiaBan DECIMAL(18,2) NOT NULL,
 TrangThaiSize NVARCHAR(20) NOT NULL
);
GO
CREATE FUNCTION dbo.fn_GiaBanTu(@MaMon NVARCHAR(30)) RETURNS DECIMAL(18,2)
AS BEGIN
 DECLARE @Gia DECIMAL(18,2);
 SELECT @Gia=MIN(S.GiaBan) FROM MON M
 JOIN SIZE_MON S ON M.MaMon=S.MaMon
 WHERE M.MaMon=@MaMon AND M.TrangThaiKinhDoanh=N'DangBan' AND S.TrangThaiSize=N'DangBan';
 RETURN @Gia;
END;
GO
CREATE PROCEDURE dbo.sp_ThemMon
 @MaMon NVARCHAR(30),@MaDanhMuc NVARCHAR(30),@TenMon NVARCHAR(150),@DanhSachSize dbo.SizeInput READONLY
AS BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF NULLIF(LTRIM(RTRIM(@MaMon)),N'') IS NULL OR NULLIF(LTRIM(RTRIM(@TenMon)),N'') IS NULL
  THROW 51001,N'Ma mon va ten mon khong duoc de trong',1;
 IF (SELECT COUNT(*) FROM @DanhSachSize) NOT BETWEEN 1 AND 3
  THROW 51002,N'Moi mon phai co 1-3 size',1;
 IF EXISTS(SELECT 1 FROM @DanhSachSize
           WHERE MaSize NOT IN ('S','M','L') OR GiaBan<0 OR TrangThaiSize NOT IN (N'DangBan',N'NgungBan'))
  THROW 51003,N'Size hoac gia/trang thai khong hop le',1;
 BEGIN TRY
  BEGIN TRAN;
  INSERT MON(MaMon,MaDanhMuc,TenMon) VALUES(@MaMon,@MaDanhMuc,@TenMon);
  INSERT SIZE_MON(MaMon,MaSize,TenSize,GiaBan,TrangThaiSize)
  SELECT @MaMon,MaSize,CASE MaSize WHEN 'S' THEN N'Nho' WHEN 'M' THEN N'Vua' ELSE N'Lon' END,GiaBan,TrangThaiSize FROM @DanhSachSize;
  COMMIT;
 END TRY BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  THROW;
 END CATCH;
END;
GO
CREATE PROCEDURE dbo.sp_CapNhatGiaMon @MaMon NVARCHAR(30),@MaSize CHAR(1),@GiaMoi DECIMAL(18,2)
AS BEGIN
 SET NOCOUNT ON;
 IF @GiaMoi IS NULL OR @GiaMoi<0 THROW 51004,N'Gia moi khong hop le',1;
 UPDATE SIZE_MON SET GiaBan=@GiaMoi WHERE MaMon=@MaMon AND MaSize=@MaSize;
 IF @@ROWCOUNT=0 THROW 51005,N'Khong tim thay mon-size',1;
END;
GO
CREATE PROCEDURE dbo.sp_NgungBanMon @MaMon NVARCHAR(30),@MaSize CHAR(1)=NULL
AS BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRY
  BEGIN TRAN;
  IF NOT EXISTS(SELECT 1 FROM MON WITH(UPDLOCK,HOLDLOCK) WHERE MaMon=@MaMon)
   THROW 51006,N'Khong tim thay mon',1;
  IF @MaSize IS NULL BEGIN
   UPDATE MON SET TrangThaiKinhDoanh=N'NgungBan' WHERE MaMon=@MaMon;
   UPDATE SIZE_MON SET TrangThaiSize=N'NgungBan' WHERE MaMon=@MaMon;
  END ELSE BEGIN
   UPDATE SIZE_MON SET TrangThaiSize=N'NgungBan' WHERE MaMon=@MaMon AND MaSize=@MaSize;
   IF @@ROWCOUNT=0 THROW 51007,N'Khong tim thay mon-size',1;
   IF NOT EXISTS(SELECT 1 FROM SIZE_MON WHERE MaMon=@MaMon AND TrangThaiSize=N'DangBan')
    UPDATE MON SET TrangThaiKinhDoanh=N'NgungBan' WHERE MaMon=@MaMon;
  END;
  COMMIT;
 END TRY BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  THROW;
 END CATCH;
END;
GO
-- Chi danh gia uu dai DU KIEN: khong ghi AP_DUNG_KM, khong sinh qua tang.
CREATE PROCEDURE dbo.sp_TinhUuDaiDuKien
 @MaKM NVARCHAR(30),@STTDieuKien INT,@TongTienHang DECIMAL(18,2),
 @SoLuongMua INT=0,@GiaTriMonNhan DECIMAL(18,2)=NULL,@MocThoiGian DATETIME2(0)=NULL
AS BEGIN
 SET NOCOUNT ON;
 DECLARE @HopLe BIT=0,@TienGiam DECIMAL(18,2)=0,@LyDo NVARCHAR(200)=N'',
 @HinhThuc NVARCHAR(30),@Kieu NVARCHAR(30),@Nguong DECIMAL(18,2),
 @MinSL INT,@GiaTri DECIMAL(18,2),@Tran DECIMAL(18,2),@CoSo DECIMAL(18,2);
 SET @MocThoiGian=COALESCE(@MocThoiGian,SYSDATETIME());
 IF @TongTienHang IS NULL OR @TongTienHang<0 OR @SoLuongMua IS NULL OR @SoLuongMua<0 BEGIN
  SELECT CONVERT(BIT,0) AS HopLe,CONVERT(DECIMAL(18,2),0) AS TienGiam,N'Dau vao khong hop le' AS LyDo; RETURN;
 END;
 SELECT @HinhThuc=K.HinhThuc,@Kieu=D.KieuUuDai,@Nguong=D.NguongTienDon,
 @MinSL=D.SoLuongMuaToiThieu,@GiaTri=D.GiaTriUuDai,@Tran=D.TienGiamToiDa
 FROM KHUYEN_MAI K JOIN DIEU_KIEN_KM D ON K.MaKM=D.MaKM
 WHERE K.MaKM=@MaKM AND D.STTDieuKien=@STTDieuKien AND K.KichHoat=1
 AND @MocThoiGian>=K.BatDau AND @MocThoiGian<K.KetThuc;
 IF @HinhThuc IS NULL SET @LyDo=N'KM khong ton tai, chua kich hoat hoac het han';
 ELSE IF @TongTienHang<@Nguong OR @SoLuongMua<@MinSL SET @LyDo=N'Chua dat nguong';
 ELSE IF (@HinhThuc=N'GiamDon' AND @Kieu NOT IN (N'GiamTien',N'GiamPhanTram'))
      OR (@HinhThuc=N'GiamMon' AND @Kieu NOT IN (N'GiamTien',N'GiamPhanTram',N'DongGia'))
      OR (@HinhThuc=N'MuaTang' AND @Kieu<>N'TangMon') SET @LyDo=N'Khong tuong thich';
 ELSE IF @HinhThuc=N'MuaTang' SET @LyDo=N'Can danh sach mon mua/nhan thuc te de xet qua tang';
 ELSE IF @HinhThuc=N'GiamMon' AND (@GiaTriMonNhan IS NULL OR @GiaTriMonNhan<0)
  SET @LyDo=N'Thieu gia tri mon nhan';
 ELSE IF @GiaTri IS NULL SET @LyDo=N'Thieu gia tri uu dai';
 ELSE IF @Kieu=N'GiamPhanTram' AND @GiaTri>100 SET @LyDo=N'Ty le vuot 100 phan tram';
 ELSE BEGIN
  SET @CoSo=CASE WHEN @HinhThuc=N'GiamDon' THEN @TongTienHang ELSE @GiaTriMonNhan END;
  SET @TienGiam=CASE @Kieu WHEN N'GiamTien' THEN @GiaTri
   WHEN N'GiamPhanTram' THEN ROUND(@CoSo*@GiaTri/100,2)
   WHEN N'DongGia' THEN CASE WHEN @CoSo>@GiaTri THEN @CoSo-@GiaTri ELSE 0 END ELSE 0 END;
  IF @TienGiam>@CoSo SET @TienGiam=@CoSo;
  IF @Tran IS NOT NULL AND @TienGiam>@Tran SET @TienGiam=@Tran;
  SET @HopLe=1; SET @LyDo=N'Hop le theo dau vao demo';
 END;
 SELECT @HopLe AS HopLe,@TienGiam AS TienGiam,@LyDo AS LyDo;
END;
GO
INSERT KHU_VUC VALUES(N'KV01',N'Tang tret'),(N'KV02',N'Tang lau');
INSERT BAN VALUES
(N'B01',N'KV01',N'Ban 01',4,N'HoatDong'),
(N'B02',N'KV01',N'Ban 02',4,N'HoatDong'),
(N'B03',N'KV02',N'Ban 03',2,N'TamNgung'),
(N'B04',N'KV02',N'Ban 04',6,N'HoatDong');
INSERT DANH_MUC_MON VALUES(N'DM01',NULL,N'Tra sua'),(N'DM02',NULL,N'Ca phe');
INSERT MON VALUES
(N'M01',N'DM01',N'Tra sua truyen thong',N'DangBan'),
(N'M02',N'DM01',N'Tra sua matcha',N'DangBan'),
(N'M03',N'DM02',N'Ca phe sua',N'DangBan'),
(N'M04',N'DM02',N'Ca phe da',N'NgungBan');
INSERT SIZE_MON VALUES
(N'M01','S',N'Nho',25000,N'DangBan'),(N'M01','M',N'Vua',30000,N'DangBan'),(N'M01','L',N'Lon',35000,N'DangBan'),
(N'M02','S',N'Nho',27000,N'DangBan'),(N'M02','M',N'Vua',32000,N'DangBan'),(N'M02','L',N'Lon',37000,N'NgungBan'),
(N'M03','S',N'Nho',23000,N'DangBan'),(N'M03','M',N'Vua',29000,N'DangBan'),
(N'M04','S',N'Nho',22000,N'NgungBan');
INSERT DON_HANG VALUES(N'DH01',N'B02',N'DangPhucVu');
INSERT KHUYEN_MAI(MaKM,TenKM,BatDau,KetThuc,HinhThuc,KichHoat) VALUES
(N'KM01',N'Giam don','2026-10-01','2026-12-01',N'GiamDon',1),
(N'KM02',N'Giam mon','2026-10-01','2026-12-01',N'GiamMon',1),
(N'KM03',N'Mua tang','2026-10-01','2026-12-01',N'MuaTang',0);
INSERT DIEU_KIEN_KM(MaKM,STTDieuKien,NguongTienDon,SoLuongMuaToiThieu,KieuUuDai,GiaTriUuDai,TienGiamToiDa,SoLuongUuDaiToiDa) VALUES
(N'KM01',1,100000,0,N'GiamTien',15000,NULL,NULL),
(N'KM02',1,0,0,N'GiamPhanTram',20,10000,2),
(N'KM03',1,0,2,N'TangMon',NULL,NULL,1);
INSERT KM_MON_MUA VALUES(N'KM03',1,N'M01');
INSERT KM_MON_NHAN VALUES(N'KM02',1,N'M01'),(N'KM02',1,N'M02'),(N'KM03',1,N'M03');
GO
-- Q1. Thuc don, size, gia, GiaBanTu
SELECT D.TenDanhMuc,M.MaMon,M.TenMon,S.MaSize,S.GiaBan,dbo.fn_GiaBanTu(M.MaMon) AS GiaBanTu,
M.TrangThaiKinhDoanh,S.TrangThaiSize
FROM DANH_MUC_MON D JOIN MON M ON M.MaDanhMuc=D.MaDanhMuc
JOIN SIZE_MON S ON M.MaMon=S.MaMon ORDER BY D.MaDanhMuc,M.MaMon,S.MaSize;
-- Q2. Mon va size dang ban trong khoang gia
SELECT M.MaMon,M.TenMon,S.MaSize,S.GiaBan
FROM MON M JOIN SIZE_MON S ON M.MaMon=S.MaMon
WHERE M.TrangThaiKinhDoanh=N'DangBan' AND S.TrangThaiSize=N'DangBan'
AND S.GiaBan BETWEEN 25000 AND 35000 ORDER BY M.MaMon,S.MaSize;
-- Q3. Trang thai ban duoc suy ra
SELECT B.MaBan,B.TrangThaiHoatDong,
CASE WHEN EXISTS(SELECT 1 FROM DON_HANG D WHERE D.MaBan=B.MaBan AND D.TrangThaiDonHang=N'DangPhucVu')
THEN N'DangPhucVu' ELSE N'Trong' END AS TrangThaiBan FROM BAN B ORDER BY B.MaBan;
-- Q4. Ban co the tiep nhan khach
SELECT B.MaBan,B.TenBan FROM BAN B
WHERE B.TrangThaiHoatDong=N'HoatDong' AND NOT EXISTS
(SELECT 1 FROM DON_HANG D WHERE D.MaBan=B.MaBan AND D.TrangThaiDonHang=N'DangPhucVu')
ORDER BY B.MaBan;
-- Q5. Chuong trinh KM dang kich hoat va con hieu luc
DECLARE @MocDemo DATETIME2(0)='2026-11-01';
SELECT K.MaKM,K.TenKM,D.STTDieuKien,D.KieuUuDai,D.NguongTienDon,D.GiaTriUuDai
FROM KHUYEN_MAI K JOIN DIEU_KIEN_KM D ON D.MaKM=K.MaKM
WHERE K.KichHoat=1 AND @MocDemo>=K.BatDau AND @MocDemo<K.KetThuc
ORDER BY K.MaKM,D.STTDieuKien;
GO
-- T1 - T10: phan demo (run only once on fresh DB)
DECLARE @S1 dbo.SizeInput;
INSERT @S1 VALUES('S',22000,N'DangBan');
EXEC dbo.sp_ThemMon N'M05',N'DM01',N'Tra dao',@S1;
GO
DECLARE @S2 dbo.SizeInput;
INSERT @S2 VALUES('S',27000,N'DangBan'),('M',32000,N'DangBan'),('L',37000,N'DangBan');
EXEC dbo.sp_ThemMon N'M06',N'DM02',N'Ca phe muoi',@S2;
GO
EXEC dbo.sp_CapNhatGiaMon N'M01','M',33000;
SELECT dbo.fn_GiaBanTu(N'M01') AS GiaBanTu_M01;
EXEC dbo.sp_NgungBanMon N'M02','L';
SELECT MaSize,TrangThaiSize FROM SIZE_MON WHERE MaMon=N'M02';
EXEC dbo.sp_TinhUuDaiDuKien N'KM01',1,150000,0,NULL,'2026-11-01';
EXEC dbo.sp_TinhUuDaiDuKien N'KM01',1,60000,0,NULL,'2026-11-01';
EXEC dbo.sp_TinhUuDaiDuKien N'KM02',1,70000,2,50000,'2026-11-01';
EXEC dbo.sp_TinhUuDaiDuKien N'KM03',1,100000,2,35000,'2026-11-01';
GO
DECLARE @Empty dbo.SizeInput;
BEGIN TRY EXEC dbo.sp_ThemMon N'M07',N'DM01',N'Test rong',@Empty;
END TRY BEGIN CATCH SELECT ERROR_MESSAGE() AS LoiDuKien_DanhSachSizeRong; END CATCH;
BEGIN TRY INSERT SIZE_MON VALUES(N'M01','T',N'Tieu chuan',10000,N'DangBan');
END TRY BEGIN CATCH SELECT ERROR_MESSAGE() AS LoiDuKien_SizeSai; END CATCH;
GO
