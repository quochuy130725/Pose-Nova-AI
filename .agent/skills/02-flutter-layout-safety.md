---
name: 02-flutter-layout-safety
description: Quy chuẩn an toàn bố cục Flutter, chính sách Zero RenderFlex Overflow, cấu trúc Provider sạch và quy trình kiểm tra chất lượng.
---

# Skill: Flutter Zero Overflow & Clean Code

Quy chuẩn lập trình giao diện Flutter đảm bảo độ ổn định tuyệt đối, không tràn pixel và kiến trúc code sạch sẽ.

---

## 1. Chính Sách "Zero RenderFlex Overflow"

Lỗi tràn pixel màu vàng đen (`RenderFlex overflowed`) là lỗi nghiêm trọng nhất cần ngăn chặn từ gốc:

1. **Thẻ Hẹp (Masonry Grid Column < 160px):**
   - CẤM đặt nhiều phần tử text động trên cùng một `Row` mà không bọc `Expanded` hoặc `Flexible`.
   - Bắt buộc khai báo `maxLines: 1` và `overflow: TextOverflow.ellipsis` cho mọi tiêu đề hoặc tên tác giả động.
   - Thẻ creator: Avatar tròn 18-20px + Text bọc `Expanded(child: Text(..., overflow: TextOverflow.ellipsis))`.

2. **Nút Bấm Trên Thẻ Sản Phẩm / Lookbook:**
   - Bắt buộc sử dụng nút Full-Width: `width: double.infinity`, `height: 36.0`.
   - Giúp giao diện phẳng phiu, thanh thoát và không bao giờ bị tràn theo chiều ngang bất kể độ phân giải màn hình.

3. **Lưới So Le (Staggered Masonry Layout):**
   - Cột so le bên phải bắt buộc dùng `SizedBox(height: 24.0)` đặt ở phần tử đầu tiên của cột.
   - TUYỆT ĐỐI KHÔNG dùng `Transform.translate(offset: Offset(0, 24))` vì sẽ làm lệch bounding box tính toán kích thước cuộn của Flutter, gây giật lag và lỗi cuộn.

4. **Khoảng Đệm Đáy Danh Sách Cuộn (Bottom Padding):**
   - Mọi `ListView`, `SingleChildScrollView`, `CustomScrollView` ở màn hình chính bắt buộc có `padding: EdgeInsets.only(bottom: 140.0)`.
   - Đảm bảo các thẻ ở cuối danh sách không bao giờ bị che lấp bởi thanh Floating Capsule Bottom Bar.

---

## 2. Quản Lý State & Cấu Trúc Provider

Ứng dụng sử dụng mô hình ChangeNotifier Singleton Providers tinh gọn, trực quan:

- `LookbookProvider.instance`: Quản lý danh sách Lookbook, lượt thích, lọc danh mục, sản phẩm affiliate.
- `StylingRequestProvider.instance`: Quản lý đơn hàng phối đồ `#REQ-XXXX`, giải ngân mốc, nộp bài, duyệt bài.
- `WalletProvider.instance`: Quản lý số dư ví khả dụng, quỹ ký quỹ đang khóa, lịch sử đối soát giao dịch.
- `AuthProvider.instance`: Quản lý tài khoản, phiên đăng nhập JWT, chuyển đổi vai trò 1-chạm giữa Client và Stylist Studio.
- `PoseCaptureProvider.instance`: Quản lý khung hình chụp camera, lưu trữ On-Device Gallery Album `PoseNova AI`.

### Đa Ngôn Ngữ & Bản Địa Hóa (Localization)
- Hỗ trợ VI / EN đồng bộ qua `AppLanguageController.instance`.
- Lấy chuỗi hiển thị qua `final t = AppLanguageController.instance.t`.
- Tuyệt đối không hardcode chuỗi thông báo nếu có thể tái sử dụng qua `t.*`.

---

## 3. Quy Trình Kiểm Tra Bắt Buộc (Quality Gate)

Sau mỗi lần sửa đổi mã nguồn Flutter, BẮT BUỘC thực hiện kiểm tra:

```bash
cd "Front-end"
flutter analyze lib
```

- **Mục tiêu:** Đạt kết quả **`No issues found!`** (0 error, 0 warning, 0 info không cần thiết).
- Không để tồn tại cảnh báo `use_build_context_synchronously`, `dead_code`, hay `unused_import`.

