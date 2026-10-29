import { z } from 'zod';

export const withdrawFundsBodySchema = z.object({
  amount: z.coerce
    .number()
    .min(50000, 'Minimum bank withdrawal amount is 50,000 VND'),
  bankName: z.string().trim().min(2).max(100).optional(),
  bankAccountNo: z.string().trim().min(5).max(40).optional(),
  bankAccountHolder: z.string().trim().min(2).max(120).optional(),
  note: z.string().trim().max(500).optional(),
});

export const updateBankAccountBodySchema = z.object({
  bankName: z.string().trim().min(2, 'Bank name is required').max(100),
  bankAccountNo: z.string().trim().min(5, 'Bank account number is required').max(40),
  bankAccountHolder: z.string().trim().min(2, 'Account holder name is required').max(120),
});

export type WithdrawFundsInput = z.infer<typeof withdrawFundsBodySchema>;
export type UpdateBankAccountInput = z.infer<typeof updateBankAccountBodySchema>;

