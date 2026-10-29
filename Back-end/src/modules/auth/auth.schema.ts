import { z } from 'zod';

export const demoLoginSchema = z.object({
  role: z
    .string()
    .default('CLIENT')
    .transform((val) => val.trim().toUpperCase())
    .pipe(z.enum(['CLIENT', 'STYLIST'])),
});

export const registerSchema = z.object({
  email: z.string().email('Invalid email address').transform((v) => v.trim().toLowerCase()),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  fullName: z.string().min(2, 'Full name must be at least 2 characters').trim(),
  role: z.enum(['CLIENT', 'STYLIST']).default('CLIENT'),
  heightCm: z.coerce.number().int().positive().max(250).optional(),
  weightKg: z.coerce.number().int().positive().max(300).optional(),
  avatarUrl: z.string().url().optional(),
  bio: z.string().max(500).optional(),
});

export const loginSchema = z.object({
  email: z.string().email('Invalid email address').transform((v) => v.trim().toLowerCase()),
  password: z.string().min(1, 'Password is required'),
});

export type DemoLoginInput = z.infer<typeof demoLoginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;

