import { z } from 'zod';

export const aiEnhanceBriefBodySchema = z
  .object({
    heightCm: z.coerce.number().int().min(100).max(250).default(170),
    weightKg: z.coerce.number().int().min(30).max(250).default(62),
    occasion: z.string().trim().min(2, 'Occasion is required'),
    vibe: z.string().trim().optional(),
    bodyType: z.string().trim().optional(),
    briefText: z.string().trim().optional(),
    rawBrief: z.string().trim().optional(),
    totalBudget: z.coerce.number().positive().optional(),
  })
  .transform((data) => ({
    heightCm: data.heightCm,
    weightKg: data.weightKg,
    occasion: data.occasion,
    vibe: data.vibe,
    bodyType: data.bodyType,
    briefText: data.briefText ?? data.rawBrief,
    totalBudget: data.totalBudget,
  }));

export const createStylingRequestBodySchema = z
  .object({
    stylistId: z.string().trim().optional(),
    title: z.string().trim().max(150).optional(),
    briefText: z.string().trim().min(5, 'Styling brief must be at least 5 characters'),
    occasion: z.string().trim().optional(),
    vibe: z.string().trim().optional(),
    bodyType: z.string().trim().optional(),
    aiPaletteJson: z.array(z.string().trim()).optional(),
    suggestedPalette: z.array(z.string().trim()).optional(),
    colorPalette: z.array(z.string().trim()).optional(),
    totalBudget: z.coerce
      .number()
      .min(100000, 'Minimum styling contract budget is 100,000 VND'),
  })
  .transform((data) => ({
    stylistId: data.stylistId,
    title: data.title,
    briefText: data.briefText,
    occasion: data.occasion,
    vibe: data.vibe,
    bodyType: data.bodyType,
    aiPaletteJson: data.aiPaletteJson ?? data.suggestedPalette ?? data.colorPalette,
    totalBudget: Math.round(data.totalBudget),
  }));

export const listStylingRequestsQuerySchema = z.object({
  status: z
    .enum([
      'PENDING_ACCEPTANCE',
      'PENDING_DEPOSIT',
      'IN_PROGRESS',
      'ESCROW_FROZEN',
      'COMPLETED',
    ])
    .optional(),
});

export const createReviewBodySchema = z.object({
  rating: z.coerce.number().int().min(1).max(5),
  comment: z.string().trim().max(2000).optional(),
  capturedImageUrl: z.string().url().optional(),
  poseMatchScore: z.coerce.number().min(0).max(100).optional(),
});

export type AiEnhanceBriefBody = z.infer<typeof aiEnhanceBriefBodySchema>;
export type CreateStylingRequestBody = z.infer<typeof createStylingRequestBodySchema>;
export type CreateReviewBody = z.infer<typeof createReviewBodySchema>;

