import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const envSchema = z.object({
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string(),
  DIRECT_URL: z.string(),
  JWT_SECRET: z.string().default('posenova_super_secret_jwt_key_2026'),
  JWT_EXPIRES_IN: z.string().default('7d'),
  ENABLE_DEMO_LOGIN: z
    .string()
    .default('true')
    .transform((val) => val.toLowerCase() !== 'false'),
  SUPABASE_URL: z.string().optional(),
  SUPABASE_ANON_KEY: z.string().optional(),
  SUPABASE_PUBLISHABLE_KEY: z.string().optional(),
  SUPABASE_SERVICE_ROLE_KEY: z.string().optional(),
  SUPABASE_SECRET_KEY: z.string().optional(),
  SUPABASE_BUCKET: z.string().default('posenova-media'),
  GEMINI_API_KEY: z.string().optional(),
  SEPAY_WEBHOOK_SECRET: z.string().default('sepay_posenova_webhook_secret_2026'),
  SEPAY_BANK_CODE: z.string().default('MBBank'),
  SEPAY_ACCOUNT_NO: z.string().default('0987654321'),
  SEPAY_ACCOUNT_NAME: z.string().default('POSENOVA ESCROW SYSTEM'),
});

export const env = envSchema.parse(process.env);

