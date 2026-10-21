# PoseNova AI — Design System & CSS Token Mapping

Phong cách giao diện lấy cảm hứng từ **Neo-Brutalist Cyber-Streetwear**, kết hợp giữa nền lưới kỹ thuật (`grid-paper`) và độ tương phản màu sắc cao theo định dạng không gian màu `oklch`.

## 1. Typography (Phông chữ)
* **Primary Sans-Font:** `Archivo` (áp dụng cho toàn bộ tiêu đề, nhãn và nút bấm).
* **Monospace Font:** `JetBrains Mono` (áp dụng cho ID đơn hàng `#REQ-8452`, số phần trăm, số tiền và thông số kỹ thuật).

## 2. Color Tokens (Bảng màu OKLCH & Hex tương ứng)
Được ánh xạ trực tiếp từ CSS Web Production:
* `--background` (`oklch(96.24% .0239 163.15)`): Nền chính màu xanh mint kỹ thuật sáng (`#E5F8EE`).
* `--grid-line` (`oklch(91.41% .0471 161.73)`): Đường kẻ ô vuông bàn cờ (`20px x 20px`).
* `--vermilion` (`oklch(65.29% .2342 31.56)`): Màu Đỏ Cam chủ đạo cho nút CTA chính và trạng thái đang xử lý (`#FF3B1D` tương đương).
* `--cyber` (`oklch(80.99% .2141 151.77)`): Màu Xanh Ngọc Cyber cho bảo chứng ký quỹ (`100% Escrow Secured`) và mốc đã hoàn thành.
* `--acid` (`oklch(95.55% .2153 114.31)`): Màu Vàng Chanh Acid cho nhãn `IN REVIEW`.
* `--ink` (`oklch(0% 0 0)`): Màu đen tuyền cho viền sắc nét và chữ (`#000000`).
* `--paper` (`oklch(100% 0 0)`): Màu trắng tinh cho bề mặt thẻ (`#FFFFFF`).

## 3. Shadows & Borders (Hiệu ứng Khối & Viền)
* **Brutalist Hard Shadow:** `4px 4px 0 var(--ink)` (áp dụng cho các thẻ card milestone và hộp thông tin).
* **Sticker Offset Shadow:** `3px 3px 0 var(--ink)` (áp dụng cho các thẻ tag sản phẩm gắn trên ảnh).
* **Card Border:** Viền đen đặc `2px solid var(--ink)`.
* **Border Radius:** Bo góc tiêu chuẩn `--radius: .625rem` (10px) kết hợp góc vuông sắc cạnh tạo nét cá tính công nghiệp.



