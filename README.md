# ✨ PoseNova AI — AI Pose Atelier & Personal Styling C2C Marketplace

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
[Workflow 1: AI Pose Camera & Discovery] 
       │  (Top-of-Funnel User Acquisition Hook)
       ▼
[Workflow 3: CORE FLOW — Styling Brief & 30-30-40 Escrow] ◄── [Workflow 2: Lookbook & Affiliate Tagging]
       │                                                       (Supply-Side Creator Tooling)
       ▼
[Workflow 4: Revision Quota & Dispute Resolution]
  (Financial Safety Net & Partial Refund Engine)
