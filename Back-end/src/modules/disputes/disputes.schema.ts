import { z } from 'zod';

export const createDisputeBodySchema = z
  .object({
    requestId: z.string().trim().min(1).optional(),
    milestoneId: z.string().trim().min(1).optional(),
    reason: z
      .string()
      .trim()
      .min(5, 'Dispute reason must be at least 5 characters')
      .max(2000),
  })
  .refine((data) => Boolean(data.requestId || data.milestoneId), {
    message: 'Either "milestoneId" or "requestId" must be provided to open a Dispute',
    path: ['milestoneId'],
  });

export type CreateDisputeInput = z.infer<typeof createDisputeBodySchema>;

