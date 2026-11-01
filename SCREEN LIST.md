# PoseNova AI — Danh Sách & Kiến Trúc Màn Hình (Screen List)

Hệ thống ứng dụng di động **PoseNova AI** bao gồm 2 vai trò chính (**Client / Người dùng thời trang** và **Stylist Studio / Nhà tạo mẫu**) kết nối trực tiếp với nhau thông qua cơ chế ký quỹ thông minh (Escrow).

---

## 1. Màn Hình Khởi Động & Xác Thực (Auth & Onboarding)

| Mã màn hình | Tên màn hình | Tệp nguồn (Source File) | Vai trò | Chức năng chính |
| :--- | :--- | :--- | :--- | :--- |
| **SCR-00A** | **Login & Quick Access** | [`login_screen.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/auth/login_screen.dart) | Chung | Đăng nhập tài khoản, nút tắt vào thẳng vai trò Client hoặc Stylist Studio (Maya Trần), chuyển đổi ngôn ngữ EN/VI. |
| **SCR-00B** | **Role Selection** | [`role_selection_screen.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/role_selection_screen.dart) | Chung | Lựa chọn vai trò: Khách hàng tìm kiếm phong cách (Client) hoặc Chuyên gia phối đồ kiếm thu nhập (Stylist Studio). |

---

## 2. Giao Diện Khách Hàng (Client Main Shell)
Quản lý bởi Shell điều hướng: [`client_main_shell.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/client_main_shell.dart)

| Mã màn hình | Tên màn hình | Tệp nguồn (Source File) | Tab điều hướng | Chức năng chính |
| :--- | :--- | :--- | :--- | :--- |
| **SCR-01** | **Lookbook Discovery** | [`discovery_feed_screen.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/discovery_feed_screen.dart) | Tab 0: `Lookbook` | Khám phá cảm hứng phối đồ miễn phí theo dạng lưới so le (Masonry Grid), thẻ riêng biệt *"Cần Phối Đồ Riêng?"*, nút *"Chụp Dáng AI →"* kích hoạt tạo dáng chuẩn theo từng lookbook. |
| **SCR-02** | **AI Pose Camera HUD** | [`pose_camera_screen.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/pose_camera_screen.dart) | Tab 1: `Chụp Dáng` | Quét khung xương người mẫu 33 Landmarks thời gian thực (MediaPipe Pose 30 FPS), hiển thị tỷ lệ khớp dáng (Pose Match %), hướng dẫn góc chụp chuẩn runway. |
| **SCR-03** | **Styling Brief Creation** | [`create_styling_request_screen.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/create_styling_request_screen.dart) | Modal / Deep link | Khách hàng tạo yêu cầu phối đồ riêng theo số đo hình thể cá nhân, tối ưu brief qua Gemini Co-pilot, lựa chọn ngân sách và cọc tiền vào Escrow. |
| **SCR-04** | **Milestone Workspace** | [`milestone_workspace_screen.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/milestone_workspace_screen.dart) | Tab 2: `Ký Quỹ` | Không gian làm việc tiến độ 3 mốc (30% Concept — 30% AI Try-On — 40% Final Lookbook), duyệt sản phẩm và mở khóa giải ngân cọc qua OTP. |
| **SCR-06** | **Escrow Checkout** | [`escrow_checkout_screen.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/escrow_checkout_screen.dart) | Modal | Nạp tiền ký quỹ bảo chứng, xem bảng chi tiết giải ngân và cam kết hoàn tiền 100% nếu stylist không đạt yêu cầu. |

---

## 3. Giao Diện Stylist Chuyên Nghiệp (Stylist Studio Shell)
Quản lý bởi Shell điều hướng: [`stylist_main_shell.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/stylist_main_shell.dart)

| Mã màn hình | Tên màn hình | Tệp nguồn (Source File) | Tab điều hướng | Chức năng chính |
| :--- | :--- | :--- | :--- | :--- |
| **SCR-05** | **Stylist Inbox & Order Queue** | [`stylist_inbox_screen.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/stylist_inbox_screen.dart) | Tab 0: `Đơn Hàng` | Quản lý danh sách brief khách hàng gửi đến, xem thẻ số đo hình thể khách (`175 cm • 65 kg`), nhận đơn và sử dụng Gemini Co-pilot phối đồ nhanh. |
| **SCR-04S** | **Stylist Milestone Workroom** | [`milestone_workspace_screen.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/milestone_workspace_screen.dart) | Tab 1: `Dự Án` | Đăng tải concept mốc 1, ảnh AI Try-On mốc 2 (gắn tag sản phẩm affiliate), nhận thông báo tiền về ví ký quỹ khi khách hàng duyệt mốc. |
| **SCR-07** | **Stylist Earnings & Payout** | [`stylist_inbox_screen.dart`](file:///d:/KY%208/prm/POSENOVAAI/APP/Pose-Nova-AI/Front-end/lib/presentation/screens/stylist_inbox_screen.dart) | Tab 2: `Ví Thu Nhập` | Quản lý số dư đã giải ngân, theo dõi doanh thu hoa hồng affiliate bán đồ và yêu cầu rút tiền về tài khoản ngân hàng. |
