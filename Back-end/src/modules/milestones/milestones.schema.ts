import { z } from 'zod';
import {
  poseLandmarkNodeSchema,
  productTagInputSchema,
} from '../lookbooks/lookbooks.schema';

export const submitMilestoneBodySchema = z
  .object({
    deliverableTitle: z.string().trim().max(150).optional(),
    deliverableUrl: z.string().url('Valid deliverableUrl is required'),
    stylistNotes: z.string().trim().max(2000).optional(),
    poseLandmarksJson: z.array(poseLandmarkNodeSchema).optional(),
    poseLandmarks: z.array(poseLandmarkNodeSchema).optional(),
    productTags: z.array(productTagInputSchema).optional(),
  })
  .transform((data) => ({
    deliverableTitle: data.deliverableTitle,
    deliverableUrl: data.deliverableUrl,
    stylistNotes: data.stylistNotes,
    poseLandmarksJson: data.poseLandmarksJson ?? data.poseLandmarks,
    productTags: data.productTags,
  }));

export const approveMilestoneBodySchema = z.object({
  feedback: z.string().trim().max(1000).optional(),
  clientFeedback: z.string().trim().max(1000).optional(),
});

export const requestRevisionBodySchema = z
  .object({
    feedback: z.string().trim().min(3).max(2000).optional(),
    clientFeedback: z.string().trim().min(3).max(2000).optional(),
    reason: z.string().trim().min(3).max(2000).optional(),
  })
  .refine((data) => Boolean(data.feedback || data.clientFeedback || data.reason), {
    message: 'Revision feedback ("feedback") is required (minimum 3 characters)',
    path: ['feedback'],
  })
  .transform((data) => ({
    feedback: (data.feedback ?? data.clientFeedback ?? data.reason) as string,
  }));

export type SubmitMilestoneInput = z.infer<typeof submitMilestoneBodySchema>;
export type ApproveMilestoneInput = z.infer<typeof approveMilestoneBodySchema>;
export type RequestRevisionInput = z.infer<typeof requestRevisionBodySchema>;
