---
name: 01-editorial-design-system
description: Quy chuẩn thiết kế High-Fashion Editorial, bảng màu Sakura Pink & Sunset Orange, typography và luật Zero AI Emoji tuyệt đối cho PoseNova AI.
---

# Skill: Editorial High-Fashion UI & Zero Emoji

> **Artistic Direction:** Sự giao thoa giữa **Wavespace Editorial Fashion** (Collage Polaroid nghiêng 3D, nghệ thuật sắp đặt chữ Highlighted Typography, tương tác vật lý Haptic Spring) và **Munna Rahman Aesthetic** (Không gian ngập tràn sắc hồng Sakura Pink mộng mơ kết hợp sắc cam hoàng hôn Sunset Orange rực rỡ).

---

## 1. Triết lý Thiết kế Cốt lõi

1. **Editorial High-Fashion, Not Tech Demo:**  
   Giao diện mang cảm giác một tạp chí thời trang kỹ thuật số xa xỉ (Digital Fashion Lookbook Vogue / Dazed), không mang dáng dấp ứng dụng AI kỹ thuật khô khan hay sàn thương mại điện tử đại trà.
2. **Blush Pink Dominant Atmosphere:**  
   Toàn bộ không gian được bao bọc bởi nền hồng Sakura mềm mại (`#FDF2F7`), điểm xuyết các đốm sáng hào quang khuếch tán (Pastel Flamingo Pink `#FBCFE8` và Peach Glow `#FED7AA`).
3. **Zero Dark Borders & Clean Depth:**  
   Xóa bỏ hoàn toàn viền đen dày cộp và nền xanh petrol tối. Chiều sâu được tạo dựng bằng bóng kép đa tầng (Dual-layer Ambient Shadow) và quầng sáng đổi màu theo trang phục (`Ambient Colored Glow`).
4. **Tactile Haptic Feedback:**  
   Mọi phần tử tương tác (thẻ Lookbook, category pill, nút chụp ảnh, nút yêu cầu) đều phản hồi bằng hiệu ứng nén đàn hồi vật lý tự nhiên (`SpringInteractiveCard` với `Curves.easeOutCubic`).

---

## 2. Hệ Thống Màu Chuẩn (`AppColors.*`)

Tuyệt đối KHÔNG hardcode mã màu tùy tiện. Mọi màu sắc phải trỏ về `AppColors.*` trong `Front-end/lib/core/theme/app_colors.dart`.

### 2.1. Nền & Ánh Sáng Khuếch Tán
- **Nền chính:** `AppColors.canvas` / `AppColors.sakuraPink` (`#FDF2F7`)
- **Hào quang hồng:** `AppColors.pastelFlamingo` (`#FBCFE8`)
- **Hào quang đào:** `AppColors.peachGlow` (`#FED7AA`)
- **Nền thẻ (Surface):** `AppColors.paper` / `Colors.white` (92% - 100% Opacity)
- **Viền siêu mảnh (Hairline):** `AppColors.hairlineBorder` (`#FFF0F3`, độ dày `1.0px`)

### 2.2. Chữ & Bề Mặt
- **Màu chữ chính:** `AppColors.ink` (`#1E1B18` - Deep Warm Espresso, thay thế hoàn toàn màu đen `#000000`)
- **Chữ phụ & Thông số phụ:** `AppColors.textMuted` (`#7A7067`)
- **Accent Rose:** `AppColors.deepRoseText` (`#E11D48`)

### 2.3. Gradient Thương Hiệu Đặc Quyền
- **Primary Pop Gradient (CTA & Active States):**  
  `LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFFF6B35)])`  
  *Sắc chuyển từ Rose Coral sang Electric Sunset Orange.* Áp dụng cho nút "Chụp Dáng AI →", "Gửi Yêu Cầu Phối Đồ →", Active Category Pill.
- **Hero Banner Gradient:**  
  `LinearGradient(colors: [Color(0xFFF472B6), Color(0xFFFB923C), Color(0xFFFBBF24)])`  
  *Dải màu hoàng hôn rực rỡ.* Áp dụng cho Hero Banner, thẻ ví tiền Stylist Payout.
- **Soft Rose-Gold Gradient:**  
  `LinearGradient(colors: [Color(0xFFFBCFE8), Color(0xFFFED7AA)])`

### 2.4. Ambient Colored Glow (Hào quang trang phục)
- Cyber Amber Outfit: `Color(0x3DFB923C)`
- Techwear Street Outfit: `Color(0x38F43F5E)`
- Neo Mint / Acid Pop: `Color(0x3810B981)`
- Neo Kimono / Luxury: `Color(0x38A855F7)`

### 2.5. Trạng Thái Nghiệp Vụ & Escrow
- **Escrow Secured (Đã bảo chứng 100%):** `#10B981` (Emerald Cyber Green)
- **Dispute / Cảnh báo:** `#EF4444` (Crimson Rose)
- **In Review / Chờ duyệt:** `#FB923C` (Warm Sunset Amber)

---

## 3. Hệ Thống Typography Tuyển Chọn

1. **Phông Chữ Chính — `Plus Jakarta Sans`:**
   - **Headlines / Display:** `fontSize: 26 - 32px`, `FontWeight.w900`, `letterSpacing: -0.8` đến `-0.6`.
   - **Section Titles:** `fontSize: 18 - 22px`, `FontWeight.w900`, `letterSpacing: -0.5`, màu Deep Ink `#1E1B18`.
   - **Editorial Capsule Stickers:** `fontSize: 9.5 - 10.5px`, `FontWeight.w800`, `letterSpacing: 0.8` (Uppercase hoàn toàn: `"STREETWEAR"`, `"CYBER AW26"`, `"30 FPS POSE"`, `"VERIFIED"`).
   - **Body / Subtitles:** `fontSize: 12 - 13.5px`, `FontWeight.w600`, màu Muted Espresso `#7A7067`.

2. **Phông Chữ Kỹ Thuật Số — `JetBrains Mono`:**
   - Dùng riêng cho mã đơn (`#REQ-8452`), giá tiền (`2.500.000₫`), tỷ lệ mốc (`30% — 30% — 40%`) và telemetry (`30 FPS`, `98% Match`).

---

## 4. Quy Tắc "Zero AI Emoji" (Bắt Buộc Tuân Thủ 100%)

Toàn bộ ứng dụng tuân thủ nghiêm ngặt chuẩn mực Haute Couture:
- **TUYỆT ĐỐI CẤM:**
  - Emojis trang trí: `✨`, `🔥`, `⚡`, `✦`, `🏷️`, `📷`, `👤`, `📏`, `👋`.
  - Icon sparkle AI rẻ tiền: `Icons.auto_awesome`.
- **CHUẨN HÓA THAY THẾ:**
  - Sticker trên ảnh: Dùng Uppercase text pill (`"STREETWEAR"`, `"CYBER AW26"`, `"30 FPS POSE"`, `"VERIFIED"`).
  - Lời chào: `"Hey, Alex"` (không emoji vẫy tay `👋`).
  - Nút chuyển vai trò: `"Stylist"` hoặc `"Client"` (không dấu chấm tròn hay mũi tên `● ⇄`).
  - Nút Gemini Assist: `"Gemini Co-pilot Enhance"` (thuần text sang trọng).
  - Trạng thái Camera: `"Pose Matched (94%)"` (không dùng tia sét `⚡`).

---

## 5. Tương Tác Haptic & Bóng Đổ (Elevation)

- **Thẻ lơ lửng:** `BoxShadow(color: Color(0x0D8A4F60), offset: Offset(0, 8), blurRadius: 24)`.
- **Nút CTA phát sáng:** `BoxShadow(color: Color(0x40F43F5E), offset: Offset(0, 6), blurRadius: 16)`.
- **Hiệu ứng chạm:** Mọi thẻ Lookbook, nút CTA, icon header đều phải bọc trong `SpringInteractiveCard`.

