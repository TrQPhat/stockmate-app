// web/src/lib/supabaseClient.ts
import { createClient, SupabaseClient } from '@supabase/supabase-js';

const supabaseUrl: string | undefined = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey: string | undefined = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.error("Missing Supabase URL or Anon Key in environment variables.");
  throw new Error("Supabase credentials are not set in environment variables. Please check your .env.local file.");
}

export const supabase: SupabaseClient = createClient(supabaseUrl, supabaseAnonKey);