-- ============================================================================
--  Saku · Catatan Keuangan
--  Skema database Supabase
--
--  Cara pakai:
--  1. Buka Supabase Dashboard → SQL Editor → New query
--  2. Tempel seluruh isi file ini, lalu klik RUN
--  3. Ulangi dengan aman (script bersifat idempotent)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. PROFILES
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  full_name  text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Buat profil otomatis ketika user baru mendaftar.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 2. FINANCE CATEGORIES (pemasukan / pengeluaran)
-- ---------------------------------------------------------------------------
create table if not exists public.finance_categories (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users (id) on delete cascade,
  name       text not null,
  type       text not null check (type in ('income', 'expense')),
  icon       text,
  color      text,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists finance_categories_user_idx
  on public.finance_categories (user_id, type);

alter table public.finance_categories enable row level security;

drop policy if exists "finance_categories_select_own" on public.finance_categories;
create policy "finance_categories_select_own"
  on public.finance_categories for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "finance_categories_insert_own" on public.finance_categories;
create policy "finance_categories_insert_own"
  on public.finance_categories for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "finance_categories_update_own" on public.finance_categories;
create policy "finance_categories_update_own"
  on public.finance_categories for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "finance_categories_delete_own" on public.finance_categories;
create policy "finance_categories_delete_own"
  on public.finance_categories for delete
  to authenticated
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 3. FINANCE TRANSACTIONS
-- ---------------------------------------------------------------------------
create table if not exists public.finance_transactions (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null default auth.uid() references auth.users (id) on delete cascade,
  category_id      uuid references public.finance_categories (id) on delete set null,
  type             text not null check (type in ('income', 'expense')),
  amount           numeric not null check (amount > 0),
  description      text,
  transaction_date date not null default current_date,
  payment_method   text check (
    payment_method is null
    or payment_method in ('cash', 'bank_transfer', 'e_wallet', 'credit_card', 'debit_card', 'other')
  ),
  source           text not null default 'manual' check (source in ('manual', 'receipt', 'ocr')),
  notes            text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index if not exists finance_transactions_user_date_idx
  on public.finance_transactions (user_id, transaction_date desc);

create index if not exists finance_transactions_category_idx
  on public.finance_transactions (category_id);

alter table public.finance_transactions enable row level security;

drop policy if exists "finance_transactions_select_own" on public.finance_transactions;
create policy "finance_transactions_select_own"
  on public.finance_transactions for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "finance_transactions_insert_own" on public.finance_transactions;
create policy "finance_transactions_insert_own"
  on public.finance_transactions for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "finance_transactions_update_own" on public.finance_transactions;
create policy "finance_transactions_update_own"
  on public.finance_transactions for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "finance_transactions_delete_own" on public.finance_transactions;
create policy "finance_transactions_delete_own"
  on public.finance_transactions for delete
  to authenticated
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 4. FINANCE RECEIPTS (foto struk)
-- ---------------------------------------------------------------------------
create table if not exists public.finance_receipts (
  id              uuid primary key default gen_random_uuid(),
  transaction_id  uuid not null references public.finance_transactions (id) on delete cascade,
  user_id         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  storage_path    text not null,
  file_name       text,
  mime_type       text check (
    mime_type is null
    or mime_type in ('image/jpeg', 'image/png', 'image/webp', 'application/pdf')
  ),
  file_size_bytes bigint check (file_size_bytes is null or file_size_bytes >= 0),
  merchant_name   text,
  receipt_date    date,
  subtotal        numeric check (subtotal is null or subtotal >= 0),
  tax_amount      numeric check (tax_amount is null or tax_amount >= 0),
  total_amount    numeric check (total_amount is null or total_amount >= 0),
  ocr_status      text not null default 'pending' check (
    ocr_status in ('pending', 'processing', 'completed', 'failed', 'review')
  ),
  ocr_raw_text    text,
  ocr_data        jsonb not null default '{}'::jsonb,
  created_at      timestamptz not null default now()
);

create index if not exists finance_receipts_transaction_idx
  on public.finance_receipts (transaction_id);

create index if not exists finance_receipts_user_idx
  on public.finance_receipts (user_id);

alter table public.finance_receipts enable row level security;

drop policy if exists "finance_receipts_select_own" on public.finance_receipts;
create policy "finance_receipts_select_own"
  on public.finance_receipts for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "finance_receipts_insert_own" on public.finance_receipts;
create policy "finance_receipts_insert_own"
  on public.finance_receipts for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "finance_receipts_update_own" on public.finance_receipts;
create policy "finance_receipts_update_own"
  on public.finance_receipts for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "finance_receipts_delete_own" on public.finance_receipts;
create policy "finance_receipts_delete_own"
  on public.finance_receipts for delete
  to authenticated
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 5. TRIGGER updated_at
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists finance_transactions_set_updated_at on public.finance_transactions;
create trigger finance_transactions_set_updated_at
  before update on public.finance_transactions
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- 6. STORAGE: foto struk (bucket privat)
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'receipts',
  'receipts',
  false,
  10485760,
  array['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/heic']
)
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "receipts_select_own" on storage.objects;
create policy "receipts_select_own"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'receipts'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "receipts_insert_own" on storage.objects;
create policy "receipts_insert_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'receipts'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "receipts_update_own" on storage.objects;
create policy "receipts_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'receipts'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'receipts'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "receipts_delete_own" on storage.objects;
create policy "receipts_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'receipts'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ---------------------------------------------------------------------------
-- 7. HAK AKSES
-- ---------------------------------------------------------------------------
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete
  on public.profiles,
     public.finance_categories,
     public.finance_transactions,
     public.finance_receipts
  to authenticated;

-- Selesai. Data setiap pengguna dilindungi oleh Row Level Security.
