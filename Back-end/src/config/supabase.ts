import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { env } from './env';

const supabaseKey =
  env.SUPABASE_SECRET_KEY ||
  env.SUPABASE_SERVICE_ROLE_KEY ||
  env.SUPABASE_PUBLISHABLE_KEY ||
  env.SUPABASE_ANON_KEY ||
  '';
const isConfigured =
  Boolean(env.SUPABASE_URL) &&
  Boolean(supabaseKey) &&
  !supabaseKey.includes('your_supabase_');

export const supabase: SupabaseClient | null = isConfigured && env.SUPABASE_URL
  ? createClient(env.SUPABASE_URL, supabaseKey)
  : null;

