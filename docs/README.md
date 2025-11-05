## Báo cáo tiến độ dự án Matcha

### Tiến độ tổng quan
- Ứng dụng Flutter đang chạy ổn định trên giao diện Material 3, đã cấu hình theme và điều hướng cơ bản.
- Hoàn thiện giao diện và luồng màn hình chính: đăng nhập, đăng ký nhiều bước, tab điều hướng, khám phá/kết đôi, tin nhắn, hồ sơ, cài đặt, danh sách chặn.
- Đồng bộ hoá màu sắc giao diện theo tông hồng pastel, loại bỏ các gradient ở nút/logo để thống nhất nhận diện.

### Chức năng đã hoàn thành
- Đăng nhập UI (điều hướng vào ứng dụng, chưa có xác thực server).
- Đăng ký nhiều bước (tên, tuổi, ảnh, giới thiệu, sở thích) với điều hướng/nút điều kiện và chọn ảnh từ thư viện/camera.
- Thanh tab và điều hướng 4 màn hình: Khám phá, Kết đôi, Tin nhắn, Hồ sơ.
- Màn hình Khám phá: thẻ hồ sơ với hiệu ứng, badge, CTA.
- Màn hình Kết đôi: lưới danh sách kết đôi, badge “Mới”, điểm tương hợp, CTA nhắn tin.
- Màn hình Tin nhắn: danh sách hội thoại và chi tiết hội thoại (dữ liệu mock), gửi tin nhắn nội bộ UI.
- Màn hình Hồ sơ: hiển thị và trạng thái chỉnh sửa, thống kê nhỏ, danh sách sở thích.
- Màn hình Cài đặt: khu vực cấu hình, điều hướng đến danh sách chặn.
- Danh sách chặn: thêm/xoá/tìm kiếm người bị chặn, lưu trữ cục bộ với SharedPreferences.
- Chủ đề màu sắc: pastel pink thống nhất cho nút/logo và các thành phần chính.

### Trạng thái Backend
- Đã khởi tạo backend Node.js + Express + Firebase (Firestore, FCM, Storage).
- API có sẵn: auth (register/login), user (get/update), match (swipe/check/list), chat (send/list), block (create/list).
- Yêu cầu `.env` trong `backend/` với `FIREBASE_CREDENTIALS`, `JWT_SECRET`, `FIREBASE_STORAGE_BUCKET`.

### Nền tảng và cấu hình
- Flutter đa nền tảng (Android, iOS, Web) đã có cấu trúc dự án và assets.
- Android/iOS đã cấu hình cơ bản (Gradle/Xcode), icon/launch assets có sẵn.

Lưu ý: Tài liệu này chỉ báo cáo tiến độ, các chức năng hiện có và trạng thái backend như yêu cầu.
