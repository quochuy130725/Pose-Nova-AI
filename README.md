 ✨ PoseNova AI — AI Pose Atelier & Personal Styling C2C Marketplace

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?style=for-the-badge&logo=typescript&logoColor=white)
![Prisma](https://img.shields.io/badge/Prisma-ORM-2D3748?style=for-the-badge&logo=prisma&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Google ML Kit](https://img.shields.io/badge/Google_ML_Kit-33_Pose_Nodes-EA4335?style=for-the-badge&logo=google&logoColor=white)
![Gemini AI](https://img.shields.io/badge/Gemini_AI-Co--Pilot-8E75B2?style=for-the-badge&logo=googlegemini&logoColor=white)

> **"From Styling to Posing — Bridging the gap between what you wear and how you own the frame."**  
> **PoseNova AI** is a managed C2C Personal Styling Marketplace & AI Pose Atelier that connects fashion-forward **Clients** with independent **Personal Stylists** through **Real-Time 33-Landmark AI Pose Detection**, a **3-Stage Milestone Escrow System (`30% - 30% - 40%`)**, and **Visual Affiliate Commerce**.

---

## 📖 Table of Contents
1. [Problem Statement & Core Values](#-1-problem-statement--core-values)
2. [System Workflows Architecture](#-2-system-workflows-architecture)
3. [End-to-End Main Flow (Mermaid Diagram)](#-3-end-to-end-main-flow)
4. [Financial Mechanics: 30-30-40 Escrow & Dispute Engine](#-4-financial-mechanics-30-30-40-escrow--dispute-engine)
5. [On-Device AI Camera & Privacy Architecture](#-5-on-device-ai-camera--privacy-architecture)
6. [Database Schema & Entity Relationships (ERD)](#-6-database-schema--entity-relationships-erd)
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
[Workflow 1: AI Pose Camera & Discovery] 
       │  (Top-of-Funnel User Acquisition Hook)
       ▼
[Workflow 3: CORE FLOW — Styling Brief & 30-30-40 Escrow] ◄── [Workflow 2: Lookbook & Affiliate Tagging]
       │                                                       (Supply-Side Creator Tooling)
       ▼
[Workflow 4: Revision Quota & Dispute Resolution]
  (Financial Safety Net & Partial Refund Engine)
WorkflowNameRole in EcosystemKey Technical ComponentsWorkflow 1Discovery & AI Pose CameraTop-of-Funnel Hook: Users browse curated lookbooks (Streetwear, Cyber AW26, Y2K Pop), inspect affiliate items, and test poses in real time.google_mlkit_pose_detection, 30 FPS RAM Stream, Cosine/Euclidean Joint Angle Matching, Local Gallery Save (gal).Workflow 2Lookbook Publishing & AffiliateSupply-Side Engine: Stylists upload outfit photos, validate human skeletal landmarks, and pin affiliate product links.Automated OpenGraph Scraper (title, price, thumbnail), 33-Node JSONB Extractor, normalized (x, y) coordinates.Workflow 3 ⭐3-Stage Styling & EscrowCORE BUSINESS FLOW: End-to-end custom styling request, AI brief enhancement, 100% VietQR escrow deposit, and rolling 30-30-40 payouts.Gemini AI Co-pilot, SePay VietQR Webhook, Prisma Interactive ACID Transactions, Pessimistic Wallet Locking.Workflow 4Revision Quota & DisputeRisk Mitigation: Enforces the 2-revision cap, freezes escrow funds upon conflict, and executes automated partial refunds.Revision Counter State Machine, ESCROW_FROZEN Lock, 48-Hour SLA Auto-Release Cronjob.🛣️ 3. End-to-End Main FlowThe complete Happy Path journey connecting the Client (Alex Đỗ), the System & AI Engine, and the Stylist (Maya Trần):Đoạn mãflowchart TD
    classDef process fill:#dae8fc,stroke:#6c8ebf,stroke-width:1.5px,color:#000000;
    classDef decision fill:#ffe6cc,stroke:#d79b00,stroke-width:1.5px,color:#000000;
    classDef startEnd fill:#f8cecc,stroke:#b85450,stroke-width:2px,color:#000000;

    subgraph Client["App: User / Client"]
        direction TB
        C_start(["Start"])
        C_disc["1. Explore Lookbooks & Test AI Pose Camera"]
        C_brief["2. Fill Styling Brief (Metrics, Occasion, Budget)"]
        C_sub["Submit Styling Request"]
        C_dep["Scan VietQR & Deposit 100% (SePay Escrow)"]
        C_app1["Approve Stage 1 (30%)"]
        C_app2["Approve Stage 2 (30%)"]
        C_app3["Approve Stage 3 (40%)"]
        C_shoot["Shoot Final Look via AI Pose Camera (Save to Gallery)"]
        C_rate["Rate Stylist (1-5 Stars) & Close Order"]
        C_end(["End"])
    end

    subgraph System["System & AI Engine"]
        direction TB
        Sys_ai["Gemini AI Analyzes Brief & Recommends Stylists"]
        Sys_not["Dispatch Request Notification"]
        Sys_init["Init 3-Stage Escrow (30-30-40) & Generate VietQR"]
        Sys_lock["Lock 100% Escrow Fund & Unlock Stage 1"]
        Sys_p1["Release 30% Net to Wallet & Unlock Stage 2"]
        Sys_p2["Release 30% Net to Wallet & Unlock Stage 3"]
        Sys_p3["Release Final 40% Net & Publish Custom Pose"]
    end

    subgraph Stylist["Role: Stylist / Partner"]
        direction TB
        S_rec["Receive Notification & Review AI Brief"]
        S_acc{"Accept Request?"}
        S_st1["Stage 1: Deliver Moodboard & Concept (30%)"]
        S_st2["Stage 2: Deliver Outfits & Affiliate Tags (30%)"]
        S_st3["Stage 3: Deliver Final Lookbook & 33 Pose Nodes (40%)"]
        S_with["Wallet Reaches 100% Net -> Withdraw to Bank"]
    end

    C_start --> C_disc --> C_brief --> C_sub
    C_sub --> Sys_ai --> Sys_not --> S_rec --> S_acc
    S_acc -- No --> Sys_ai
    S_acc -- Yes --> Sys_init --> C_dep --> Sys_lock
    Sys_lock --> S_st1 --> C_app1 --> Sys_p1
    Sys_p1 --> S_st2 --> C_app2 --> Sys_p2
    Sys_p2 --> S_st3 --> C_app3 --> Sys_p3
    Sys_p3 --> C_shoot --> C_rate --> C_end
    Sys_p3 --> S_with

    class C_disc,C_brief,C_sub,C_dep,C_app1,C_app2,C_app3,C_shoot,C_rate,Sys_ai,Sys_not,Sys_init,Sys_lock,Sys_p1,Sys_p2,Sys_p3,S_rec,S_st1,S_st2,S_st3,S_with process;
    class S_acc decision;
    class C_start,C_end startEnd;
💰 4. Financial Mechanics: 30-30-40 Escrow & Dispute EngineA. Milestone Disbursement Breakdown (Example Contract: 2,500,000 VND)Platform Commission Fee: 15% (375,000 VND total across 3 stages)Stylist Guaranteed Net Payout: 85% (2,125,000 VND total across 3 stages)StageDeliverable ScopeAllocationGross AmountPlatform Fee (15%)Stylist Net Payout (85%)Trigger ConditionStage 01Moodboard & Concept (Color palette, vibe, silhouette direction)30%750,000 VND112,500 VND637,500 VNDInstant payout upon Client approval of Stage 01.Stage 02Outfit Selection & Affiliate Tags (Garment curation & shoppable links)30%750,000 VND112,500 VND637,500 VNDInstant payout upon Client approval of Stage 02.Stage 03Final Lookbook & 33 AI Pose Nodes (Full visual guide & custom skeleton)40%1,000,000 VND150,000 VND850,000 VNDClient approval OR 48-hour SLA Auto-Release timer.TotalFull 3-Stage Contract (#REQ-8452)100%2,500,000 VND375,000 VND2,125,000 VND100% Balanced LedgerB. Mathematical Invariant & Ledger IntegrityEvery financial operation executes inside an interactive PostgreSQL ACID transaction (prisma.$transaction), satisfying the strict conservation invariant:$$\text{Total Deposit} = \sum_{i=1}^{k} \text{Net Payout}_i + \sum_{i=1}^{k} \text{Platform Fee}_i + \text{Escrow Locked Balance} + \text{Dispute Refund}$$C. Revision Quota (Max = 2) & Partial Dispute Refund RuleRevision Tracking: For each stage, the Client is entitled to at most 2 free revisions (revision_count increments from 0 → 1 → 2).Dispute Activation: Once revision_count == 2 is exhausted and the Client remains unsatisfied, the Open Dispute & Refund action unlocks.Partial Refund Calculation: Suppose Stage 01 (30%) was already approved, and a dispute occurs at Stage 02:Stylist Protection: The Stylist retains the 637,500 VND Net Payout already earned from Stage 01.Client Protection: The unapproved remaining stages (Stage 02 [30%] + Stage 03 [40%] = 70%) totaling 1,750,000 VND are frozen (ESCROW_FROZEN) and refunded directly to the Client.📸 5. On-Device AI Camera & Privacy ArchitecturePoseNova AI is engineered with a Privacy-First, Edge-Computing Vision Pipeline:Zero-Latency RAM Stream (30 FPS): During live pose matching, camera frames are processed strictly in volatile device RAM via google_mlkit_pose_detection. No video streams or raw preview frames are ever written to disk or uploaded to external servers.Direct Local Gallery Save: When the user hits the capture button at high pose-match accuracy (e.g., 98% Pose Match), the high-resolution photo is saved directly to the smartphone's native photo album (DCIM/PoseNova) via the gal package.Strict Opt-In Cloud Upload: Personal photos taken by clients never leave the device unless the user explicitly attaches a photo to a 5-star review or opts in to share their result on the community feed.🗄️ 6. Database Schema & Entity Relationships (ERD)The PostgreSQL database is structured around 7 core tables managed via Prisma ORM:Đoạn mãerDiagram
    USERS ||--o| WALLETS : owns
    USERS ||--o{ LOOKBOOKS : publishes
    USERS ||--o{ STYLING_REQUESTS : "creates (Client) / fulfills (Stylist)"
    LOOKBOOKS ||--o{ PRODUCT_TAGS : contains
    STYLING_REQUESTS ||--|{ REQUEST_MILESTONES : "divided into (30-30-40)"
    STYLING_REQUESTS ||--o{ PAYMENT_TRANSACTIONS : logs
    STYLING_REQUESTS ||--o| DISPUTES : triggers
    REQUEST_MILESTONES ||--o{ PRODUCT_TAGS : attaches

    USERS {
        uuid id PK
        string email UK
        string full_name
        enum role "CLIENT | STYLIST | ADMIN"
        int height_cm
        int weight_kg
        float rating_avg
    }

    WALLETS {
        uuid id PK
        uuid user_id FK
        decimal available_balance "Withdrawable 85% Net"
        decimal escrow_locked_balance "Locked in active stages"
        string bank_name
        string bank_account_no
    }

    LOOKBOOKS {
        uuid id PK
        uuid stylist_id FK
        string title
        string style_category "STREETWEAR | CYBER_AW26 | Y2K_POP"
        string image_url
        jsonb pose_landmarks_json "33 ML Kit XYZ coordinates"
    }

    PRODUCT_TAGS {
        uuid id PK
        uuid lookbook_id FK
        uuid milestone_id FK
        string product_name
        decimal price
        string affiliate_url
        float pos_x "Normalized 0.0 - 1.0"
        float pos_y "Normalized 0.0 - 1.0"
    }

    STYLING_REQUESTS {
        uuid id PK
        string code UK "e.g., #REQ-8452"
        uuid client_id FK
        uuid stylist_id FK
        text brief_text
        jsonb ai_palette_json "Gemini suggested hex colors"
        decimal total_budget "e.g., 2,500,000"
        decimal platform_fee_rate "0.15"
        enum status "PENDING_DEPOSIT | IN_PROGRESS | ESCROW_FROZEN | COMPLETED"
    }

    REQUEST_MILESTONES {
        uuid id PK
        uuid request_id FK
        int stage_order "1, 2, or 3"
        string title
        int percentage "30, 30, or 40"
        decimal gross_amount
        decimal net_payout
        int revision_count "Default 0, Max 2"
        string deliverable_url
        jsonb pose_landmarks_json
        enum status "LOCKED | ACTIVE | IN_REVIEW | APPROVED | DISPUTED"
        timestamp auto_release_at "SLA +48h"
    }

    PAYMENT_TRANSACTIONS {
        uuid id PK
        uuid request_id FK
        uuid milestone_id FK
        uuid wallet_id FK
        enum type "ESCROW_DEPOSIT | MILESTONE_RELEASE | REFUND | WITHDRAWAL"
        decimal gross_amount
        decimal fee_amount
        decimal net_amount
        string sepay_ref_code UK "Idempotency key"
        enum status "COMPLETED | PENDING | FAILED"
    }
🔌 7. RESTful API SpecificationA. Auth & Discovery Module (Workflows 1 & 2)MethodEndpointDescriptionAuthPOST/api/v1/auth/demo-loginInstant 1-tap persona login (CLIENT: Alex Đỗ / STYLIST: Maya Trần).PublicGET/api/v1/lookbooksFetch staggered masonry lookbooks with 33 pose landmarks & affiliate tags.PublicPOST/api/v1/lookbooks/scrape-affiliateScrape OpenGraph metadata (title, price, image) from Shopee/Zara URLs.StylistPOST/api/v1/lookbooksPublish a new Lookbook with verified 33-node skeletal data and product tags.StylistB. Styling Request & SePay Escrow Module (Workflow 3)MethodEndpointDescriptionAuthPOST/api/v1/styling-requests/ai-enhanceInvoke Gemini AI Co-pilot to refine raw brief & generate a 4-color hex palette.ClientPOST/api/v1/styling-requestsCreate a styling order (#REQ-8452) and generate a dynamic SePay VietQR payload.ClientPOST/api/v1/webhooks/sepayIdempotent webhook receiving VietQR payment confirmation; locks 100% escrow & initializes 3 stages (30-30-40).Webhook SecretC. Milestone Execution, Wallet & Dispute Module (Workflows 3 & 4)MethodEndpointDescriptionAuthPOST/api/v1/milestones/:id/submitStylist uploads stage deliverable, pose nodes, and affiliate tags; starts 48h SLA timer.StylistPOST/api/v1/milestones/:id/approveClient approves stage; executes ACID transfer of 85% Net Payout to Stylist's available_balance and unlocks next stage.ClientPOST/api/v1/milestones/:id/request-revisionClient requests changes; increments revision_count (rejects if revision_count >= 2).ClientPOST/api/v1/disputesFreezes escrow (ESCROW_FROZEN) and refunds unapproved stage funds (70% or 40%) back to the Client.ClientGET/api/v1/wallets/meRetrieve Stylist's available_balance, escrow_locked_balance, and immutable Escrow Reconciliation Ledger.StylistPOST/api/v1/wallets/withdrawWithdraw available net balance to linked bank account.Stylist📂 8. Project Directory StructurePlaintextposenova-platform/
├── posenova-mobile/                        # FLUTTER MOBILE APPLICATION (iOS / Android)
│   └── lib/
│       ├── core/
│       │   ├── theme/                      # Sunset Rose-Pink (#FDF2F7) & Coral-Orange (#FF6B35) Palette
│       │   └── widgets/                    # SpringInteractiveCard, FrostedGlassPill, AuraShadowCard
│       └── features/
│           ├── auth/                       # 1-Tap Role Switcher (Client <-> Stylist Studio)
│           ├── discovery/                  # Staggered Masonry Feed, Polaroid Hero & Affiliate Sheet
│           ├── pose_camera/                # 30 FPS ML Kit Pose Detector, 33-Node Overlay & Local Save
│           ├── styling_request/            # Custom Brief Builder, Gemini Co-Pilot & VietQR Escrow
│           └── stylist_studio/             # Client Order Inbox, 3-Stage Workspace & Cyber Wallet Ledger
│
└── posenova-backend/                       # NODE.JS + TYPESCRIPT + PRISMA BACK-END
    ├── prisma/
    │   ├── schema.prisma                   # Complete PostgreSQL schema & financial constraints
    │   └── seed.ts                         # Pre-seeded demo state (Alex Đỗ, Maya Trần, #REQ-8452)
    ├── docs/                               # Swagger OpenAPI 3.0 YAML & Draw.io Workflow Diagrams
    └── src/
        ├── config/                         # Zod Env validation, Prisma Singleton & Swagger UI
        ├── common/
        │   ├── constants/                  # ESCROW_SPLITS = [0.3, 0.3, 0.4], FEE = 0.15, MAX_REV = 2
        │   ├── middlewares/                # JWT Auth, Role Guard, Zod Validator & Global Error Handler
        │   └── utils/                      # Decimal money math & standardized API responses
        ├── integrations/
        │   ├── sepay/                      # VietQR generation & Idempotent Webhook handler
        │   ├── gemini/                     # Google Gemini AI Brief & Color Palette service
        │   └── scraper/                    # OpenGraph Affiliate URL metadata extractor
        ├── jobs/
        │   └── sla-auto-release.job.ts     # 48-hour inactivity auto-disbursement cronjob
        └── modules/
            ├── auth/
            ├── lookbooks/
            ├── styling-requests/
            ├── milestones/
            ├── escrow-wallet/
            └── disputes/
🚀 9. Getting Started & InstallationPrerequisitesNode.js >= 20.x & PostgreSQL >= 15Flutter SDK >= 3.19.x (Dart >= 3.3.x)Physical Android/iOS device (recommended for testing real-time 30 FPS AI Pose Camera)Step 1: Back-End SetupBashcd posenova-backend
npm install

# Copy environment variables and configure DATABASE_URL, GEMINI_API_KEY, SEPAY_WEBHOOK_SECRET
cp .env.example .env

# Run Prisma migrations and seed initial demo personas (Alex Đỗ & Maya Trần)
npx prisma migrate dev --name init_posenova_schema
npx prisma db seed

# Start the development server (http://localhost:3000 | Swagger Docs: http://localhost:3000/api-docs)
npm run dev
Step 2: Flutter Mobile App SetupBashcd posenova-mobile
flutter pub get

# Run on connected physical device or emulator
flutter run
🎬 10. 5-Minute Evaluation & Demo ScriptDesigned for live demonstration during capstone defense or product pitch:Minute 1 — Discovery & AI Pose Camera (Client Persona: Alex Đỗ):Browse the staggered editorial lookbook feed (Tokyo Outlaw • AW26 by Maya Trần).Tap [ Chụp Dáng AI → ] on a Lookbook card to launch the live 30 FPS camera with the 33-landmark skeletal overlay. Align posture to hit 98% Pose Match, capture the photo, and verify instant local gallery storage.Minute 2 — Custom Styling Brief & 100% VietQR Escrow Deposit:Tap [ Gửi Yêu Cầu Phối Đồ → ] on the top hero card. Enter body metrics (175 cm • 65 kg), use Gemini AI Co-pilot to generate the styling brief and color palette, and lock a 2,500,000 VND deposit via SePay VietQR.Minute 3 — Instant Persona Switch to Stylist Studio (Maya Trần):Tap the top-right [ Stylist ] role switcher button.In the Client Order Inbox (#REQ-8452), inspect the clean Client Specification Card and the Guaranteed Net Payout Card (2,125,000 VND after 15% platform fee) broken down into Stage 1 (637K), Stage 2 (637K), and Stage 3 (850K).Minute 4 — 3-Stage Escrow Workspace & Affiliate Tagging:Navigate to Escrow Workspace. Review Stage 01 (Moodboard • Approved • 750,000 VND) and upload the Stage 02 deliverable (Outfit Selection & Pose) with pinned Affiliate Product Tags, then hit [ Publish & Submit (Stage 02) → ].Minute 5 — Real-Time Escrow Ledger & Bank Payout:Open the Stylist Wallet (WAL-STY-8452). Show how approved stage funds automatically transition from Escrow Locked Balance (850,000 VND) into Available Balance (765,000 VND), backed by an immutable audit trail in the Escrow Reconciliation Ledger, ready for 1-tap bank withdrawal.📄 LicenseThis project is developed for academic capstone evaluation and R&D demonstration. All rights reserved © 2026 PoseNova AI Team.
