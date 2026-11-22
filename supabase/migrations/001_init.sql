-- ====================================================================
-- Migrasi 001: Inisialisasi Tabel kos dan Row Level Security (RLS)
-- Repositori : KosFinder (Versi 1)
-- ====================================================================

-- 1. Buat Tabel public.kos
CREATE TABLE IF NOT EXISTS public.kos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    area TEXT NOT NULL,
    address TEXT NOT NULL,
    price BIGINT NOT NULL CHECK (price > 0),
    total_rooms INTEGER NOT NULL CHECK (total_rooms > 0),
    available_rooms INTEGER NOT NULL CHECK (available_rooms >= 0 AND available_rooms <= total_rooms),
    facilities TEXT[] NOT NULL DEFAULT '{}',
    contact_number TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Buat Indeks untuk Mengoptimalkan Pencarian dan Penyaringan
CREATE INDEX IF NOT EXISTS idx_kos_owner_id ON public.kos (owner_id);
CREATE INDEX IF NOT EXISTS idx_kos_area ON public.kos (area);
CREATE INDEX IF NOT EXISTS idx_kos_price ON public.kos (price);

-- 3. Berikan Hak Akses Tabel ke Role Supabase (anon & authenticated)
-- Tanpa ini, PostgreSQL akan memblokir request dengan error: permission denied for table kos
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON TABLE public.kos TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- 4. Aktifkan Row Level Security (RLS)
ALTER TABLE public.kos ENABLE ROW LEVEL SECURITY;

-- 5. Bersihkan Kebijakan Lama jika ada
DROP POLICY IF EXISTS "Public users can view all kos" ON public.kos;
DROP POLICY IF EXISTS "Authenticated owners can insert their own kos" ON public.kos;
DROP POLICY IF EXISTS "Owners can update their own kos" ON public.kos;
DROP POLICY IF EXISTS "Owners can delete their own kos" ON public.kos;

-- 6. Kebijakan RLS (Security Policies)

-- A. SELECT: Publik (anonim & terautentikasi) dapat melihat seluruh data kos
CREATE POLICY "Public users can view all kos"
ON public.kos
FOR SELECT
TO anon, authenticated
USING (true);

-- B. INSERT: Hanya pemilik kos yang login yang dapat menambahkan kos miliknya
CREATE POLICY "Authenticated owners can insert their own kos"
ON public.kos
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = owner_id);

-- C. UPDATE: Hanya pemilik kos terkait yang dapat memperbarui datanya
CREATE POLICY "Owners can update their own kos"
ON public.kos
FOR UPDATE
TO authenticated
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);

-- D. DELETE: Hanya pemilik kos terkait yang dapat menghapus datanya (hard delete)
CREATE POLICY "Owners can delete their own kos"
ON public.kos
FOR DELETE
TO authenticated
USING (auth.uid() = owner_id);
