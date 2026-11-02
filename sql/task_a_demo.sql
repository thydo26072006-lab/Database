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


-- TASK 5: types and transaction-safe promotion creation + eligibility evaluation
CREATE TYPE dbo.KMMonInput AS TABLE (MaMon NVARCHAR(30) PRIMARY KEY);
GO
CREATE TYPE dbo.GioHangInput AS TABLE (
 MaMon NVARCHAR(30) NOT NULL,
 MaSize CHAR(1) NOT NULL,
 SoLuong INT NOT NULL CHECK (SoLuong>0),
 PRIMARY KEY(MaMon,MaSize)
);
GO
-- Creates a promotion and its one condition atomically.
-- Assumption: one rule per call, promotion can have further rules added separately.
CREATE PROCEDURE dbo.sp_TaoKhuyenMai
 @MaKM NVARCHAR(30), @TenKM NVARCHAR(150),
 @BatDau DATETIME2(0),@KetThuc DATETIME2(0),@HinhThuc NVARCHAR(20),
 @KieuUuDai NVARCHAR(30),@GiaTriUuDai DECIMAL(18,2)=NULL,
 @NguongTienDon DECIMAL(18,2)=0,@SoLuongMuaToiThieu INT=0,
 @TienGiamToiDa DECIMAL(18,2)=NULL,@SoLuongUuDaiToiDa INT=NULL,
 @ChiApDungThanhVien BIT=0,@TuDongApDung BIT=0,
 @NganSachToiDa DECIMAL(18,2)=NULL,@SoLanToiDaMoiKhach INT=NULL,
 @ThuTuUuTien INT=0,@KichHoat BIT=0,
 @MonMua dbo.KMMonInput READONLY,@MonNhan dbo.KMMonInput READONLY
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF NULLIF(LTRIM(RTRIM(@MaKM)),N'') IS NULL OR NULLIF(LTRIM(RTRIM(@TenKM)),N'') IS NULL
  THROW 51100,N'Ma va ten khuyen mai khong duoc trong',1;
 IF @BatDau IS NULL OR @KetThuc IS NULL OR @BatDau>=@KetThuc
  THROW 51101,N'Khoang thoi gian khong hop le',1;
 IF @HinhThuc NOT IN (N'GiamDon',N'GiamMon',N'MuaTang') OR @HinhThuc IS NULL
  THROW 51102,N'Hinh thuc khuyen mai khong hop le',1;
 IF (@HinhThuc=N'GiamDon' AND @KieuUuDai NOT IN (N'GiamTien',N'GiamPhanTram'))
 OR (@HinhThuc=N'GiamMon' AND @KieuUuDai NOT IN (N'GiamTien',N'GiamPhanTram',N'DongGia'))
 OR (@HinhThuc=N'MuaTang' AND @KieuUuDai<>N'TangMon') OR @KieuUuDai IS NULL
  THROW 51103,N'Hinh thuc va kieu uu dai khong tuong thich',1;
 IF @NguongTienDon IS NULL OR @NguongTienDon<0 OR @SoLuongMuaToiThieu IS NULL OR @SoLuongMuaToiThieu<0
  THROW 51104,N'Nguong tien/so luong mua khong hop le',1;
 IF @KieuUuDai=N'GiamPhanTram' AND (@GiaTriUuDai IS NULL OR @GiaTriUuDai>100 OR @GiaTriUuDai<=0)
  THROW 51105,N'Ty le giam phai trong (0,100]',1;
 IF @KieuUuDai IN (N'GiamTien',N'DongGia') AND (@GiaTriUuDai IS NULL OR @GiaTriUuDai<0)
  THROW 51106,N'Phai khai bao gia tri uu dai khong am',1;
 IF @KieuUuDai=N'TangMon' AND (@GiaTriUuDai IS NOT NULL OR @SoLuongMuaToiThieu<=0 OR @SoLuongUuDaiToiDa IS NULL)
  THROW 51107,N'Mua tang can so luong mua/nhan va khong dung gia tri giam',1;
 IF @TienGiamToiDa IS NOT NULL AND @TienGiamToiDa<0
  THROW 51108,N'Tran giam khong hop le',1;
 IF @SoLuongUuDaiToiDa IS NOT NULL AND @SoLuongUuDaiToiDa<=0
  THROW 51109,N'So luong uu dai toi da khong hop le',1;
 IF @NganSachToiDa IS NOT NULL AND @NganSachToiDa<=0
  THROW 51110,N'Ngan sach khong hop le',1;
 IF @SoLanToiDaMoiKhach IS NOT NULL AND @SoLanToiDaMoiKhach<=0
  THROW 51111,N'Gioi han moi khach khong hop le',1;
 IF @ThuTuUuTien IS NULL OR @ThuTuUuTien<0
  THROW 51112,N'Thu tu uu tien khong hop le',1;
 IF @HinhThuc=N'GiamDon' AND (EXISTS(SELECT 1 FROM @MonMua) OR EXISTS(SELECT 1 FROM @MonNhan))
  THROW 51113,N'Giam don khong can tap mon',1;
 IF @HinhThuc=N'GiamMon' AND NOT EXISTS(SELECT 1 FROM @MonNhan)
  THROW 51114,N'Giam mon can tap mon nhan',1;
 IF @HinhThuc=N'MuaTang' AND
    (NOT EXISTS(SELECT 1 FROM @MonMua) OR NOT EXISTS(SELECT 1 FROM @MonNhan))
  THROW 51115,N'Mua tang can tap mon mua va tap mon nhan',1;
 IF EXISTS(SELECT 1 FROM @MonMua X LEFT JOIN MON M ON M.MaMon=X.MaMon WHERE M.MaMon IS NULL)
 OR EXISTS(SELECT 1 FROM @MonNhan X LEFT JOIN MON M ON M.MaMon=X.MaMon WHERE M.MaMon IS NULL)
  THROW 51116,N'Tap mon chua mon khong ton tai',1;
 BEGIN TRY
  BEGIN TRAN;
  INSERT KHUYEN_MAI(MaKM,TenKM,BatDau,KetThuc,HinhThuc,KichHoat,ChiApDungThanhVien,
    TuDongApDung,NganSachToiDa,SoLanToiDaMoiKhach,ThuTuUuTien)
  VALUES(@MaKM,@TenKM,@BatDau,@KetThuc,@HinhThuc,@KichHoat,@ChiApDungThanhVien,
    @TuDongApDung,@NganSachToiDa,@SoLanToiDaMoiKhach,@ThuTuUuTien);
  INSERT DIEU_KIEN_KM(MaKM,STTDieuKien,NguongTienDon,SoLuongMuaToiThieu,KieuUuDai,
    GiaTriUuDai,TienGiamToiDa,SoLuongUuDaiToiDa,ThuTuUuTien)
  VALUES(@MaKM,1,@NguongTienDon,@SoLuongMuaToiThieu,@KieuUuDai,@GiaTriUuDai,
    @TienGiamToiDa,@SoLuongUuDaiToiDa,0);
  INSERT KM_MON_MUA SELECT @MaKM,1,MaMon FROM @MonMua;
  INSERT KM_MON_NHAN SELECT @MaKM,1,MaMon FROM @MonNhan;
  COMMIT;
 END TRY BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  THROW;
 END CATCH;
END;
GO
-- Read-only validation based on cart, member flag and externally supplied history.
-- @SoLanDaDung and @NganSachDaDung are DEMO inputs, not validated accounting records.
-- No budget reservation, concurrency protection or AP_DUNG_KM writes.
CREATE PROCEDURE dbo.sp_KiemTraDieuKienKM
 @MaKM NVARCHAR(30), @STTDieuKien INT=1,
 @TongTienHang DECIMAL(18,2),@GioHang dbo.GioHangInput READONLY,
 @LaThanhVien BIT=0,@SoLanDaDung INT=0,
 @NganSachDaDung DECIMAL(18,2)=0,
 @ThoiDiem DATETIME2(0)=NULL
AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @HopLe BIT=0,@LyDo NVARCHAR(250)=N'',
 @HinhThuc NVARCHAR(20),@Kieu NVARCHAR(30),@Nguong DECIMAL(18,2),
 @MinSL INT,@ThanhVien BIT,@Limit INT,@Budget DECIMAL(18,2),
 @SLMua INT=0,@SLNhan INT=0,@MucGiam DECIMAL(18,2)=0,
 @GiaTri DECIMAL(18,2),@Tran DECIMAL(18,2),@SoTang INT=NULL,@Base DECIMAL(18,2)=NULL;
 SET @ThoiDiem=COALESCE(@ThoiDiem,SYSDATETIME());
 IF @TongTienHang IS NULL OR @TongTienHang<0 OR @SoLanDaDung IS NULL OR @SoLanDaDung<0
 OR @NganSachDaDung IS NULL OR @NganSachDaDung<0 BEGIN
  SELECT CONVERT(BIT,0) HopLe,N'Dau vao khong hop le' LyDo,CONVERT(DECIMAL(18,2),0) TienGiam,
  CONVERT(INT,NULL) SoLuongQuaDuKien; RETURN;
 END;
 SELECT @HinhThuc=K.HinhThuc,@Kieu=D.KieuUuDai,@Nguong=D.NguongTienDon,
 @MinSL=D.SoLuongMuaToiThieu,@ThanhVien=K.ChiApDungThanhVien,
 @Limit=K.SoLanToiDaMoiKhach,@Budget=K.NganSachToiDa,
 @GiaTri=D.GiaTriUuDai,@Tran=D.TienGiamToiDa,@SoTang=D.SoLuongUuDaiToiDa
 FROM KHUYEN_MAI K JOIN DIEU_KIEN_KM D ON D.MaKM=K.MaKM
 WHERE K.MaKM=@MaKM AND D.STTDieuKien=@STTDieuKien
 AND K.KichHoat=1 AND @ThoiDiem>=K.BatDau AND @ThoiDiem<K.KetThuc;
 SELECT @SLMua=COALESCE(SUM(G.SoLuong),0)
 FROM @GioHang G JOIN KM_MON_MUA M ON M.MaMon=G.MaMon
 AND M.MaKM=@MaKM AND M.STTDieuKien=@STTDieuKien;
 SELECT @SLNhan=COALESCE(SUM(G.SoLuong),0),
 @Base=COALESCE(SUM(G.SoLuong*S.GiaBan),0)
 FROM @GioHang G JOIN KM_MON_NHAN N ON N.MaMon=G.MaMon
 AND N.MaKM=@MaKM AND N.STTDieuKien=@STTDieuKien
 JOIN SIZE_MON S ON S.MaMon=G.MaMon AND S.MaSize=G.MaSize;
 IF @HinhThuc IS NULL SET @LyDo=N'KM khong ton tai, chua kich hoat hoac het han';
 ELSE IF @TongTienHang<@Nguong SET @LyDo=N'Chua dat nguong tien';
 ELSE IF @ThanhVien=1 AND @LaThanhVien=0 SET @LyDo=N'Chi ap dung thanh vien';
 ELSE IF @Limit IS NOT NULL AND @SoLanDaDung>=@Limit SET @LyDo=N'Vuot so lan/khach';
 ELSE IF @Budget IS NOT NULL AND @NganSachDaDung>=@Budget SET @LyDo=N'Het ngan sach';
 ELSE IF @HinhThuc=N'MuaTang' AND @SLMua<@MinSL SET @LyDo=N'Chua du mon mua';
 ELSE IF @HinhThuc=N'GiamMon' AND @SLNhan=0 SET @LyDo=N'Khong co mon duoc giam trong gio';
 ELSE IF @HinhThuc=N'MuaTang' AND @SoTang IS NULL SET @LyDo=N'Thieu so luong qua';
 ELSE IF @Kieu=N'GiamPhanTram' AND (@GiaTri IS NULL OR @GiaTri>100) SET @LyDo=N'Ty le khong hop le';
 ELSE BEGIN
   IF @HinhThuc=N'MuaTang' BEGIN
      -- No gift-line insertion; return a gift allowance for the separate order workflow.
      SET @SoTang=@SoTang*(@SLMua/@MinSL);
      SET @MucGiam=0;
   END ELSE BEGIN
      SET @Base=CASE WHEN @HinhThuc=N'GiamDon' THEN @TongTienHang ELSE @Base END;
      SET @MucGiam=CASE @Kieu
        WHEN N'GiamTien' THEN @GiaTri
        WHEN N'GiamPhanTram' THEN ROUND(@Base*@GiaTri/100,2)
        WHEN N'DongGia' THEN CASE WHEN @Base>@GiaTri THEN @Base-@GiaTri ELSE 0 END ELSE 0 END;
      IF @MucGiam>@Base SET @MucGiam=@Base;
      IF @Tran IS NOT NULL AND @MucGiam>@Tran SET @MucGiam=@Tran;
      IF @Budget IS NOT NULL AND @MucGiam+@NganSachDaDung>@Budget
       SET @LyDo=N'Khong du ngan sach';
   END;
   IF @LyDo=N'' BEGIN SET @HopLe=1; SET @LyDo=N'Hop le de du kien'; END;
 END;
 IF @HopLe=0 BEGIN SET @MucGiam=0; SET @SoTang=NULL; END;
 SELECT @HopLe HopLe,@LyDo LyDo,@MucGiam TienGiam,
 CASE WHEN @HinhThuc=N'MuaTang' THEN @SoTang ELSE NULL END AS SoLuongQuaDuKien;
END;
GO
-- TASK 6: additional automated checks. Independent of the existing T1-T9.
-- Negative create is expected to fail; valid creation must persist.
DECLARE @Mua dbo.KMMonInput, @Nhan dbo.KMMonInput;
INSERT @Mua VALUES(N'M01'); INSERT @Nhan VALUES(N'M03');
EXEC dbo.sp_TaoKhuyenMai
 @MaKM=N'KM04',@TenKM=N'Mua 2 tang 1',@BatDau='2026-10-01',
 @KetThuc='2026-12-01',@HinhThuc=N'MuaTang',@KieuUuDai=N'TangMon',
 @SoLuongMuaToiThieu=2,@SoLuongUuDaiToiDa=1,@KichHoat=1,
 @MonMua=@Mua,@MonNhan=@Nhan;
SELECT N'T10 tao KM04' AS KichBan,MaKM,TenKM FROM KHUYEN_MAI WHERE MaKM=N'KM04';
GO
DECLARE @Mua dbo.KMMonInput, @Nhan dbo.KMMonInput;
BEGIN TRY
 EXEC dbo.sp_TaoKhuyenMai
 @MaKM=N'KM05',@TenKM=N'KM sai',@BatDau='2026-12-01',
 @KetThuc='2026-11-01',@HinhThuc=N'MuaTang',@KieuUuDai=N'TangMon',
 @SoLuongMuaToiThieu=2,@SoLuongUuDaiToiDa=1,
 @MonMua=@Mua,@MonNhan=@Nhan;
 SELECT N'T11 FAIL: accepted invalid time' AS KetQua;
END TRY BEGIN CATCH SELECT N'T11 PASS: invalid time rejected' AS KetQua,ERROR_MESSAGE() AS LyDo; END CATCH;
SELECT N'T11 khong tao ban ghi' AS KichBan,COUNT(*) AS SoBanGhi FROM KHUYEN_MAI WHERE MaKM=N'KM05';
GO
DECLARE @G dbo.GioHangInput;
INSERT @G VALUES(N'M01','S',2);
EXEC dbo.sp_KiemTraDieuKienKM @MaKM=N'KM04',@TongTienHang=50000,@GioHang=@G,@ThoiDiem='2026-11-01';
DELETE FROM @G;
INSERT @G VALUES(N'M01','S',1);
EXEC dbo.sp_KiemTraDieuKienKM @MaKM=N'KM04',@TongTienHang=25000,@GioHang=@G,@ThoiDiem='2026-11-01';
GO
-- Table checks: TamNgung B03, B02 occupied, B01/B04 available.
SELECT B.MaBan,B.TrangThaiHoatDong,
 CASE WHEN EXISTS(SELECT 1 FROM DON_HANG D
 WHERE D.MaBan=B.MaBan AND D.TrangThaiDonHang=N'DangPhucVu')
 THEN N'DangPhucVu' ELSE N'Trong' END TrangThaiBan
FROM BAN B ORDER BY B.MaBan;
GO
