import { z } from 'zod';

export const listLookbooksQuerySchema = z.object({
  styleCategory: z.string().trim().optional(),
});

function normalizeInputUrl(raw: string): string {
  const trimmed = raw.trim();
  if (!trimmed) return 'https://shopee.vn/demo-product';
  if (/^https?:\/\//i.test(trimmed)) return trimmed;
  return `https://${trimmed}`;
}

export const scrapeAffiliateBodySchema = z
  .object({
    url: z.string().trim().min(1).optional(),
    affiliateUrl: z.string().trim().min(1).optional(),
  })
  .refine((data) => Boolean(data.url || data.affiliateUrl), {
    message: 'Product link ("url" or "affiliateUrl") is required',
    path: ['url'],
  })
  .transform((data) => ({
    url: normalizeInputUrl((data.url ?? data.affiliateUrl) as string),
  }));

export const poseLandmarkNodeSchema = z.object({
  landmarkIndex: z.number().int().min(0).max(32).optional(),
  id: z.number().int().min(0).max(32).optional(),
  x: z.coerce.number(),
  y: z.coerce.number(),
  z: z.coerce.number().default(0),
  visibility: z.coerce.number().min(0).max(1).optional(),
});

export const productTagInputSchema = z.object({
  productName: z.string().min(1, 'Product name is required').trim(),
  brandName: z.string().trim().optional(),
  price: z.coerce.number().nonnegative('Price must be >= 0'),
  thumbnailUrl: z.string().url().optional(),
  affiliateUrl: z.string().trim().min(1).transform(normalizeInputUrl),
  posX: z.coerce.number().min(0).max(1),
  posY: z.coerce.number().min(0).max(1),
});

export const createLookbookBodySchema = z
  .object({
    title: z.string().min(2, 'Title must be at least 2 characters').trim(),
    description: z.string().trim().optional(),
    styleCategory: z
      .string()
      .trim()
      .default('STREETWEAR')
      .transform((v) => v.toUpperCase()),
    imageUrl: z.string().url('Valid imageUrl is required'),
    // Allow array of any length in Zod so service layer strictly enforces !== 33 -> HTTP 400
    poseLandmarksJson: z.array(poseLandmarkNodeSchema).optional(),
    poseLandmarks: z.array(poseLandmarkNodeSchema).optional(),
    productTags: z.array(productTagInputSchema).default([]),
  })
  .transform((data) => ({
    title: data.title,
    description: data.description,
    styleCategory: data.styleCategory,
    imageUrl: data.imageUrl,
    poseLandmarksJson: data.poseLandmarksJson ?? data.poseLandmarks ?? [],
    productTags: data.productTags,
  }));

export type CreateLookbookInput = z.infer<typeof createLookbookBodySchema>;
