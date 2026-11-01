# PoseNova AI — Core Engineering & Design Directives

Chào mừng bạn đến với dự án **PoseNova AI** — Nền tảng C2C Personal Styling Marketplace & AI Pose Atelier kết nối Khách hàng và Stylist.

Mọi tác vụ lập trình, thiết kế giao diện, xử lý Camera AI và kiến trúc Back-end trong dự án này **BẮT BUỘC** phải tuân thủ nghiêm ngặt 4 bộ quy chuẩn kỹ năng (Skills) cốt lõi tại thư mục `.agent/skills/`:

---

### 1. [01-editorial-design-system.md](file:///.agent/skills/01-editorial-design-system.md)
* **Triết lý:** Digital Fashion Lookbook xa xỉ, phong cách Wavespace Editorial & Munna Rahman Aesthetic.
* **Màu sắc:** Nền Sakura Pink `#FDF2F7`, chữ Deep Warm Espresso `#1E1B18`, CTA Gradient `#F43F5E` -> `#FF6B35`. Tuyệt đối không hardcode màu xanh teal hay viền đen dày.
* **Typography:** `Plus Jakarta Sans` cho tiêu đề và nút bấm; `JetBrains Mono` cho tiền tệ, mã đơn và telemetry.
* **Quy tắc Zero AI Emoji:** CẤM TUYỆT ĐỐI mọi emoji (`✨`, `🔥`, `⚡`, `✦`, `👋`) và icon sparkle `Icons.auto_awesome`.

### 2. [02-flutter-layout-safety.md](file:///.agent/skills/02-flutter-layout-safety.md)
* **Zero RenderFlex Overflow:** Cột lưới hẹp < 160px luôn dùng `Expanded` + `maxLines: 1` + `TextOverflow.ellipsis`. Nút CTA trên thẻ dùng full-width (`width: double.infinity`, `height: 36`).
* **Staggered Grid:** Dùng `SizedBox(height: 24)` ở đầu cột phải (không dùng `Transform.translate`).
* **Khoảng đệm đáy:** Mọi danh sách cuộn phải có `padding: EdgeInsets.only(bottom: 140)` để không bị Bottom Bar che lấp.
* **Kiểm tra bắt buộc:** Sau mỗi lần sửa code, luôn chạy `flutter analyze lib` và đảm bảo đạt **`No issues found!`**.

### 3. [03-mlkit-pose-camera.md](file:///.agent/skills/03-mlkit-pose-camera.md)
* **Nguyên lý Bất biến (Invariants):**
  - Luôn gọi `stopImageStream()` trước khi `takePicture()` để chống sập native camera buffer.
  - Khởi tạo `PoseDetector(model: PoseDetectionModel.base)` sớm trong `initState()`, dùng cờ `_isBusy` chống tràn RAM.
  - Dynamic Visible Joints: Chỉ chấm điểm trên các khớp hiển thị rõ trong khung hình, tuyệt đối không phạt khớp khuất ngoài màn hình.
  - Upper Body Visibility Gate: Phải phát hiện rõ thân trên (vai, khuỷu) trước khi cho phép đạt điểm Match.
  - Bảo mật 100% On-Device: Lưu vào máy qua `Gal.putImage()`, không gửi ảnh thô lên Cloud.
* **Kiến trúc Tinh chỉnh (Strategy Pattern & Config):**
  - Mọi tham số giải thuật (alpha làm mượt, thresholds điểm số, dung sai góc...) đọc từ `PoseMatchingConfig` (`lib/core/ai/pose_matching_config.dart`), cấm hardcode trong UI.
  - Mọi giải thuật chấm điểm kế thừa `PoseMatcherStrategy` (`lib/core/ai/pose_matcher.dart`), giúp tự do thử nghiệm công thức mới mà không ảnh hưởng Camera UI.

### 4. [04-escrow-prisma-backend.md](file:///.agent/skills/04-escrow-prisma-backend.md)
* **10 Bảng Prisma:** Tuân thủ `schema.prisma`, lưu tọa độ 33 điểm mốc `poseLandmarksJson: Json` dạng JSONB nguyên bản.
* **Quy tắc dòng tiền Escrow:** Phí sàn 15%, Stylist thực nhận 85% Net. Phân bổ đúng 3 chặng 30% - 30% - 40%.
* **SLA & Giải ngân:** Tối đa 2 lần sửa bài miễn phí; tự động giải ngân sau 48h nếu khách không phản hồi; bảo toàn 100% tiền các mốc đã duyệt cho Stylist khi có Dispute.

