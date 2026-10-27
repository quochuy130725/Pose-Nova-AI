# ✨ PoseNova AI — AI Pose Atelier & Personal Styling C2C Marketplace

![Flutter](https://img.shields.io/badge/Flutter-00C2FF?style=for-the-badge&logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-58CC02?style=for-the-badge&logo=nodedotjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-4285FF?style=for-the-badge&logo=typescript&logoColor=white)
![Prisma](https://img.shields.io/badge/Prisma-BB5CFF?style=for-the-badge&logo=prisma&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-00D68F?style=for-the-badge&logo=supabase&logoColor=white)
![Google ML Kit](https://img.shields.io/badge/Google_ML_Kit-FF5C7A?style=for-the-badge&logo=google&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Gemini_AI-9B6DFF?style=for-the-badge&logo=googlegemini&logoColor=white)

> **"From Styling to Posing — Bridging the gap between what you wear and how you own the frame."**  
> **PoseNova AI** is a managed C2C Personal Styling Marketplace & AI Pose Atelier that connects fashion-forward **Clients** with independent **Personal Stylists** through **Real-Time 33-Landmark AI Pose Detection**, a **3-Stage Milestone Escrow System (`30% - 30% - 40%`)**, and **Visual Affiliate Commerce**.

---

## 📖 Table of Contents
1. [Problem Statement & Core Values](#-1-problem-statement--core-values)
2. [System Workflows Architecture](#-2-system-workflows-architecture)
3. [End-to-End Main Flow](#-3-end-to-end-main-flow)
4. [Financial Mechanics: 30-30-40 Escrow & Dispute Engine](#-4-financial-mechanics-30-30-40-escrow--dispute-engine)
5. [On-Device AI Camera & Privacy Architecture](#-5-on-device-ai-camera--privacy-architecture)
6. [Database Schema & Entity Relationships](#-6-database-schema--entity-relationships)
7. [RESTful API Specification](#-7-restful-api-specification)
8. [Project Directory Structure](#-8-project-directory-structure)
9. [Getting Started & Installation](#-9-getting-started--installation)
10. [5-Minute Evaluation & Demo Script](#-10-5-minute-evaluation--demo-script)

---

## 🎯 1. Problem Statement & Core Values

Traditional C2C personal styling suffers from three critical bottlenecks: clients buy great outfits but fail to look good in photos due to poor posture; freelance stylists face unpaid labor and endless revision loops; and creators lack sustainable passive income. **PoseNova AI** solves these via three pillars:

### Pillar 1: "From Styling to Posing" (Last-Mile Visual Fulfillment)
* **The Problem:** Knowing *what* to wear is only half the battle; knowing *how to pose* to flatter the garment's silhouette is what creates confidence.
* **The Solution:** Powered by **Google ML Kit Pose Detection (33 Skeletal Landmarks @ 30 FPS)**, PoseNova AI extracts pose templates directly from a Stylist's Lookbook and overlays an interactive skeletal guide onto the Client's live camera viewfinder.

### Pillar 2: "Fair Labor & Two-Way Trust" (30-30-40 Milestone Escrow)
* **The Problem:** In informal C2C transactions, clients fear paying upfront for low-effort advice, while stylists suffer from ghosting, scope creep, and infinite revisions.
* **The Solution:** A smart **3-Stage Milestone Contract (`30% Moodboard` → `30% Outfits & Tags` → `40% Final Lookbook & Pose`)** combined with a strict **Maximum Revision Quota (`Max Revisions = 2` per stage)** and **Partial Dispute Refunds**. Approved stages are irreversibly paid out to the Stylist, while unapproved remaining stages are automatically refunded to the Client upon dispute.

### Pillar 3: "Dual-Revenue Creator Economy" (Visual Affiliate Monetization)
* **The Problem:** Relying solely on 1-on-1 styling fees limits a stylist's scalability.
* **The Solution:** Stylists earn **Active Income** (85% Net Payout from styling contracts) alongside **Passive Income** by pinning interactive **Affiliate Product Tags** (Shopee, Zara, TikTok Shop) directly onto public and custom Lookbooks via an automated OpenGraph metadata scraper.

---

## 🔄 2. System Workflows Architecture

The platform operates across **4 specialized workflows**, with **Workflow 3 serving as the Core Business & Transaction Engine**:

```text
[Workflow 1: Discovery & AI Pose Camera]
                    |
                    v
[Workflow 3: Styling Brief & 30-30-40 Escrow] <--- [Workflow 2: Lookbook & Affiliate Tagging]
                    |
                    v
[Workflow 4: Revision Quota & Dispute Resolution]
```

### 🏗️ Core Workflows & System Architecture

| Workflow | Name | Role in Ecosystem | Key Technical Components |
|---|---|---|---|
| **Workflow 1** | Discovery & AI Pose Camera | **Top-of-Funnel Hook:** Users browse curated lookbooks (Streetwear, Cyber AW26, Y2K Pop), inspect affiliate items, and test poses in real time. | `google_mlkit_pose_detection`, 30 FPS RAM Stream, Cosine/Euclidean Joint Angle Matching, Local Gallery Save (`gal`). |
| **Workflow 2** | Lookbook Publishing & Affiliate | **Supply-Side Engine:** Stylists upload outfit photos, validate human skeletal landmarks, and pin affiliate product links. | Automated OpenGraph Scraper (title, price, thumbnail), 33-Node JSONB Extractor, Normalized `(x, y)` Coordinates. |
| **Workflow 3 ⭐** | **3-Stage Styling & Escrow** | **CORE BUSINESS FLOW:** End-to-end custom styling request, AI brief enhancement, 100% VietQR escrow deposit, and rolling 30-30-40 payouts. | Gemini AI Co-pilot, SePay VietQR Webhook, Prisma Interactive ACID Transactions, Pessimistic Wallet Locking. |
| **Workflow 4** | Revision Quota & Dispute | **Risk Mitigation:** Enforces the 2-revision cap, freezes escrow funds upon conflict, and executes automated partial refunds. | Revision Counter State Machine, `ESCROW_FROZEN` Lock, 48-Hour SLA Auto-Release Cronjob. |

### 🛣️ 3. End-to-End Main Flow

The complete Happy Path journey connecting the Client (Alex Đỗ), the System & AI Engine, and the Stylist (Maya Trần).

```text
[STEP 1: DISCOVERY & AI POSE TRIAL]
  └── Client browses Staggered Lookbooks & tests 33-Landmark AI Pose Camera (30 FPS)
                  |
                  v
[STEP 2: STYLING BRIEF & 100% ESCROW DEPOSIT]
  ├── Client inputs body metrics (175cm, 65kg), occasion & budget (2,500,000 VND)
  ├── Gemini AI Co-pilot refines brief & generates 4-color hex palette
  └── Client scans SePay VietQR → System locks 100% fund in Escrow (ESCROW_LOCKED)
                  |
                  v
[STEP 3: STYLIST 3-STAGE MILESTONE EXECUTION]
  ├── Stage 01 (30%): Deliver Moodboard, Vibe & Color Concept
  ├── Stage 02 (30%): Deliver Outfit Curation + Pin Affiliate Product Tags
  └── Stage 03 (40%): Deliver Final Lookbook + Extract 33 AI Pose Landmarks
                  |
                  v
[STEP 4: ROLLING APPROVAL & AUTOMATED ESCROW DISBURSEMENT]
  ├── Client approves Stage 01 → Release 30% Net (637.5K) to Stylist & Unlock Stage 02
  ├── Client approves Stage 02 → Release 30% Net (637.5K) to Stylist & Unlock Stage 03
  ├── Client approves Stage 03 → Release 40% Net (850.0K) to Stylist & Unlock Custom Pose
  └── Exception: If revisions exceed 2 without agreement → Freeze Escrow & Refund unapproved funds
                  |
                  v
[STEP 5: FINAL AI POSE SHOOT & BANK PAYOUT]
  ├── Client shoots final outfit using custom 33-node skeleton (Saved to Phone Gallery)
  ├── Client submits a 1–5 star rating for the Stylist
  └── Stylist wallet receives 100% of net earnings (2,125,000 VND) → 1-Tap Bank Withdrawal
```

### 💰 4. Financial Mechanics: 30-30-40 Escrow & Dispute Engine

#### A. Milestone Disbursement Breakdown

**Example contract:** 2,500,000 VND

- **Platform Commission Fee:** 15% (375,000 VND total)
- **Stylist Guaranteed Net Payout:** 85% (2,125,000 VND total)

| Stage | Deliverable Scope | Allocation | Gross Amount | Platform Fee (15%) | Stylist Net Payout (85%) | Trigger Condition |
|---|---|---:|---:|---:|---:|---|
| Stage 01 | Moodboard & Concept (color palette, vibe, silhouette direction) | 30% | 750,000 VND | 112,500 VND | 637,500 VND | Instant payout upon Client approval |
| Stage 02 | Outfit Selection & Affiliate Tags (garment curation and shoppable links) | 30% | 750,000 VND | 112,500 VND | 637,500 VND | Instant payout upon Client approval |
| Stage 03 | Final Lookbook & 33 AI Pose Nodes (visual guide and custom skeleton) | 40% | 1,000,000 VND | 150,000 VND | 850,000 VND | Client approval or 48-hour SLA auto-release |
| **Total** | **Full 3-Stage Contract (#REQ-8452)** | **100%** | **2,500,000 VND** | **375,000 VND** | **2,125,000 VND** | **100% Balanced Ledger** |

#### B. Mathematical Invariant & Ledger Integrity

Every financial operation executes inside an interactive PostgreSQL ACID transaction (`prisma.$transaction`), enforcing the following conservation invariant:

```text
Total Deposit
= Total Net Payouts
+ Total Platform Fees
+ Escrow Locked Balance
+ Dispute Refunds
```

#### C. Revision Quota & Partial Dispute Refund Rule

- **Revision Tracking:** Each stage allows at most 2 free revisions (`revision_count`: `0 → 1 → 2`).
- **Dispute Activation:** When the revision quota is exhausted and the Client remains unsatisfied, the dispute and refund action becomes available.
- **Stylist Protection:** The Stylist retains the 637,500 VND net payout already earned from an approved Stage 01.
- **Client Protection:** If a dispute occurs at Stage 02, the unapproved Stage 02 (30%) and Stage 03 (40%) funds, totaling 1,750,000 VND, are frozen and refunded to the Client.
- **Escrow State:** Disputed funds transition to `ESCROW_FROZEN` until the refund process is resolved.
### 📸 5. On-Device AI Camera & Privacy Architecture

PoseNova AI is designed around a Privacy-First, Edge-Computing Vision Pipeline.

| Component | Implementation | Privacy Guarantee |
|---|---|---|
| Real-Time Pose Detection | `google_mlkit_pose_detection`, 30 FPS | Camera frames are processed in volatile device RAM during live pose matching; raw preview frames are not written to disk or uploaded to external servers. |
| Local Photo Storage | `gal` package | Captured high-resolution photos are saved directly to the smartphone's native photo album (`DCIM/PoseNova`). |
| Cloud Upload | Strict opt-in | Personal photos remain on-device unless the Client explicitly attaches a photo to a review or opts in to sharing on the community feed. |
### 🗄️ 6. Database Schema & Entity Relationships

The PostgreSQL database is structured around the following core entities, managed through Prisma ORM.

```text
[users] 1 ────────── 1 [wallets]
   |
   ├── 1 ────────── * [lookbooks]
   |                      └── 1 ──── * [product_tags]
   |
   └── 1 ────────── * [styling_requests]
                           ├── 1 ──── 3 [request_milestones]
                           ├── 1 ──── * [payment_transactions]
                           └── 1 ──── 1 [disputes]
```

| Table | Primary Key | Key Columns | Business Responsibility |
|---|---|---|---|
| `users` | `id` (UUID) | `email`, `full_name`, `role`, `height_cm`, `weight_kg`, `rating_avg` | Stores Client and Stylist profiles and body metrics. |
| `wallets` | `id` (UUID) | `user_id`, `available_balance`, `escrow_locked_balance`, `bank_name`, `bank_account_no` | Tracks withdrawable earnings and funds locked in active milestones. |
| `lookbooks` | `id` (UUID) | `stylist_id`, `title`, `style_category`, `image_url`, `pose_landmarks_json` | Stores editorial outfits and 33-node skeletal coordinates. |
| `product_tags` | `id` (UUID) | `lookbook_id`, `milestone_id`, `product_name`, `price`, `affiliate_url`, `pos_x`, `pos_y` | Stores interactive affiliate pins on lookbook and milestone images. |
| `styling_requests` | `id` (UUID) | `code`, `client_id`, `stylist_id`, `brief_text`, `ai_palette_json`, `total_budget`, `status` | Stores custom styling contracts. |
| `request_milestones` | `id` (UUID) | `request_id`, `stage_order`, `percentage`, `gross_amount`, `net_payout`, `revision_count`, `status` | Controls stage deliverables, revision limits, and 48-hour SLA timers. |
| `payment_transactions` | `id` (UUID) | `request_id`, `milestone_id`, `wallet_id`, `type`, `gross_amount`, `fee_amount`, `net_amount`, `sepay_ref_code` | Maintains the immutable escrow audit ledger. |
| `disputes` | `id` (UUID) | `request_id`, `milestone_id`, `reason`, `remaining_refund_amount`, `status` | Manages disputes and partial refunds for unapproved stages. |
### 🔌 7. RESTful API Specification

#### A. Auth & Discovery Module — Workflows 1 & 2

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/api/v1/auth/demo-login` | Instant one-tap persona login (Client / Stylist). | Public |
| `GET` | `/api/v1/lookbooks` | Fetch lookbooks with 33 pose landmarks and affiliate tags. | Public |
| `POST` | `/api/v1/lookbooks/scrape-affiliate` | Scrape OpenGraph metadata from product URLs. | Stylist |
| `POST` | `/api/v1/lookbooks` | Publish a lookbook with verified skeletal data and product tags. | Stylist |

#### B. Styling Request & SePay Escrow Module — Workflow 3

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/api/v1/styling-requests/ai-enhance` | Refine the styling brief and generate a four-color palette using Gemini AI. | Client |
| `POST` | `/api/v1/styling-requests` | Create a styling order and generate a SePay VietQR payment payload. | Client |
| `POST` | `/api/v1/webhooks/sepay` | Receive idempotent VietQR payment confirmations, lock escrow funds, and initialize three stages. | Webhook Secret |

#### C. Milestone Execution, Wallet & Dispute Module — Workflows 3 & 4

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/api/v1/milestones/:id/submit` | Submit stage deliverables, pose nodes, and affiliate tags; start the SLA timer. | Stylist |
| `POST` | `/api/v1/milestones/:id/approve` | Approve a stage, transfer the stylist's net payout, and unlock the next stage. | Client |
| `POST` | `/api/v1/milestones/:id/request-revision` | Request revisions while enforcing the two-revision limit. | Client |
| `POST` | `/api/v1/disputes` | Freeze escrow and refund unapproved stage funds. | Client |
| `GET` | `/api/v1/wallets/me` | Retrieve wallet balances and the immutable escrow ledger. | Stylist |
| `POST` | `/api/v1/wallets/withdraw` | Withdraw available net earnings to the linked bank account. | Stylist |
### 🔌 7. RESTful API Specification

#### A. Auth & Discovery Module — Workflows 1 & 2

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/api/v1/auth/demo-login` | Instant one-tap persona login (Client / Stylist). | Public |
| `GET` | `/api/v1/lookbooks` | Fetch lookbooks with 33 pose landmarks and affiliate tags. | Public |
| `POST` | `/api/v1/lookbooks/scrape-affiliate` | Scrape OpenGraph metadata from product URLs. | Stylist |
| `POST` | `/api/v1/lookbooks` | Publish a lookbook with verified skeletal data and product tags. | Stylist |

#### B. Styling Request & SePay Escrow Module — Workflow 3

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/api/v1/styling-requests/ai-enhance` | Refine the styling brief and generate a four-color palette using Gemini AI. | Client |
| `POST` | `/api/v1/styling-requests` | Create a styling order and generate a SePay VietQR payment payload. | Client |
| `POST` | `/api/v1/webhooks/sepay` | Receive idempotent VietQR payment confirmations, lock escrow funds, and initialize three stages. | Webhook Secret |

#### C. Milestone Execution, Wallet & Dispute Module — Workflows 3 & 4

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `POST` | `/api/v1/milestones/:id/submit` | Submit stage deliverables, pose nodes, and affiliate tags; start the SLA timer. | Stylist |
| `POST` | `/api/v1/milestones/:id/approve` | Approve a stage, transfer the stylist's net payout, and unlock the next stage. | Client |
| `POST` | `/api/v1/milestones/:id/request-revision` | Request revisions while enforcing the two-revision limit. | Client |
| `POST` | `/api/v1/disputes` | Freeze escrow and refund unapproved stage funds. | Client |
| `GET` | `/api/v1/wallets/me` | Retrieve wallet balances and the immutable escrow ledger. | Stylist |
| `POST` | `/api/v1/wallets/withdraw` | Withdraw available net earnings to the linked bank account. | Stylist |
### 📂 8. Project Directory Structure

```text
posenova-platform/
├── posenova-mobile/                    # Flutter mobile app (iOS / Android)
│   └── lib/
│       ├── core/
│       │   ├── theme/                  # Design system and color palette
│       │   └── widgets/                # Reusable UI components
│       └── features/
│           ├── auth/                   # Client / Stylist role switcher
│           ├── discovery/              # Lookbook feed and affiliate sheet
│           ├── pose_camera/            # ML Kit pose detection and local save
│           ├── styling_request/        # Brief builder, Gemini AI and VietQR
│           └── stylist_studio/         # Order inbox, milestones and wallet
│
└── posenova-backend/                   # Node.js + TypeScript + Prisma
    ├── prisma/
    │   ├── schema.prisma               # PostgreSQL schema
    │   └── seed.ts                     # Demo data
    ├── docs/                           # Swagger OpenAPI and workflow diagrams
    └── src/
        ├── config/
        ├── common/
        │   ├── constants/
        │   ├── middlewares/
        │   └── utils/
        ├── integrations/
        │   ├── sepay/                  # VietQR and webhook handler
        │   ├── gemini/                 # AI brief and color palette
        │   └── scraper/                # Affiliate metadata extractor
        ├── jobs/
        │   └── sla-auto-release.job.ts # 48-hour auto-release job
        └── modules/
            ├── auth/
            ├── lookbooks/
            ├── styling-requests/
            ├── milestones/
            ├── escrow-wallet/
            └── disputes/
```
### 🚀 9. Getting Started & Installation

#### Prerequisites

- Node.js >= 20.x
- PostgreSQL >= 15
- Flutter SDK >= 3.19.x (Dart >= 3.3.x)
- Physical Android/iOS device recommended for real-time AI pose camera testing

#### Step 1: Back-End Setup

```bash
cd posenova-backend
npm install

# Configure DATABASE_URL, GEMINI_API_KEY, and SEPAY_WEBHOOK_SECRET
cp .env.example .env

# Run Prisma migrations and seed demo personas
npx prisma migrate dev --name init_posenova_schema
npx prisma db seed

# Start the development server
npm run dev
```

- API: `http://localhost:3000`
- Swagger Docs: `http://localhost:3000/api-docs`

#### Step 2: Flutter Mobile App Setup

```bash
cd posenova-mobile
flutter pub get

# Run on a connected device or emulator
flutter run
```
### 🎬 10. 5-Minute Evaluation & Demo Script

Designed for live demonstration during a capstone defense or product pitch.

| Time | Demo Stage | Actions | Expected Outcome |
|---|---|---|---|
| Minute 1 | Discovery & AI Pose Camera | Browse the lookbook feed, launch the 30 FPS pose camera, align with the 33-landmark skeleton, capture a photo, and verify local storage. | Demonstrate pose matching and on-device photo saving. |
| Minute 2 | Styling Brief & Escrow Deposit | Enter body metrics and budget, generate the brief and color palette using Gemini AI, and pay 2,500,000 VND through SePay VietQR. | Demonstrate styling brief enhancement and escrow locking. |
| Minute 3 | Stylist Studio | Switch to the Stylist persona and inspect request `#REQ-8452` and the 2,125,000 VND net payout breakdown. | Demonstrate the stylist order inbox and payout calculation. |
| Minute 4 | Milestone Workspace | Inspect Stage 01 and submit the Stage 02 outfit selection with affiliate product tags. | Demonstrate milestone delivery and affiliate tagging. |
| Minute 5 | Escrow Ledger & Bank Payout | Inspect wallet balances and the escrow reconciliation ledger, then demonstrate the withdrawal flow. | Demonstrate financial tracking and bank withdrawal readiness. |

---

### 📄 License

This project is developed for academic capstone evaluation and R&D demonstration.

**All rights reserved © 2026 PoseNova AI Team.**


