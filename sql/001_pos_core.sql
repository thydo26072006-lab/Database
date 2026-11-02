-- POS quan ca phe - Microsoft SQL Server 2016+
-- Chay bang SSMS hoac sqlcmd (ho tro dau phan tach batch GO).
-- Phien ban khoi tao cho phan he ban hang, size, khuyen mai, thanh toan.
-- Quy tac chinh: moi mon co 1-3 size S/M/L, khong co TC.
USE master;
GO
IF DB_ID(N'coffee_pos') IS NULL
BEGIN
  EXEC(N'CREATE DATABASE coffee_pos');
END;
GO
USE coffee_pos;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE KHU_VUC (
  MaKhuVuc NVARCHAR(30) PRIMARY KEY,
  TenKhuVuc NVARCHAR(150) NOT NULL,
  GhiChu NVARCHAR(MAX)
);
CREATE TABLE BAN (
  MaBan NVARCHAR(30) PRIMARY KEY,
  MaKhuVuc NVARCHAR(30) NOT NULL,
  TenBan NVARCHAR(100) NOT NULL,
  SoGhe INT NULL CHECK (SoGhe > 0),
  SoThuTu INT NULL CHECK (SoThuTu >= 0),
  TrangThaiHoatDong NVARCHAR(20) NOT NULL DEFAULT N'HoatDong'
    CHECK (TrangThaiHoatDong IN (N'HoatDong',N'TamNgung')),
  GhiChu NVARCHAR(MAX),
  FOREIGN KEY (MaKhuVuc) REFERENCES KHU_VUC(MaKhuVuc)
);
CREATE TABLE DANH_MUC_MON (
  MaDanhMuc NVARCHAR(30) PRIMARY KEY,
  MaDanhMucCha NVARCHAR(30) NULL,
  TenDanhMuc NVARCHAR(150) NOT NULL,
  FOREIGN KEY (MaDanhMucCha) REFERENCES DANH_MUC_MON(MaDanhMuc)
);
CREATE TABLE MON (
  MaMon NVARCHAR(30) PRIMARY KEY,
  MaDanhMuc NVARCHAR(30) NOT NULL,
  TenMon NVARCHAR(150) NOT NULL,
  TrangThaiKinhDoanh NVARCHAR(20) NOT NULL DEFAULT N'DangBan'
    CHECK (TrangThaiKinhDoanh IN (N'DangBan',N'NgungBan')),
  FOREIGN KEY (MaDanhMuc) REFERENCES DANH_MUC_MON(MaDanhMuc)
);
CREATE TABLE SIZE_MON (
  MaMon NVARCHAR(30) NOT NULL,
  MaSize CHAR(1) NOT NULL CHECK (MaSize IN (N'S',N'M',N'L')),
  TenSize NVARCHAR(50) NOT NULL,
  GiaBan DECIMAL(18,2) NOT NULL CHECK (GiaBan >= 0),
  TrangThaiSize NVARCHAR(20) NOT NULL DEFAULT N'DangBan'
    CHECK (TrangThaiSize IN (N'DangBan',N'NgungBan')),
  PRIMARY KEY (MaMon, MaSize),
  FOREIGN KEY (MaMon) REFERENCES MON(MaMon)
);
-- CHECK S/M/L + PK(MaMon,MaSize) cho phep toi da 3 size/món.
-- Yeu cau IT NHAT 1 size/mon phai kiem tra trong giao dich tao/duyet mon
-- hoac trigger/procedure; CHECK tren mot bang khong the kiem tra bang khac.

CREATE TABLE NHAN_VIEN (
  MaNV NVARCHAR(30) PRIMARY KEY,
  HoTen NVARCHAR(150) NOT NULL,
  TrangThaiLamViec NVARCHAR(20) NOT NULL DEFAULT N'DangLam'
    CHECK (TrangThaiLamViec IN (N'DangLam',N'DaNghi')),
  NgayVaoLam DATE NOT NULL,
  NgayNghiViec DATE NULL,
  DuocLapPhieuKho BIT NOT NULL DEFAULT 0,
  CHECK (NgayNghiViec IS NULL OR NgayNghiViec >= NgayVaoLam)
);
CREATE TABLE PHUC_VU (
  MaNV NVARCHAR(30) PRIMARY KEY,
  SoBanPhuTrachToiDa INT NULL CHECK (SoBanPhuTrachToiDa > 0),
  FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
);
CREATE TABLE THU_NGAN (
  MaNV NVARCHAR(30) PRIMARY KEY,
  DuocHuyHoaDon BIT NOT NULL DEFAULT 0,
  FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
);
CREATE TABLE QUAN_LY (
  MaNV NVARCHAR(30) PRIMARY KEY,
  DuocDuyetChamCong BIT NOT NULL DEFAULT 1,
  DuocChotBangLuong BIT NOT NULL DEFAULT 1,
  DuocDuyetKho BIT NOT NULL DEFAULT 0,
  DuocDuyetKPI BIT NOT NULL DEFAULT 0,
  FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
);
CREATE TABLE KHACH_HANG (
  MaKH NVARCHAR(30) PRIMARY KEY,
  HoTen NVARCHAR(150) NOT NULL,
  SoDienThoai NVARCHAR(20) NOT NULL UNIQUE,
  Email NVARCHAR(255),
  DiemHienCo INT NOT NULL DEFAULT 0 CHECK (DiemHienCo >= 0)
);
CREATE TABLE CHINH_SACH_DIEM (
  MaChinhSachDiem NVARCHAR(30) PRIMARY KEY,
  TuNgay DATETIME2(0) NOT NULL,
  DenNgay DATETIME2(0) NOT NULL,
  SoDongMoiDiemCong DECIMAL(18,2) NOT NULL CHECK (SoDongMoiDiemCong > 0),
  GiaTriVNDMoiDiemDoi DECIMAL(18,2) NOT NULL CHECK (GiaTriVNDMoiDiemDoi >= 0),
  TyLeSuDungToiDa DECIMAL(5,4) NOT NULL CHECK (TyLeSuDungToiDa BETWEEN 0 AND 1),
  TrangThai NVARCHAR(20) NOT NULL CHECK (TrangThai IN (N'Nhap',N'KichHoat',N'Ngung')),
  CHECK (TuNgay < DenNgay)
);
CREATE TABLE KHO (
  MaKho NVARCHAR(30) PRIMARY KEY CHECK (MaKho = N'KHO_CHINH'),
  TenKho NVARCHAR(150) NOT NULL
);
CREATE TABLE DON_HANG (
  MaDonHang NVARCHAR(30) PRIMARY KEY,
  MaBan NVARCHAR(30) NOT NULL,
  MaKH NVARCHAR(30) NULL,
  MaNVPhucVu NVARCHAR(30) NOT NULL,
  MaChinhSachDiem NVARCHAR(30) NULL,
  MaKhoXuat NVARCHAR(30) NULL CHECK (MaKhoXuat IS NULL OR MaKhoXuat = N'KHO_CHINH'),
  ThoiDiemTao DATETIME2(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  TrangThaiDonHang NVARCHAR(20) NOT NULL DEFAULT N'DangPhucVu'
    CHECK (TrangThaiDonHang IN (N'DangPhucVu',N'DaThanhToan',N'DaHuy')),
  DiemSuDung INT NOT NULL DEFAULT 0 CHECK (DiemSuDung >= 0),
  DiemDuocCong INT NOT NULL DEFAULT 0 CHECK (DiemDuocCong >= 0),
  GiaTriDoiDiemApDung DECIMAL(18,2) NULL CHECK (GiaTriDoiDiemApDung >= 0),
  SoDongMoiDiemCongApDung DECIMAL(18,2) NULL CHECK (SoDongMoiDiemCongApDung > 0),
  TyLeSuDungDiemToiDaApDung DECIMAL(5,4) NULL
    CHECK (TyLeSuDungDiemToiDaApDung BETWEEN 0 AND 1),
  TrangThaiUuDai NVARCHAR(20) NOT NULL DEFAULT N'KhongApDung'
    CHECK (TrangThaiUuDai IN (N'KhongApDung',N'DaXacNhan',N'DaChot')),
  ThoiDiemXacNhanKM DATETIME2(0) NULL,
  MaNVXacNhanKM NVARCHAR(30) NULL,
  SoKhach INT NULL CHECK (SoKhach > 0),
  FOREIGN KEY (MaBan) REFERENCES BAN(MaBan),
  FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH),
  FOREIGN KEY (MaNVPhucVu) REFERENCES PHUC_VU(MaNV),
  FOREIGN KEY (MaNVXacNhanKM) REFERENCES THU_NGAN(MaNV),
  FOREIGN KEY (MaChinhSachDiem) REFERENCES CHINH_SACH_DIEM(MaChinhSachDiem),
  FOREIGN KEY (MaKhoXuat) REFERENCES KHO(MaKho),
  CHECK (TrangThaiUuDai = N'KhongApDung' OR (ThoiDiemXacNhanKM IS NOT NULL AND MaNVXacNhanKM IS NOT NULL))
);
CREATE TABLE CHI_TIET_DON_HANG (
  MaDonHang NVARCHAR(30) NOT NULL,
  STT INT NOT NULL CHECK (STT > 0),
  MaMon NVARCHAR(30) NOT NULL,
  MaSizeChon CHAR(1) NOT NULL,
  SoLuong INT NOT NULL CHECK (SoLuong > 0),
  DonGiaTaiThoiDiemBan DECIMAL(18,2) NOT NULL CHECK (DonGiaTaiThoiDiemBan >= 0),
  TenMonTaiThoiDiemBan NVARCHAR(150) NOT NULL,
  TenSizeTaiThoiDiemBan NVARCHAR(50) NOT NULL,
  LoaiDong NVARCHAR(10) NOT NULL DEFAULT N'Mua' CHECK (LoaiDong IN (N'Mua',N'TangKM')),
  GhiChu NVARCHAR(MAX),
  PRIMARY KEY (MaDonHang, STT),
  FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang),
  FOREIGN KEY (MaMon, MaSizeChon) REFERENCES SIZE_MON(MaMon, MaSize)
);
-- Snapshot don gia va ten mon/size khong duoc cap nhat theo bang gia moi.
-- TangKM la dong qua tang rieng; khong tu dong coi gia niem yet = 0.

CREATE TABLE KHUYEN_MAI (
  MaKM NVARCHAR(30) PRIMARY KEY,
  TenKM NVARCHAR(150) NOT NULL,
  BatDau DATETIME2(0) NOT NULL,
  KetThuc DATETIME2(0) NOT NULL,
  HinhThuc NVARCHAR(30) NOT NULL
    CHECK (HinhThuc IN (N'GiamDon',N'GiamMon',N'MuaTang')),
  KichHoat BIT NOT NULL DEFAULT 0,
  MaKMTruoc NVARCHAR(30) NULL,
  FOREIGN KEY (MaKMTruoc) REFERENCES KHUYEN_MAI(MaKM),
  CHECK (BatDau < KetThuc)
);
CREATE TABLE DIEU_KIEN_KM (
  MaKM NVARCHAR(30) NOT NULL,
  STTDieuKien INT NOT NULL CHECK (STTDieuKien > 0),
  NguongTienDon DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (NguongTienDon >= 0),
  SoLuongMuaToiThieu INT NULL CHECK (SoLuongMuaToiThieu > 0),
  KieuUuDai NVARCHAR(30) NOT NULL
    CHECK (KieuUuDai IN (N'GiamTien',N'GiamPhanTram',N'DongGia',N'TangMon')),
  GiaTriUuDai DECIMAL(18,2) NULL CHECK (GiaTriUuDai >= 0),
  TienGiamToiDa DECIMAL(18,2) NULL CHECK (TienGiamToiDa >= 0),
  SoLuongUuDaiToiDa INT NULL CHECK (SoLuongUuDaiToiDa > 0),
  ThuTuUuTien INT NOT NULL DEFAULT 0,
  PRIMARY KEY (MaKM, STTDieuKien),
  FOREIGN KEY (MaKM) REFERENCES KHUYEN_MAI(MaKM)
);
CREATE TABLE AP_DUNG_KM (
  MaDonHang NVARCHAR(30) NOT NULL,
  STTApDung INT NOT NULL CHECK (STTApDung > 0),
  MaKM NVARCHAR(30) NOT NULL,
  STTDieuKien INT NOT NULL,
  STTDong INT NULL,
  SoLuongHuongUuDai INT NULL CHECK (SoLuongHuongUuDai > 0),
  SoTienGiam DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (SoTienGiam >= 0),
  NoiDungApDung NVARCHAR(MAX),
  ThoiDiemApDung DATETIME2(0) NOT NULL,
  TrangThaiApDung NVARCHAR(20) NOT NULL CHECK (TrangThaiApDung IN (N'DaXacNhan',N'DaChot',N'DaHuy')),
  ThoiDiemHuy DATETIME2(0) NULL,
  LyDoHuy NVARCHAR(MAX) NULL,
  PRIMARY KEY (MaDonHang, STTApDung),
  FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang),
  FOREIGN KEY (MaKM, STTDieuKien) REFERENCES DIEU_KIEN_KM(MaKM, STTDieuKien),
  FOREIGN KEY (MaDonHang, STTDong) REFERENCES CHI_TIET_DON_HANG(MaDonHang, STT),
  CHECK (TrangThaiApDung <> N'DaHuy' OR ThoiDiemHuy IS NOT NULL)
);
CREATE TABLE THANH_TOAN (
  MaThanhToan NVARCHAR(30) PRIMARY KEY,
  MaDonHang NVARCHAR(30) NOT NULL UNIQUE,
  MaNVThuNgan NVARCHAR(30) NOT NULL,
  ThoiGianThanhToan DATETIME2(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PhuongThuc NVARCHAR(20) NOT NULL
    CHECK (PhuongThuc IN (N'TienMat',N'ChuyenKhoan',N'ViDienTu',N'The',N'KhongThuTien')),
  SoTienThanhToan DECIMAL(18,2) NOT NULL CHECK (SoTienThanhToan >= 0),
  FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang),
  FOREIGN KEY (MaNVThuNgan) REFERENCES THU_NGAN(MaNV)
);
CREATE TABLE HOA_DON (
  MaHoaDon NVARCHAR(30) PRIMARY KEY,
  MaThanhToan NVARCHAR(30) NOT NULL,
  ThoiGianLap DATETIME2(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  TrangThaiHoaDon NVARCHAR(20) NOT NULL
    CHECK (TrangThaiHoaDon IN (N'HieuLuc',N'DaHuy')),
  ThoiGianHuy DATETIME2(0) NULL,
  LyDoHuy NVARCHAR(MAX),
  FOREIGN KEY (MaThanhToan) REFERENCES THANH_TOAN(MaThanhToan)
);
CREATE TABLE HANG_HOA (
  MaHangHoa NVARCHAR(30) PRIMARY KEY,
  TenHangHoa NVARCHAR(150) NOT NULL,
  DonViTinh NVARCHAR(30) NOT NULL,
  TrangThaiSuDung NVARCHAR(20) NOT NULL DEFAULT N'DangSuDung'
);
CREATE TABLE TON_KHO (
  MaKho NVARCHAR(30) NOT NULL,
  MaHangHoa NVARCHAR(30) NOT NULL,
  ViTri NVARCHAR(150),
  TonToiThieu DECIMAL(18,6) NULL CHECK (TonToiThieu >= 0),
  TonToiDa DECIMAL(18,6) NULL CHECK (TonToiDa >= 0),
  PRIMARY KEY (MaKho,MaHangHoa),
  FOREIGN KEY (MaKho) REFERENCES KHO(MaKho),
  FOREIGN KEY (MaHangHoa) REFERENCES HANG_HOA(MaHangHoa),
  CHECK (TonToiDa IS NULL OR TonToiThieu IS NULL OR TonToiDa >= TonToiThieu)
);
CREATE TABLE CONG_THUC (
  MaCongThuc NVARCHAR(30) PRIMARY KEY,
  MaMon NVARCHAR(30) NOT NULL,
  MaSize CHAR(1) NOT NULL,
  TuLuc DATETIME2(0) NOT NULL,
  DenLuc DATETIME2(0) NOT NULL,
  TrangThai NVARCHAR(20) NOT NULL
    CHECK (TrangThai IN (N'Nhap',N'KichHoat',N'Ngung')),
  GhiChu NVARCHAR(MAX),
  FOREIGN KEY (MaMon,MaSize) REFERENCES SIZE_MON(MaMon,MaSize),
  CHECK (TuLuc < DenLuc)
);
CREATE TABLE CHI_TIET_CONG_THUC (
  MaCongThuc NVARCHAR(30) NOT NULL,
  MaHangHoa NVARCHAR(30) NOT NULL,
  DinhLuongCoSo DECIMAL(18,6) NOT NULL CHECK (DinhLuongCoSo > 0),
  PRIMARY KEY (MaCongThuc,MaHangHoa),
  FOREIGN KEY (MaCongThuc) REFERENCES CONG_THUC(MaCongThuc),
  FOREIGN KEY (MaHangHoa) REFERENCES HANG_HOA(MaHangHoa)
);
CREATE TABLE TIEU_HAO_DON_HANG (
  MaDonHang NVARCHAR(30) NOT NULL,
  STTDong INT NOT NULL,
  MaHangHoa NVARCHAR(30) NOT NULL,
  MaCongThuc NVARCHAR(30) NOT NULL,
  DinhLuongApDung DECIMAL(18,6) NOT NULL CHECK (DinhLuongApDung > 0),
  SoLuongMonApDung INT NOT NULL CHECK (SoLuongMonApDung > 0),
  SoLuongTieuHao DECIMAL(18,6) NOT NULL CHECK (SoLuongTieuHao >= 0),
  DonViTinhApDung NVARCHAR(30) NOT NULL,
  PRIMARY KEY (MaDonHang,STTDong,MaHangHoa),
  FOREIGN KEY (MaDonHang,STTDong) REFERENCES CHI_TIET_DON_HANG(MaDonHang,STT),
  FOREIGN KEY (MaHangHoa) REFERENCES HANG_HOA(MaHangHoa),
  FOREIGN KEY (MaCongThuc) REFERENCES CONG_THUC(MaCongThuc)
);
-- Luu y: day la phien ban nen tang cho ban hang/kho, chua phai tat ca
-- bang nhan su, cham cong, bang luong va KPI cua workbook.
-- Thu tuc duyet KM, sinh dong TangKM, kiem tra so du diem, chot don,
-- xuat kho va bat bien du lieu da chot phai thuc hien trong transaction.
