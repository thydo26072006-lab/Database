-- POS quan ca phe - MySQL 8.0+
-- Phien ban khoi tao cho phan he ban hang, size, khuyen mai, thanh toan.
-- Quy tac chinh: moi mon co 1-3 size S/M/L, khong co TC.
CREATE DATABASE IF NOT EXISTS coffee_pos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE coffee_pos;

CREATE TABLE KHU_VUC (
  MaKhuVuc VARCHAR(30) PRIMARY KEY,
  TenKhuVuc VARCHAR(150) NOT NULL,
  GhiChu TEXT
);
CREATE TABLE BAN (
  MaBan VARCHAR(30) PRIMARY KEY,
  MaKhuVuc VARCHAR(30) NOT NULL,
  TenBan VARCHAR(100) NOT NULL,
  SoGhe INT NULL CHECK (SoGhe > 0),
  SoThuTu INT NULL CHECK (SoThuTu >= 0),
  TrangThaiHoatDong VARCHAR(20) NOT NULL DEFAULT 'HoatDong'
    CHECK (TrangThaiHoatDong IN ('HoatDong','TamNgung')),
  GhiChu TEXT,
  FOREIGN KEY (MaKhuVuc) REFERENCES KHU_VUC(MaKhuVuc)
);
CREATE TABLE DANH_MUC_MON (
  MaDanhMuc VARCHAR(30) PRIMARY KEY,
  MaDanhMucCha VARCHAR(30) NULL,
  TenDanhMuc VARCHAR(150) NOT NULL,
  FOREIGN KEY (MaDanhMucCha) REFERENCES DANH_MUC_MON(MaDanhMuc)
);
CREATE TABLE MON (
  MaMon VARCHAR(30) PRIMARY KEY,
  MaDanhMuc VARCHAR(30) NOT NULL,
  TenMon VARCHAR(150) NOT NULL,
  TrangThaiKinhDoanh VARCHAR(20) NOT NULL DEFAULT 'DangBan'
    CHECK (TrangThaiKinhDoanh IN ('DangBan','NgungBan')),
  FOREIGN KEY (MaDanhMuc) REFERENCES DANH_MUC_MON(MaDanhMuc)
);
CREATE TABLE SIZE_MON (
  MaMon VARCHAR(30) NOT NULL,
  MaSize CHAR(1) NOT NULL CHECK (MaSize IN ('S','M','L')),
  TenSize VARCHAR(50) NOT NULL,
  GiaBan DECIMAL(18,2) NOT NULL CHECK (GiaBan >= 0),
  TrangThaiSize VARCHAR(20) NOT NULL DEFAULT 'DangBan'
    CHECK (TrangThaiSize IN ('DangBan','NgungBan')),
  PRIMARY KEY (MaMon, MaSize),
  FOREIGN KEY (MaMon) REFERENCES MON(MaMon)
);
-- CHECK S/M/L + PK(MaMon,MaSize) cho phep toi da 3 size/món.
-- Yeu cau IT NHAT 1 size/mon phai kiem tra trong giao dich tao/duyet mon
-- hoac trigger/procedure; CHECK tren mot bang khong the kiem tra bang khac.

CREATE TABLE NHAN_VIEN (
  MaNV VARCHAR(30) PRIMARY KEY,
  HoTen VARCHAR(150) NOT NULL,
  TrangThaiLamViec VARCHAR(20) NOT NULL DEFAULT 'DangLam'
    CHECK (TrangThaiLamViec IN ('DangLam','DaNghi')),
  NgayVaoLam DATE NOT NULL,
  NgayNghiViec DATE NULL,
  DuocLapPhieuKho BOOLEAN NOT NULL DEFAULT FALSE,
  CHECK (NgayNghiViec IS NULL OR NgayNghiViec >= NgayVaoLam)
);
CREATE TABLE PHUC_VU (
  MaNV VARCHAR(30) PRIMARY KEY,
  SoBanPhuTrachToiDa INT NULL CHECK (SoBanPhuTrachToiDa > 0),
  FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
);
CREATE TABLE THU_NGAN (
  MaNV VARCHAR(30) PRIMARY KEY,
  DuocHuyHoaDon BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
);
CREATE TABLE QUAN_LY (
  MaNV VARCHAR(30) PRIMARY KEY,
  DuocDuyetChamCong BOOLEAN NOT NULL DEFAULT TRUE,
  DuocChotBangLuong BOOLEAN NOT NULL DEFAULT TRUE,
  DuocDuyetKho BOOLEAN NOT NULL DEFAULT FALSE,
  DuocDuyetKPI BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
);
CREATE TABLE KHACH_HANG (
  MaKH VARCHAR(30) PRIMARY KEY,
  HoTen VARCHAR(150) NOT NULL,
  SoDienThoai VARCHAR(20) NOT NULL UNIQUE,
  Email VARCHAR(255),
  DiemHienCo INT NOT NULL DEFAULT 0 CHECK (DiemHienCo >= 0)
);
CREATE TABLE CHINH_SACH_DIEM (
  MaChinhSachDiem VARCHAR(30) PRIMARY KEY,
  TuNgay DATETIME NOT NULL,
  DenNgay DATETIME NOT NULL,
  SoDongMoiDiemCong DECIMAL(18,2) NOT NULL CHECK (SoDongMoiDiemCong > 0),
  GiaTriVNDMoiDiemDoi DECIMAL(18,2) NOT NULL CHECK (GiaTriVNDMoiDiemDoi >= 0),
  TyLeSuDungToiDa DECIMAL(5,4) NOT NULL CHECK (TyLeSuDungToiDa BETWEEN 0 AND 1),
  TrangThai VARCHAR(20) NOT NULL CHECK (TrangThai IN ('Nhap','KichHoat','Ngung')),
  CHECK (TuNgay < DenNgay)
);
CREATE TABLE KHO (
  MaKho VARCHAR(30) PRIMARY KEY CHECK (MaKho = 'KHO_CHINH'),
  TenKho VARCHAR(150) NOT NULL
);
CREATE TABLE DON_HANG (
  MaDonHang VARCHAR(30) PRIMARY KEY,
  MaBan VARCHAR(30) NOT NULL,
  MaKH VARCHAR(30) NULL,
  MaNVPhucVu VARCHAR(30) NOT NULL,
  MaChinhSachDiem VARCHAR(30) NULL,
  MaKhoXuat VARCHAR(30) NULL CHECK (MaKhoXuat IS NULL OR MaKhoXuat = 'KHO_CHINH'),
  ThoiDiemTao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  TrangThaiDonHang VARCHAR(20) NOT NULL DEFAULT 'DangPhucVu'
    CHECK (TrangThaiDonHang IN ('DangPhucVu','DaThanhToan','DaHuy')),
  DiemSuDung INT NOT NULL DEFAULT 0 CHECK (DiemSuDung >= 0),
  DiemDuocCong INT NOT NULL DEFAULT 0 CHECK (DiemDuocCong >= 0),
  GiaTriDoiDiemApDung DECIMAL(18,2) NULL CHECK (GiaTriDoiDiemApDung >= 0),
  SoDongMoiDiemCongApDung DECIMAL(18,2) NULL CHECK (SoDongMoiDiemCongApDung > 0),
  TyLeSuDungDiemToiDaApDung DECIMAL(5,4) NULL
    CHECK (TyLeSuDungDiemToiDaApDung BETWEEN 0 AND 1),
  TrangThaiUuDai VARCHAR(20) NOT NULL DEFAULT 'KhongApDung'
    CHECK (TrangThaiUuDai IN ('KhongApDung','DaXacNhan','DaChot')),
  ThoiDiemXacNhanKM DATETIME NULL,
  MaNVXacNhanKM VARCHAR(30) NULL,
  SoKhach INT NULL CHECK (SoKhach > 0),
  FOREIGN KEY (MaBan) REFERENCES BAN(MaBan),
  FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH),
  FOREIGN KEY (MaNVPhucVu) REFERENCES PHUC_VU(MaNV),
  FOREIGN KEY (MaNVXacNhanKM) REFERENCES THU_NGAN(MaNV),
  FOREIGN KEY (MaChinhSachDiem) REFERENCES CHINH_SACH_DIEM(MaChinhSachDiem),
  FOREIGN KEY (MaKhoXuat) REFERENCES KHO(MaKho),
  CHECK (TrangThaiUuDai = 'KhongApDung' OR (ThoiDiemXacNhanKM IS NOT NULL AND MaNVXacNhanKM IS NOT NULL))
);
CREATE TABLE CHI_TIET_DON_HANG (
  MaDonHang VARCHAR(30) NOT NULL,
  STT INT NOT NULL CHECK (STT > 0),
  MaMon VARCHAR(30) NOT NULL,
  MaSizeChon CHAR(1) NOT NULL,
  SoLuong INT NOT NULL CHECK (SoLuong > 0),
  DonGiaTaiThoiDiemBan DECIMAL(18,2) NOT NULL CHECK (DonGiaTaiThoiDiemBan >= 0),
  TenMonTaiThoiDiemBan VARCHAR(150) NOT NULL,
  TenSizeTaiThoiDiemBan VARCHAR(50) NOT NULL,
  LoaiDong VARCHAR(10) NOT NULL DEFAULT 'Mua' CHECK (LoaiDong IN ('Mua','TangKM')),
  GhiChu TEXT,
  PRIMARY KEY (MaDonHang, STT),
  FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang),
  FOREIGN KEY (MaMon, MaSizeChon) REFERENCES SIZE_MON(MaMon, MaSize)
);
-- Snapshot don gia va ten mon/size khong duoc cap nhat theo bang gia moi.
-- TangKM la dong qua tang rieng; khong tu dong coi gia niem yet = 0.

CREATE TABLE KHUYEN_MAI (
  MaKM VARCHAR(30) PRIMARY KEY,
  TenKM VARCHAR(150) NOT NULL,
  BatDau DATETIME NOT NULL,
  KetThuc DATETIME NOT NULL,
  HinhThuc VARCHAR(30) NOT NULL
    CHECK (HinhThuc IN ('GiamDon','GiamMon','MuaTang')),
  KichHoat BOOLEAN NOT NULL DEFAULT FALSE,
  MaKMTruoc VARCHAR(30) NULL,
  FOREIGN KEY (MaKMTruoc) REFERENCES KHUYEN_MAI(MaKM),
  CHECK (BatDau < KetThuc)
);
CREATE TABLE DIEU_KIEN_KM (
  MaKM VARCHAR(30) NOT NULL,
  STTDieuKien INT NOT NULL CHECK (STTDieuKien > 0),
  NguongTienDon DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (NguongTienDon >= 0),
  SoLuongMuaToiThieu INT NULL CHECK (SoLuongMuaToiThieu > 0),
  KieuUuDai VARCHAR(30) NOT NULL
    CHECK (KieuUuDai IN ('GiamTien','GiamPhanTram','DongGia','TangMon')),
  GiaTriUuDai DECIMAL(18,2) NULL CHECK (GiaTriUuDai >= 0),
  TienGiamToiDa DECIMAL(18,2) NULL CHECK (TienGiamToiDa >= 0),
  SoLuongUuDaiToiDa INT NULL CHECK (SoLuongUuDaiToiDa > 0),
  ThuTuUuTien INT NOT NULL DEFAULT 0,
  PRIMARY KEY (MaKM, STTDieuKien),
  FOREIGN KEY (MaKM) REFERENCES KHUYEN_MAI(MaKM)
);
CREATE TABLE AP_DUNG_KM (
  MaDonHang VARCHAR(30) NOT NULL,
  STTApDung INT NOT NULL CHECK (STTApDung > 0),
  MaKM VARCHAR(30) NOT NULL,
  STTDieuKien INT NOT NULL,
  STTDong INT NULL,
  SoLuongHuongUuDai INT NULL CHECK (SoLuongHuongUuDai > 0),
  SoTienGiam DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (SoTienGiam >= 0),
  NoiDungApDung TEXT,
  ThoiDiemApDung DATETIME NOT NULL,
  TrangThaiApDung VARCHAR(20) NOT NULL CHECK (TrangThaiApDung IN ('DaXacNhan','DaChot','DaHuy')),
  ThoiDiemHuy DATETIME NULL,
  LyDoHuy TEXT NULL,
  PRIMARY KEY (MaDonHang, STTApDung),
  FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang),
  FOREIGN KEY (MaKM, STTDieuKien) REFERENCES DIEU_KIEN_KM(MaKM, STTDieuKien),
  FOREIGN KEY (MaDonHang, STTDong) REFERENCES CHI_TIET_DON_HANG(MaDonHang, STT),
  CHECK (TrangThaiApDung <> 'DaHuy' OR ThoiDiemHuy IS NOT NULL)
);
CREATE TABLE THANH_TOAN (
  MaThanhToan VARCHAR(30) PRIMARY KEY,
  MaDonHang VARCHAR(30) NOT NULL UNIQUE,
  MaNVThuNgan VARCHAR(30) NOT NULL,
  ThoiGianThanhToan DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PhuongThuc VARCHAR(20) NOT NULL
    CHECK (PhuongThuc IN ('TienMat','ChuyenKhoan','ViDienTu','The','KhongThuTien')),
  SoTienThanhToan DECIMAL(18,2) NOT NULL CHECK (SoTienThanhToan >= 0),
  FOREIGN KEY (MaDonHang) REFERENCES DON_HANG(MaDonHang),
  FOREIGN KEY (MaNVThuNgan) REFERENCES THU_NGAN(MaNV)
);
CREATE TABLE HOA_DON (
  MaHoaDon VARCHAR(30) PRIMARY KEY,
  MaThanhToan VARCHAR(30) NOT NULL,
  ThoiGianLap DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  TrangThaiHoaDon VARCHAR(20) NOT NULL
    CHECK (TrangThaiHoaDon IN ('HieuLuc','DaHuy')),
  ThoiGianHuy DATETIME NULL,
  LyDoHuy TEXT,
  FOREIGN KEY (MaThanhToan) REFERENCES THANH_TOAN(MaThanhToan)
);
CREATE TABLE HANG_HOA (
  MaHangHoa VARCHAR(30) PRIMARY KEY,
  TenHangHoa VARCHAR(150) NOT NULL,
  DonViTinh VARCHAR(30) NOT NULL,
  TrangThaiSuDung VARCHAR(20) NOT NULL DEFAULT 'DangSuDung'
);
CREATE TABLE TON_KHO (
  MaKho VARCHAR(30) NOT NULL,
  MaHangHoa VARCHAR(30) NOT NULL,
  ViTri VARCHAR(150),
  TonToiThieu DECIMAL(18,6) NULL CHECK (TonToiThieu >= 0),
  TonToiDa DECIMAL(18,6) NULL CHECK (TonToiDa >= 0),
  PRIMARY KEY (MaKho,MaHangHoa),
  FOREIGN KEY (MaKho) REFERENCES KHO(MaKho),
  FOREIGN KEY (MaHangHoa) REFERENCES HANG_HOA(MaHangHoa),
  CHECK (TonToiDa IS NULL OR TonToiThieu IS NULL OR TonToiDa >= TonToiThieu)
);
CREATE TABLE CONG_THUC (
  MaCongThuc VARCHAR(30) PRIMARY KEY,
  MaMon VARCHAR(30) NOT NULL,
  MaSize CHAR(1) NOT NULL,
  TuLuc DATETIME NOT NULL,
  DenLuc DATETIME NOT NULL,
  TrangThai VARCHAR(20) NOT NULL
    CHECK (TrangThai IN ('Nhap','KichHoat','Ngung')),
  GhiChu TEXT,
  FOREIGN KEY (MaMon,MaSize) REFERENCES SIZE_MON(MaMon,MaSize),
  CHECK (TuLuc < DenLuc)
);
CREATE TABLE CHI_TIET_CONG_THUC (
  MaCongThuc VARCHAR(30) NOT NULL,
  MaHangHoa VARCHAR(30) NOT NULL,
  DinhLuongCoSo DECIMAL(18,6) NOT NULL CHECK (DinhLuongCoSo > 0),
  PRIMARY KEY (MaCongThuc,MaHangHoa),
  FOREIGN KEY (MaCongThuc) REFERENCES CONG_THUC(MaCongThuc),
  FOREIGN KEY (MaHangHoa) REFERENCES HANG_HOA(MaHangHoa)
);
CREATE TABLE TIEU_HAO_DON_HANG (
  MaDonHang VARCHAR(30) NOT NULL,
  STTDong INT NOT NULL,
  MaHangHoa VARCHAR(30) NOT NULL,
  MaCongThuc VARCHAR(30) NOT NULL,
  DinhLuongApDung DECIMAL(18,6) NOT NULL CHECK (DinhLuongApDung > 0),
  SoLuongMonApDung INT NOT NULL CHECK (SoLuongMonApDung > 0),
  SoLuongTieuHao DECIMAL(18,6) NOT NULL CHECK (SoLuongTieuHao >= 0),
  DonViTinhApDung VARCHAR(30) NOT NULL,
  PRIMARY KEY (MaDonHang,STTDong,MaHangHoa),
  FOREIGN KEY (MaDonHang,STTDong) REFERENCES CHI_TIET_DON_HANG(MaDonHang,STT),
  FOREIGN KEY (MaHangHoa) REFERENCES HANG_HOA(MaHangHoa),
  FOREIGN KEY (MaCongThuc) REFERENCES CONG_THUC(MaCongThuc)
);
-- Luu y: day la phien ban nen tang cho ban hang/kho, chua phai tat ca
-- bang nhan su, cham cong, bang luong va KPI cua workbook.
-- Thu tuc duyet KM, sinh dong TangKM, kiem tra so du diem, chot don,
-- xuat kho va bat bien du lieu da chot phai thuc hien trong transaction.
