# PoseNova AI — Editorial High-Fashion Design System & Architecture

> **Artistic Direction:** Sự giao thoa giữa **Wavespace Editorial Fashion** (Collage Polaroid nghiêng 3D, nghệ thuật sắp đặt chữ Highlighted Typography, tương tác vật lý Haptic Spring) và **Munna Rahman Aesthetic** (Không gian ngập tràn sắc hồng Sakura Pink mộng mơ kết hợp sắc cam hoàng hôn Sunset Orange rực rỡ).  
> **Nguyên tắc cốt lõi:** **100% Pure Human-Crafted Editorial Typography** — Tuyệt đối loại bỏ toàn bộ emoji trang trí (`✨`, `🔥`, `⚡`, `✦`, `👋`) và icon sparkle AI rẻ tiền (`Icons.auto_awesome`), thay bằng kiểu chữ Haute Couture sắc sảo, tối giản và cao cấp.

---

## 1. Triết lý Thiết kế (Design Philosophy)

1. **Editorial High-Fashion, Not Tech Demo:**  
   Giao diện không mang cảm giác một ứng dụng AI kỹ thuật khô khan hay một sàn thương mại điện tử đại trà, mà giống như một tạp chí thời trang kỹ thuật số xa xỉ (Digital Fashion Lookbook).
2. **Blush Pink Dominant Atmosphere:**  
   Toàn bộ không gian được bao bọc bởi nền hồng Sakura mềm mại (`#FDF2F7`), điểm xuyết các đốm sáng hào quang khuếch tán (Pastel Flamingo Pink `#FBCFE8` và Peach Glow `#FED7AA`).
3. **Zero Dark Borders & Clean Depth:**  
   Xóa bỏ hoàn toàn viền đen dày cộp và nền xanh petrol tối. Chiều sâu được tạo dựng bằng bóng kép đa tầng (Dual-layer Ambient Shadow) và quầng sáng đổi màu theo trang phục (`Ambient Colored Glow`).
4. **Tactile Haptic Feedback:**  
   Mọi phần tử tương tác (thẻ Lookbook, category pill, nút chụp ảnh, nút yêu cầu) đều phản hồi bằng hiệu ứng nén đàn hồi vật lý tự nhiên (`SpringInteractiveCard` với `Curves.easeOutCubic`).

---

## 2. Typography System (Hệ Thống Phông Chữ)

PoseNova AI sử dụng hai phông chữ tuyển chọn đặc quyền:

### 2.1. Primary Editorial Font — `Plus Jakarta Sans` (Google Fonts)
Áp dụng cho toàn bộ tiêu đề, nhãn danh mục, nội dung bài viết và nút hành động:
* **Display / Huge Headlines:** `fontSize: 26 - 32px`, `FontWeight.w900`, `letterSpacing: -0.8` đến `-0.6`. Mang nét tự tin, đậm chất bìa tạp chí Vogue / Dazed.
* **Section Titles:** `fontSize: 18 - 22px`, `FontWeight.w900`, `letterSpacing: -0.5`, màu Deep Ink `#1E1B18`.
* **Editorial Capsule Stickers:** `fontSize: 9.5 - 10.5px`, `FontWeight.w800`, `letterSpacing: 0.8` (Uppercase hoàn toàn: `"STREETWEAR"`, `"CYBER AW26"`, `"30 FPS POSE"`, `"VERIFIED"`).
* **Body / Subtitles:** `fontSize: 12 - 13.5px`, `FontWeight.w600`, màu Muted Espresso `#7A7067`.

### 2.2. Monospace Telemetry Font — `JetBrains Mono`
Áp dụng riêng cho các thông số kỹ thuật, ký quỹ tài chính và camera telemetry:
* **Mã đơn hàng Escrow:** `#REQ-8452`, `#ORD-2026` (`FontWeight.w800`, `letterSpacing: 0.5`).
* **Số tiền & Tỷ lệ mốc Escrow:** `2.500.000₫`, `30% — 30% — 40%`.
* **Camera AI Telemetry:** `30 FPS`, `33 Keypoints`, `98% Pose Match`.

---

## 3. Color Tokens & Signature Gradients (Hệ Màu & Gradient)

### 3.1. Backgrounds & Mesh Aura Glow
| Token Name | Hex Code | Ứng Dụng |
| :--- | :--- | :--- |
| `canvas` / `sakuraPink` | `#FDF2F7` | Nền canvas chính toàn bộ màn hình |
| `pastelFlamingo` | `#FBCFE8` | Hào quang hồng phấn, thẻ highlight chữ "Iconic" nghiêng |
| `peachGlow` | `#FED7AA` | Ánh sáng cam đào ấm áp khuếch tán |
| `paper` / `card` | `#FFFFFF` | Nền thẻ trắng tinh khôi (92% - 100% Opacity) |
| `hairlineBorder` | `#FFF0F3` | Viền hairline siêu mảnh 1.0px (không viền đen) |

### 3.2. Text & Surface Inks
| Token Name | Hex Code | Ứng Dụng |
| :--- | :--- | :--- |
| `ink` / `textPrimary` | `#1E1B18` | Màu chữ chính (Deep Warm Espresso), thay thế toàn bộ màu đen gắt |
| `textMuted` | `#7A7067` | Chữ phụ, tên tác giả, thông số phụ |
| `deepRoseText` | `#E11D48` | Chữ pill nổi bật, badge cảnh báo thanh lịch |

### 3.3. Signature Gradients
* **Primary Pop Gradient (CTA & Active States):**  
  `LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFFF6B35)])`  
  *Sắc chuyển từ Rose Coral sang Electric Sunset Orange.* Áp dụng cho nút "Chụp Dáng AI →", "Gửi Yêu Cầu Phối Đồ →", Active Category Pill.
* **Hero Banner Gradient (Flamingo to Sunshine):**  
  `LinearGradient(colors: [Color(0xFFF472B6), Color(0xFFFB923C), Color(0xFFFBBF24)])`  
  *Dải màu hoàng hôn rực rỡ.* Áp dụng cho Hero Banner, thẻ ví tiền Stylist Payout.
* **Soft Rose-Gold Gradient:**  
  `LinearGradient(colors: [Color(0xFFFBCFE8), Color(0xFFFED7AA)])`  
  Áp dụng cho các huy hiệu VIP và đường tiến trình mốc.

### 3.4. Ambient Colored Glows (Bóng hào quang đổi màu theo trang phục)
* **Cyber Amber Outfit:** `Color(0x3DFB923C)` (Cam đào ấm)
* **Techwear Street Outfit:** `Color(0x38F43F5E)` (Hồng hoa hồng phát quang)
* **Neo Mint / Acid Pop:** `Color(0x3810B981)` (Xanh bạc hà phát quang)
* **Neo Kimono / Luxury:** `Color(0x38A855F7)` (Tím oải hương Lavender)

### 3.5. Status & Escrow Trust Accents
* **Escrow 100% Secured:** `#10B981` (Emerald Cyber Green)
* **Dispute / Action Required:** `#EF4444` (Crimson Rose)
* **In Review / Processing:** `#FB923C` (Warm Sunset Amber)

---

## 4. Shadow & Elevation System (Hệ Thống Bóng Đổ)

1. **Card Ambient Shadow:**  
   `BoxShadow(color: Color(0x0D8A4F60), offset: Offset(0, 8), blurRadius: 24)`  
   Bóng mờ tán xạ sắc hồng ấm, tạo cảm giác thẻ lơ lửng nhẹ trên nền vải lụa.
2. **Primary Button Glow Shadow:**  
   `BoxShadow(color: Color(0x40F43F5E), offset: Offset(0, 6), blurRadius: 16)`  
   Quầng sáng ấm rực rỡ phát ra dưới chân các nút CTA gradient chính.
3. **Pill Elevation Shadow:**  
   `BoxShadow(color: Color(0x0A8A4F60), offset: Offset(0, 2), blurRadius: 8)`  
   Bóng nổi nhẹ 2px cho các category pills và nút tròn header.

---

## 5. Quy Tắc "Zero AI Emoji / Pure Editorial Typography"

Toàn bộ ứng dụng tuân thủ nghiêm ngặt chuẩn mực Typography thời trang cao cấp:
1. **Tuyệt đối cấm sử dụng:**
   - Emojis: `✨`, `🔥`, `⚡`, `✦`, `🏷️`, `📷`, `👤`, `📏`, `👋`.
   - AI Sparkle Icons: `Icons.auto_awesome`.
2. **Chuẩn hóa chữ thay thế:**
   - Top-left sticker trên ảnh: Uppercase text pill + `letterSpacing: 0.8`, `10px` Bold: `"STREETWEAR"`, `"CYBER AW26"`, `"30 FPS POSE"`, `"VERIFIED"`.
   - Header chào hỏi: `"Hey, Alex"` (không emoji vẫy tay `👋`).
   - Nút chuyển vai trò Header: `"Stylist"` hoặc `"Client"` (không dấu chấm tròn hay mũi tên `● ⇄`).
   - Nút Gemini Assist: `"Gemini Co-pilot Enhance"` (thuần text sang trọng).
   - Trạng thái Camera: `"Pose Matched (94%)"` (không dùng tia sét `⚡`).

---

## 6. Luồng Nghiệp Vụ & Kiến Trúc Màn Hình (Screen Architecture)

### 6.1. Screen 01: Lookbook Discovery Feed (`discovery_feed_screen.dart`)
* **Mục đích:** Khám phá phong cách thời trang, gợi ý phối đồ từ các Stylist và hướng dẫn tạo dáng chụp ảnh AI hoàn toàn miễn phí.
* **Top Header:** Logo `PoseNova` tinh tế, nút chuyển nhanh vai trò (`Stylist`), nút chuông và túi mua sắm dạng phím tròn Spring.
* **Hero Banner Collage:** 
  - Banner nền Sunset Gradient kết hợp 2 ảnh Polaroid nghiêng 3D (`-5.2°` và `+3.5°`) phá vỡ khung viền (Break-the-box depth).
  - Huy hiệu text-only: `"50% FASTER FIT"`, `"LIVE FIT"`, `"98% AI MATCH"`.
* **Thẻ Kêu Gọi Đặt Stylist Riêng (Custom Personal Styling Brief Card):**
  - Tách bạch quy trình dịch vụ ra khỏi Lookbook miễn phí.
  - Headline: `"Cần Phối Đồ Riêng Theo Vóc Dáng?"`.
  - Subtitle: `"Gửi yêu cầu cho Stylist • Bảo vệ 100% qua Ký quỹ Escrow"`.
  - Nút bấm: `"Gửi Yêu Cầu Phối Đồ →"` mở trực tiếp Screen 03.
* **Staggered Masonry Grid 2 Cột:**
  - Cột phải thụt xuống 24px (`SizedBox(height: 24)` chống tràn layout).
  - Thẻ Lookbook ảnh sạch 100% (không che badge đen ở góc dưới ảnh).
  - Thông tin Creator & đồ phối: Avatar + `"Maya Trần • 3 Items"`.
  - **Nút bấm duy nhất full-width:** `"Chụp Dáng AI →"` (`height: 36px`, gradient Rose-to-Orange, giải quyết triệt để lỗi tràn pixel).

### 6.2. Screen 02: AI Pose Camera HUD (`pose_camera_screen.dart`)
* **Mục đích:** Hướng dẫn người dùng tạo dáng chụp ảnh chuẩn xác theo khung xương người mẫu thời trang.
* **Công nghệ:** MediaPipe Pose Detection 33 Landmarks thời gian thực (30 FPS).
* **HUD Overlay:**
  - Viên nhộng trạng thái: `"Scanning Pose... (30 FPS)"` chuyển sang `"Pose Matched (94%)"`.
  - Vòng tròn chỉ số khớp dáng hiển thị độ tương thích tức thì.
  - Khung ngắm chụp phong cách Runway Viewfinder.

### 6.3. Screen 03: Styling Brief & Escrow Booking (`create_styling_request_screen.dart`)
* **Mục đích:** Khách hàng tạo brief yêu cầu phối đồ cá nhân hóa theo số đo hình thể và ngân sách.
* **Tính năng:**
  - Nhập mô tả phong cách + Nút hỗ trợ `"Gemini Co-pilot Enhance"` tối ưu hóa brief cho khớp dáng 3D.
  - Bộ chọn ngân sách với phân bổ 3 mốc Escrow minh bạch (`30% Concept` — `30% AI Try-On` — `40% Final Lookbook`).
  - Lựa chọn Stylist hàng đầu bảo chứng qua Ký quỹ Escrow.

### 6.4. Screen 04: Escrow Milestone Workspace (`milestone_workspace_screen.dart`)
* **Mục đích:** Không gian làm việc chung giữa Client và Stylist, bảo vệ tiền cọc 100% qua hợp đồng thông minh Escrow.
* **Cơ chế giải ngân 3 giai đoạn:**
  - **Mốc 1 (30%):** Moodboard & Định hình Concept.
  - **Mốc 2 (30%):** Bản dựng AI Virtual Try-On & Tạo dáng AI Pose Ready.
  - **Mốc 3 (40%):** Trả Lookbook hoàn thiện + Link mua sắm affiliate.
* **Bảo mật:** Mở khóa giải ngân tiền cho Stylist qua xác thực mã OTP / Biometrics an toàn.

### 6.5. Screen 05: Stylist Studio Inbox (`stylist_inbox_screen.dart`)
* **Mục đích:** Bảng điều khiển quản lý đơn hàng dành cho Stylist chuyên nghiệp.
* **Thẻ Khách Hàng Chuẩn Mực (Client Profile Card):**
  - Hiển thị thông số vóc dáng tinh tế: `"175 cm  •  65 kg  •  Streetwear AW26"`.
  - Không lặp từ ngữ, không dùng emoji dư thừa.
  - Tích hợp trợ lý Gemini Co-pilot gợi ý bảng phối đồ nhanh trong 1 chạm.

---

## 7. Quy Chuẩn Kỹ Thuật (Engineering Conventions)

1. **Không can thiệp hardcoded màu teal/xanh đậm:** Toàn bộ màu phải trỏ về `AppColors.*` trong [app_colors.dart](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/core/theme/app_colors.dart).
2. **Phòng tránh lỗi tràn RenderFlex (Zero Overflow Policy):**
   - Không đặt nhiều phần tử động dài vào cùng một `Row` cố định trên thẻ hẹp (cột lưới < 160px).
   - Luôn sử dụng nút Full-Width `double.infinity` hoặc bọc text bằng `Expanded` kết hợp `maxLines` và `TextOverflow.ellipsis`.
   - Đối với Masonry Grid so le, dùng `SizedBox(height: 24)` ở đầu cột thay vì `Transform.translate` để Flutter tính toán chính xác chiều cao scroll, kết hợp `padding: EdgeInsets.only(bottom: 140)` để tránh bị che bởi thanh Floating Navigation Bar.
3. **Kiểm thử chất lượng:**
   - Mọi thay đổi mã nguồn bắt buộc phải vượt qua `flutter analyze lib` (0 issues) và `flutter test`.
