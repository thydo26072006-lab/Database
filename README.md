# Coffee POS — Microsoft SQL Server

Schema trong `sql/001_pos_core.sql` dùng T-SQL cho Microsoft SQL Server 2016 trở lên.

## Cách chạy

1. Kết nối SQL Server bằng SQL Server Management Studio (SSMS).
2. Mở `sql/001_pos_core.sql` và chạy toàn bộ file.
3. Refresh mục Databases để xem database `coffee_pos` và các bảng.

Hoặc chạy bằng `sqlcmd` với Windows Authentication:

```sh
sqlcmd -S localhost -E -b -i sql/001_pos_core.sql
```

Thay `localhost` bằng tên server/instance của bạn. Tài khoản cần quyền tạo
database nếu `coffee_pos` chưa tồn tại và quyền tạo bảng trong database đó.
`GO` là dấu phân tách batch của SSMS/sqlcmd; khi chạy qua ứng dụng cần tách
batch trước khi gửi đến SQL Server.

Script dành cho khởi tạo mới: nếu database đã tồn tại thì dùng lại database đó,
nhưng không bỏ qua hoặc xóa các bảng đã có. Script không chuyển dữ liệu từ MySQL.

## Kiểu dữ liệu

- `NVARCHAR` / `NVARCHAR(MAX)` và literal `N'...'` để lưu tiếng Việt.
- `BIT` với giá trị `0` / `1` thay cho `BOOLEAN` và `FALSE` / `TRUE`.
- `DATETIME2(0)` cho ngày giờ, giữ độ chính xác đến giây như schema ban đầu.
- Giữ các khóa chính, khóa ngoại, `CHECK`, `UNIQUE` và quy tắc nghiệp vụ hiện có.

Khi ghi chuỗi tiếng Việt trong T-SQL, dùng `N'Cà phê sữa'`; khi dùng ứng dụng,
truyền tham số Unicode. Database mới dùng collation mặc định của SQL Server;
nếu cần quy tắc so sánh có/không phân biệt dấu, hãy cấu hình collation phù hợp.
