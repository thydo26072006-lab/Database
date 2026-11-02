# Task A — Thực đơn, danh mục, bàn và khuyến mãi

## Cấu trúc
- [sql/task_a_demo.sql](sql/task_a_demo.sql): bản demo độc lập dành cho SQL Server 2016+ (SSMS), chạy trong database `coffee_pos_task_a`. Gồm bảng, dữ liệu mẫu, 5 truy vấn, 1 hàm, 4 thủ tục và các kịch bản kiểm thử.

## Cách chạy
1. Mở SQL Server Management Studio.
2. Mở file `sql/task_a_demo.sql`, chọn Execute trên SQL Server 2016+.
3. Script chỉ dành cho lần chạy đầu trên database mới. Các lần chạy lại sẽ gặp lỗi bảng/dữ liệu trùng.
4. Chụp kết quả truy vấn Q1–Q5 và kịch bản kiểm thử để đối chiếu báo cáo.

## Phạm vi
- Chỉ có các size S/M/L, mỗi món có từ 1 đến 3 size, mỗi size có giá và trạng thái riêng.
- Quy tắc **ít nhất một size** được bảo đảm khi thêm món qua `sp_ThemMon`, chưa ngăn được mọi thao tác INSERT trực tiếp vào MON.
- `sp_TinhUuDaiDuKien` chỉ **tính thử** giảm giá. Chưa xác nhận lên đơn, chống dùng lặp, giữ ngân sách hay tự sinh quà.
- `KM_MON_MUA` và `KM_MON_NHAN` để mô tả tập món mua/nhận cho khuyến mãi.
- Bản demo không thay thế lược đồ đơn hàng và AP_DUNG_KM chính thức khi tích hợp Task B.
- SQL chưa được thực thi trong SSMS tại đây; cần kiểm thử trước khi nộp.

Đây là **bản demo Task A tách riêng**, không phải bản sao byte-for-byte của tệp `001_pos_core_TASK_A_fixed.sql` đã phát hành trong hội thoại.
