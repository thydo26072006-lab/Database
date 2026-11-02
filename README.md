# Coffee POS — Task A (SQL Server)

Repository demo cho **thực đơn, danh mục, bàn và khuyến mãi**. Script hiện hành duy nhất: [sql/task_a_demo.sql](sql/task_a_demo.sql).

## Chạy trong SSMS
1. Kết nối Microsoft SQL Server 2016+ bằng SSMS với quyền tạo database.
2. Mở `sql/task_a_demo.sql` rồi Execute **một lần trên cơ sở dữ liệu mới**. Script khởi tạo `coffee_pos_task_a`.
3. Xem kết quả Q1–Q5, T1–T11 và truy vấn kiểm tra khuyến mãi mua–tặng ở cuối file. Kịch bản thất bại có chủ đích sẽ được TRY/CATCH trả về thông báo.
4. Nếu cần chạy lại từ đầu, hãy dùng database demo mới/sao lưu rồi tạo lại database, tránh lỗi trùng bảng và dữ liệu.

## Những gì đã có
- Bảng: `KHU_VUC`, `BAN`, `DANH_MUC_MON`, `MON`, `SIZE_MON`, `DON_HANG` (chỉ trạng thái bàn), `KHUYEN_MAI`, `DIEU_KIEN_KM`, `KM_MON_MUA`, `KM_MON_NHAN`.
- Size chỉ **S/M/L**, mỗi món 1–3 size nếu tạo qua `sp_ThemMon` (bảng `SIZE_MON` ngăn trùng và ngăn mã khác S/M/L).
- Dữ liệu mẫu, các chỉ mục, 5 truy vấn Q1–Q5, hàm `fn_GiaBanTu`, thủ tục `sp_ThemMon`, `sp_CapNhatGiaMon`, `sp_NgungBanMon`, `sp_TinhUuDaiDuKien`.
- **Task 5 mới:** `sp_TaoKhuyenMai` tạo KM, một điều kiện và các tập món mua/nhận trong transaction; `sp_KiemTraDieuKienKM` kiểm tra thời gian, mức tiền, giỏ hàng, tập món mua, giới hạn thành viên, số lượt và ngân sách trên các tham số demo.
- **Task 6 mới:** kiểm thử tạo KM hợp lệ/sai thời gian, mua 2/tặng 1, không đủ số lượng, bàn tạm ngừng, size bất hợp lệ; các test cơ bản cũ vẫn giữ.

## Giới hạn quan trọng
- **Chưa chạy kiểm thử thực tế trong SSMS.** Các dòng demo là kịch bản, không phải bằng chứng SQL đã thực thi thành công.
- `sp_KiemTraDieuKienKM` chỉ trả quyết định **dự kiến**, không sinh dòng quà tặng, không ghi nhận áp dụng KM lên đơn, không khóa giữ ngân sách, không chống dùng trùng trong giao dịch thực tế. `@SoLanDaDung` và `@NganSachDaDung` là dữ liệu đầu vào do chương trình gọi cung cấp, không được truy vấn từ sổ sử dụng thực tế. Khi tích hợp đơn hàng phải bổ sung xử lý đồng thời, đối chiếu chính sách ưu tiên và snapshot tại thời điểm bán.
- Phần tặng món trả về *số lượng dự kiến*, còn món cụ thể phải được người dùng chọn trong tập `KM_MON_NHAN` và kiểm tra trạng thái bán trước khi đưa vào đơn.
- Truy vấn giảm theo món dùng giá hiện tại; tích hợp thanh toán phải dùng giá chụp tại thời điểm bán.
- Một món vẫn có thể được INSERT trực tiếp vào `MON` mà không có size nếu bỏ qua thủ tục. Quy tắc ít nhất một size mới được bảo đảm ở `sp_ThemMon`.
- `DON_HANG` của Task A là demo rút gọn; không dùng thay thế bảng đầy đủ của nhóm.

## Kỹ thuật
T-SQL `NVARCHAR`, literal Unicode `N'...'`, `DATETIME2`, `BIT` và `GO`. Script không tương thích trực tiếp MySQL.
