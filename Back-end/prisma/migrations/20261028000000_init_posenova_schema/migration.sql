-- CreateEnum
CREATE TYPE "Role" AS ENUM ('CLIENT', 'STYLIST', 'ADMIN');

-- CreateEnum
CREATE TYPE "RequestStatus" AS ENUM ('PENDING_ACCEPTANCE', 'PENDING_DEPOSIT', 'IN_PROGRESS', 'ESCROW_FROZEN', 'COMPLETED');

-- CreateEnum
CREATE TYPE "MilestoneStatus" AS ENUM ('LOCKED', 'ACTIVE', 'IN_REVIEW', 'REVISION_REQUESTED', 'APPROVED', 'DISPUTED');

-- CreateEnum
CREATE TYPE "TransactionType" AS ENUM ('ESCROW_DEPOSIT', 'MILESTONE_RELEASE', 'REFUND', 'WITHDRAWAL');

-- CreateEnum
CREATE TYPE "TransactionStatus" AS ENUM ('PENDING', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "DisputeStatus" AS ENUM ('OPEN', 'REFUNDED', 'RESOLVED');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "full_name" TEXT NOT NULL,
    "bio" TEXT,
    "avatar_url" TEXT,
    "role" "Role" NOT NULL DEFAULT 'CLIENT',
    "height_cm" INTEGER,
    "weight_kg" INTEGER,
    "rating_avg" DOUBLE PRECISION NOT NULL DEFAULT 5.0,
    "total_reviews" INTEGER NOT NULL DEFAULT 0,
    "verified_badge" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wallets" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "available_balance" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "escrow_locked_balance" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "total_withdrawn" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "bank_name" TEXT,
    "bank_account_no" TEXT,
    "bank_account_holder" TEXT,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "wallets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lookbooks" (
    "id" TEXT NOT NULL,
    "stylist_id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "style_category" TEXT NOT NULL DEFAULT 'STREETWEAR',
    "image_url" TEXT NOT NULL,
    "pose_landmarks_json" JSONB NOT NULL,
    "likes_count" INTEGER NOT NULL DEFAULT 0,
    "pose_try_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "lookbooks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lookbook_likes" (
    "id" TEXT NOT NULL,
    "lookbook_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "lookbook_likes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_tags" (
    "id" TEXT NOT NULL,
    "lookbook_id" TEXT,
    "milestone_id" TEXT,
    "product_name" TEXT NOT NULL,
    "brand_name" TEXT,
    "price" DECIMAL(14,2) NOT NULL,
    "thumbnail_url" TEXT,
    "affiliate_url" TEXT NOT NULL,
    "pos_x" DOUBLE PRECISION NOT NULL,
    "pos_y" DOUBLE PRECISION NOT NULL,
    "click_count" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "product_tags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "styling_requests" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "client_id" TEXT NOT NULL,
    "stylist_id" TEXT NOT NULL,
    "title" TEXT,
    "brief_text" TEXT NOT NULL,
    "occasion" TEXT,
    "vibe" TEXT,
    "body_type" TEXT,
    "ai_palette_json" JSONB,
    "total_budget" DECIMAL(14,2) NOT NULL,
    "platform_fee_rate" DECIMAL(4,2) NOT NULL DEFAULT 0.15,
    "status" "RequestStatus" NOT NULL DEFAULT 'PENDING_DEPOSIT',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "styling_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "request_milestones" (
    "id" TEXT NOT NULL,
    "request_id" TEXT NOT NULL,
    "stage_order" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "percentage" INTEGER NOT NULL,
    "gross_amount" DECIMAL(14,2) NOT NULL,
    "net_payout" DECIMAL(14,2) NOT NULL,
    "revision_count" INTEGER NOT NULL DEFAULT 0,
    "max_revisions" INTEGER NOT NULL DEFAULT 2,
    "stylist_notes" TEXT,
    "client_feedback" TEXT,
    "deliverable_title" TEXT,
    "deliverable_url" TEXT,
    "pose_landmarks_json" JSONB,
    "status" "MilestoneStatus" NOT NULL DEFAULT 'LOCKED',
    "auto_release_at" TIMESTAMP(3),
    "submitted_at" TIMESTAMP(3),
    "approved_at" TIMESTAMP(3),

    CONSTRAINT "request_milestones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "milestone_submissions" (
    "id" TEXT NOT NULL,
    "milestone_id" TEXT NOT NULL,
    "revision_number" INTEGER NOT NULL DEFAULT 0,
    "deliverable_url" TEXT NOT NULL,
    "stylist_notes" TEXT,
    "client_feedback" TEXT,
    "pose_landmarks_json" JSONB,
    "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "milestone_submissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_transactions" (
    "id" TEXT NOT NULL,
    "request_id" TEXT NOT NULL,
    "milestone_id" TEXT,
    "wallet_id" TEXT NOT NULL,
    "type" "TransactionType" NOT NULL,
    "gross_amount" DECIMAL(14,2) NOT NULL,
    "fee_amount" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "net_amount" DECIMAL(14,2) NOT NULL,
    "sepay_ref_code" TEXT,
    "description" TEXT,
    "status" "TransactionStatus" NOT NULL DEFAULT 'COMPLETED',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "disputes" (
    "id" TEXT NOT NULL,
    "request_id" TEXT NOT NULL,
    "milestone_id" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "remaining_refund_amount" DECIMAL(14,2) NOT NULL,
    "status" "DisputeStatus" NOT NULL DEFAULT 'OPEN',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolved_at" TIMESTAMP(3),

    CONSTRAINT "disputes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reviews" (
    "id" TEXT NOT NULL,
    "request_id" TEXT NOT NULL,
    "client_id" TEXT NOT NULL,
    "stylist_id" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "captured_image_url" TEXT,
    "pose_match_score" DOUBLE PRECISION,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reviews_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "wallets_user_id_key" ON "wallets"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "lookbook_likes_lookbook_id_user_id_key" ON "lookbook_likes"("lookbook_id", "user_id");

-- CreateIndex
CREATE UNIQUE INDEX "styling_requests_code_key" ON "styling_requests"("code");

-- CreateIndex
CREATE UNIQUE INDEX "request_milestones_request_id_stage_order_key" ON "request_milestones"("request_id", "stage_order");

-- CreateIndex
CREATE UNIQUE INDEX "payment_transactions_sepay_ref_code_key" ON "payment_transactions"("sepay_ref_code");

-- CreateIndex
CREATE UNIQUE INDEX "payment_transactions_milestone_id_type_key" ON "payment_transactions"("milestone_id", "type");

-- CreateIndex
CREATE UNIQUE INDEX "disputes_request_id_key" ON "disputes"("request_id");

-- CreateIndex
CREATE UNIQUE INDEX "reviews_request_id_key" ON "reviews"("request_id");

-- AddForeignKey
ALTER TABLE "wallets" ADD CONSTRAINT "wallets_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lookbooks" ADD CONSTRAINT "lookbooks_stylist_id_fkey" FOREIGN KEY ("stylist_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lookbook_likes" ADD CONSTRAINT "lookbook_likes_lookbook_id_fkey" FOREIGN KEY ("lookbook_id") REFERENCES "lookbooks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lookbook_likes" ADD CONSTRAINT "lookbook_likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_tags" ADD CONSTRAINT "product_tags_lookbook_id_fkey" FOREIGN KEY ("lookbook_id") REFERENCES "lookbooks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_tags" ADD CONSTRAINT "product_tags_milestone_id_fkey" FOREIGN KEY ("milestone_id") REFERENCES "request_milestones"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "styling_requests" ADD CONSTRAINT "styling_requests_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "styling_requests" ADD CONSTRAINT "styling_requests_stylist_id_fkey" FOREIGN KEY ("stylist_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "request_milestones" ADD CONSTRAINT "request_milestones_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "styling_requests"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "milestone_submissions" ADD CONSTRAINT "milestone_submissions_milestone_id_fkey" FOREIGN KEY ("milestone_id") REFERENCES "request_milestones"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_transactions" ADD CONSTRAINT "payment_transactions_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "styling_requests"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_transactions" ADD CONSTRAINT "payment_transactions_milestone_id_fkey" FOREIGN KEY ("milestone_id") REFERENCES "request_milestones"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_transactions" ADD CONSTRAINT "payment_transactions_wallet_id_fkey" FOREIGN KEY ("wallet_id") REFERENCES "wallets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "disputes" ADD CONSTRAINT "disputes_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "styling_requests"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "disputes" ADD CONSTRAINT "disputes_milestone_id_fkey" FOREIGN KEY ("milestone_id") REFERENCES "request_milestones"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "styling_requests"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_stylist_id_fkey" FOREIGN KEY ("stylist_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
