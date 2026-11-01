---
name: 04-escrow-prisma-backend
description: Quy chuẩn kiến trúc Ký quỹ Escrow 30-30-40, 10 bảng dữ liệu cốt lõi trong Prisma Schema, dòng tiền bảo chứng và SLA giải ngân tự động.
---

# Skill: Escrow 30-30-40 & Prisma Schema Rules

Quy chuẩn kỹ thuật cho hệ thống Ký quỹ Escrow, mô hình dữ liệu PostgreSQL Prisma, và quy trình xử lý giao dịch bảo chứng dòng tiền C2C giữa Khách hàng và Stylist.

---

## 1. Hệ Thống 10 Bảng Dữ Liệu Cốt Lõi (`schema.prisma`)

Mọi truy vấn và migration phải tuân thủ nghiêm ngặt cấu trúc 10 bảng trong `Back-end/prisma/schema.prisma`:

1. **`User` (`users`):** Người dùng hệ thống với phân quyền `Role: CLIENT | STYLIST | ADMIN`, số đo hình thể (`heightCm`, `weightKg`), đánh giá trung bình `ratingAvg` và `totalReviews`.
2. **`Wallet` (`wallets`):** Ví tiền số hóa. Quản lý 3 cột số dư tách biệt:
   - `availableBalance`: Số dư khả dụng (có thể rút hoặc thanh toán).
   - `escrowLockedBalance`: Số dư đang bị khóa ký quỹ bảo chứng.
   - `totalWithdrawn`: Tổng số tiền đã rút về tài khoản ngân hàng.
3. **`Lookbook` (`lookbooks`):** Bộ sưu tập thời trang. Lưu trữ tọa độ 33 điểm mốc `poseLandmarksJson: Json` dạng JSONB nguyên bản (tuyệt đối không tách bảng phụ làm chậm truy vấn).
4. **`LookbookLike` (`lookbook_likes`):** Lưu trữ lượt thích lookbook (`unique([lookbookId, userId])`).
5. **`ProductTag` (`product_tags`):** Gắn thẻ sản phẩm thời trang affiliate (Shopee/Lazada) với tọa độ tương đối `posX`, `posY` trên ảnh Lookbook hoặc Milestone.
6. **`StylingRequest` (`styling_requests`):** Hợp đồng dịch vụ phối đồ `#REQ-XXXX`. Trạng thái: `PENDING_DEPOSIT` -> `IN_PROGRESS` -> `COMPLETED` | `ESCROW_FROZEN`.
7. **`RequestMilestone` (`request_milestones`):** 3 chặng phối đồ ký quỹ (Moodboard, AI Try-On, Final Lookbook) kèm hạn tự động giải ngân `autoReleaseAt`.
8. **`MilestoneSubmission` (`milestone_submissions`):** Lịch sử nộp bài từng chặng của Stylist (ảnh bàn giao, ghi chú, phiên bản nộp).
9. **`PaymentTransaction` (`payment_transactions`):** Sổ cái đối soát giao dịch tài chính (`ESCROW_DEPOSIT`, `MILESTONE_RELEASE`, `REFUND`, `WITHDRAWAL`).
10. **`Dispute` (`disputes`):** Khiếu nại tranh chấp khi Stylist và Khách không đạt thỏa thuận, đóng băng quỹ ký quỹ để admin đối soát.
- **Bảng phụ trợ `Review` (`reviews`):** Đánh giá 1-5 sao đính kèm điểm khớp dáng AI Pose (`poseMatchScore`) và ảnh chụp thực tế.

---

## 2. Quy Tắc Dòng Tiền Ký Quỹ Escrow (30% — 30% — 40%)

Cơ chế bảo vệ dòng tiền 100% giúp khách hàng an tâm đặt dịch vụ và Stylist được đảm bảo thù lao:

### 2.1. Phí Nền Tảng & Phân Bổ Net Payout
- **Phí sàn cố định:** `15%` (`platformFeeRate = 0.15`).
- **Stylist thực nhận (Net Payout):** `85%` tổng ngân sách hợp đồng (`totalBudget * 0.85`).
- Khi khách hàng nạp cọc 100% qua SePay VietQR:
  - Khóa `85%` tiền Net vào `escrowLockedBalance` của Stylist.
  - Tự động sinh đúng 3 dòng `RequestMilestone` trong cùng một ACID Database Transaction.

### 2.2. Tỷ Lệ Phân Bổ 3 Chặng Bắt Buộc
- **Mốc 1 (30% Gross):** `Moodboard & Concept Direction` (Khảo sát phong cách, bảng màu Hex từ Gemini 1.5 Flash).
- **Mốc 2 (30% Gross):** `AI Virtual Try-On & Pose Atelier` (Bản dựng đồ ướm thử 3D + Tư thế tạo dáng AI Pose).
- **Mốc 3 (40% Gross):** `Final Editorial Lookbook & Affiliate Shopping Links` (Lookbook hoàn thiện + Link mua sắm đồ thật).

### 2.3. Giải Ngân Từng Mốc Độc Lập
- Khi Khách hàng duyệt một mốc (`POST /api/v1/milestones/:id/approve`):
  - Chuyển số tiền Net của mốc đó từ `escrowLockedBalance` sang `availableBalance` của Stylist.
  - Chống double-approval (bấm đúp) bằng kiểm tra trạng thái mốc và khóa ACID Transaction.
  - Tự động mở khóa mốc tiếp theo sang trạng thái `ACTIVE`.
  - Mốc cuối cùng hoàn tất sẽ tự động chuyển `StylingRequest` sang trạng thái `COMPLETED`.

---

## 3. Chính Sách Sửa Bài & SLA Tự Động Giải Ngân (48h Auto-Release)

1. **Giới Hạn Sửa Bài Miễn Phí (Revision Quota Cap):**
   - Mỗi mốc tối đa **2 lần yêu cầu sửa miễn phí** (`maxRevisions = 2`).
   - Nếu `revisionCount >= 2`: hệ thống chặn lại và bắt buộc Khách hàng phải Duyệt bài hoặc mở Khiếu nại (Dispute).

2. **Hẹn Giờ SLA 48h (Auto-Release Cronjob):**
   - Khi Stylist nộp bài mốc (`POST /api/v1/milestones/:id/submit`), hệ thống đặt `autoReleaseAt = now() + 48 hours`.
   - Cronjob (`src/jobs/sla-auto-release.job.ts`) quét định kỳ: Nếu quá 48h mà Khách hàng không phản hồi, hệ thống tự động duyệt mốc và giải ngân tiền cho Stylist để bảo vệ quyền lợi lao động sáng tạo.

3. **Chính Sách Hoàn Tiền Khi Tranh Chấp (Dispute & Refund):**
   - Khi mở khiếu nại (`POST /api/v1/disputes`): Hợp đồng chuyển sang `ESCROW_FROZEN`.
   - **Stylist giữ nguyên 100% số tiền các mốc đã được duyệt trước đó.**
   - Phần tiền ký quỹ của các mốc chưa duyệt (70% hoặc 40%) được hoàn lại vào ví của Khách hàng.

