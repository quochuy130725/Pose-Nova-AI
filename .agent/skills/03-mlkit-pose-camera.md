---
name: 03-mlkit-pose-camera
description: Quy chuẩn kiến trúc Camera AI 30 FPS, nguyên lý bất biến và chiến lược chấm điểm Strategy Pattern tách biệt cấu hình cho PoseNova AI.
---

# Skill: ML Kit Pose Detection & 30 FPS Camera Pipeline

Quy chuẩn kỹ thuật cho module Camera AI nhận diện tư thế trên thiết bị di động, đảm bảo tốc độ 30 FPS, độ chính xác cao và trải nghiệm tạo dáng tự nhiên.

Tài liệu được chia làm 2 phần cốt lõi:
1. **Nguyên lý Bất biến (Invariants):** Các quy tắc kỹ thuật sống còn không bao giờ thay đổi dù ứng dụng mở rộng.
2. **Chiến lược Tinh chỉnh (Strategy Pattern & Config):** Mọi tham số giải thuật được tách biệt hoàn toàn khỏi UI để dễ dàng thử nghiệm và thay đổi.

---

## 1. Các Nguyên Lý Bất Biến (Non-Negotiable Invariants)

Dù mở rộng ứng dụng hay thay đổi công thức toán học, 6 quy tắc sau đây là **bắt buộc tuân thủ 100%**:

### 1.1. Luôn Dừng Stream Trước Khi Chụp Ảnh (Deadlock Prevention)
Trên Android (CameraX) và iOS (AVFoundation), việc gọi `takePicture()` trong khi `startImageStream()` đang chạy sẽ gây xung đột native surface buffer và treo camera:
```dart
// BẮT BUỘC: Dừng stream trước khi chụp ảnh
if (controller.value.isStreamingImages) {
  await controller.stopImageStream();
}
final XFile file = await controller.takePicture();
```

### 1.2. Khởi Tạo Tức Thì & Cờ `_isBusy` Chống Nghẽn RAM
- Khởi tạo `PoseDetector` ngay từ `initState()` với model nhẹ nhất `PoseDetectionModel.base`.
- Camera sử dụng `ResolutionPreset.medium` và `enableAudio: false` để giảm 60% băng thông byte mảng ảnh.
- Luôn kiểm tra cờ `if (_isBusy || _isCapturing || !mounted) return;` trước khi nạp frame vào ML Kit.

### 1.3. Nguyên Lý Khớp Hiển Thị Động (Dynamic Visible Joints)
- **CẤM** phạt các khớp bị che khuất tự nhiên (như đầu gối, cổ chân khi người dùng ngồi hoặc chụp nửa người).
- Chỉ tính độ lệch trên những góc/khớp mà độ tin cậy trong khung hình đạt chuẩn (`likelihood >= minLikelihood`).

### 1.4. Cổng Xác Thực Thân Trên (Upper Body Visibility Gate)
- Bắt buộc phải phát hiện rõ các khớp thân trên cốt lõi (hai vai và hai khuỷu tay) mới được công nhận là có tư thế hợp lệ.
- Nếu người dùng chỉ đưa khuôn mặt lại gần camera mà không thấy vai/thân:
  - Bắt buộc giới hạn điểm trần ở mức an toàn (`faceOnlyMaxScore`).
  - Hiển thị trạng thái nhắc nhở: `"Step Back • Show Upper Body"`.
  - Tuyệt đối không kích hoạt bộ đếm Auto-Shutter.

### 1.5. Bảo Mật 100% Trên Thiết Bị (On-Device Privacy)
- 0% upload ảnh camera thô của người dùng lên Cloud.
- Quá trình nhận diện diễn ra trực tiếp trên RAM. Ảnh chụp thực tế được lưu thẳng vào Album `PoseNova AI` của điện thoại qua package `gal`.

### 1.6. Quy Chuẩn Zero AI Emoji
- Giao diện khung ngắm tuân thủ thẩm mỹ Editorial xa xỉ:
  - CẤM mọi emoji `✨`, `🔥`, `⚡`, `✦` và icon sparkle `Icons.auto_awesome`.
  - Dùng capsule pill viết hoa thanh lịch (`30 FPS AI`, `TARGET POSE`, `MATCH SCORE`).

---

## 2. Kiến Trúc Chiến Lược & Tách Biệt Tham Số (Strategy Pattern & Config)

Để thuật toán có thể tự do tiến hóa mà không "đóng khung" AI hay làm vỡ giao diện UI, hệ thống áp dụng mô hình **Strategy Pattern** và **Centralized Configuration**.

### 2.1. Cấu Hình Tập Trung (`PoseMatchingConfig`)
Mọi con số toán học **CẤM hardcode trong UI màn hình** (`pose_camera_screen.dart`), mà phải đọc từ:
[pose_matching_config.dart](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/core/ai/pose_matching_config.dart)

Các tham số có thể điều chỉnh linh hoạt:
- `minLikelihood`: Độ tin cậy tối thiểu của khớp (mặc định: `0.50`).
- `coordinateSmoothingAlpha`: Hệ số làm mượt tọa độ EMA (mặc định: `0.70`).
- `scoreSmoothingFactor`: Hệ số làm mượt điểm số giữa các frame (mặc định: `0.60`).
- `matchThreshold`: Ngưỡng điểm đạt dáng tương đồng (mặc định: `85.0%`).
- `cancelThreshold`: Ngưỡng điểm hủy đếm ngược nếu dáng bị lệch (mặc định: `70.0%`).
- `requiredMatchFrames`: Số frame giữ dáng liên tục để chụp tự động (mặc định: `8`).
- `toleranceAngleDeg`: Góc dung sai tự nhiên (mặc định: `15.0°`).
- `mildDiffFactor`: Hệ số phạt nhẹ trong vùng dung sai (mặc định: `0.30`).
- `steepDiffFactor`: Hệ số phạt ngoài vùng dung sai (mặc định: `0.85`).
- `minUpperBodyJoints`: Số khớp thân trên tối thiểu (mặc định: `4`).
- `faceOnlyMaxScore`: Điểm tối đa khi vi phạm cổng thân trên (mặc định: `35.0%`).

### 2.2. Chiến Lược Chấm Điểm Độc Lập (`PoseMatcherStrategy`)
Mọi giải thuật so khớp được cô lập trong file:
[pose_matcher.dart](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/core/ai/pose_matcher.dart)

- **`VectorAngleToleranceMatcher` (Mặc định):**
  Tính 8 góc vector bằng `atan2` và áp dụng đường cong dung sai tự nhiên:
  - Nếu `angleDiff <= toleranceAngleDeg`: phạt nhẹ với `mildDiffFactor`.
  - Nếu `angleDiff > toleranceAngleDeg`: phạt tăng dần với `steepDiffFactor`.
- **`UpperBodyPriorityMatcher` (Chiến lược mở rộng):**
  Gán trọng số cao hơn cho cánh tay/vai (`1.2` - `1.4`), giảm trọng số hông/gối khi chụp góc bán thân.
- **Dễ dàng thử nghiệm:** Khi muốn đổi sang tính khoảng cách Cosine Vector, Pose Embedding hoặc Euclidean Distance, chỉ cần tạo một class mới kế thừa `PoseMatcherStrategy` mà không cần sửa đổi bất kỳ dòng code nào trong Camera pipeline hay UI widget.

---

## 3. Giao Diện Khung Ngắm & Trải Nghiệm Tương Tác

1. **Hiển Thị Khung Xương Tức Thì (< 0.3s):**
   - Ở frame đầu tiên nhận được, nếu bộ nhớ đệm trước rỗng (`_previousPoints.isEmpty`), gán ngay tọa độ vào bộ vẽ mà không chờ tích lũy EMA.
2. **Thẻ Ảnh Mẫu (Target PiP):**
   - Kích thước mặc định `118 x 156 px` (bo góc 16px, viền trắng mảnh).
   - Cho phép chạm để phóng to lên `180 x 240 px` mượt mà qua `AnimatedContainer`.
3. **Căn Lề Tránh Chồng Lớp:**
   - Viên thuốc trạng thái `Scanning Pose...` căn lề phải động theo trạng thái mở rộng của Target (`right: _isTargetExpanded ? 205 : 145`).
