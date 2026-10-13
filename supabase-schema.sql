-- Jalankan di Supabase Dashboard > SQL Editor > New query.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  studio_name text not null default 'Darkwhite Studio',
  exchange_rate numeric not null default 16000 check (exchange_rate > 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('income','expense')),
  date date not null,
  currency text not null check (currency in ('IDR','USD')),
  amount numeric not null check (amount > 0),
  idr_value numeric not null check (idr_value > 0),
  rate_at_entry numeric not null check (rate_at_entry > 0),
  category text not null default 'Lainnya',
  note text not null default '',
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.transactions enable row level security;

drop policy if exists "profile select own" on public.profiles;
create policy "profile select own" on public.profiles for select to authenticated using (auth.uid() = id);
drop policy if exists "profile insert own" on public.profiles;
create policy "profile insert own" on public.profiles for insert to authenticated with check (auth.uid() = id);
drop policy if exists "profile update own" on public.profiles;
create policy "profile update own" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "transactions select own" on public.transactions;
create policy "transactions select own" on public.transactions for select to authenticated using (auth.uid() = user_id);
drop policy if exists "transactions insert own" on public.transactions;
create policy "transactions insert own" on public.transactions for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "transactions update own" on public.transactions;
create policy "transactions update own" on public.transactions for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "transactions delete own" on public.transactions;
create policy "transactions delete own" on public.transactions for delete to authenticated using (auth.uid() = user_id);

-- Profil baru dibuat saat pengguna pertama kali menyimpan pengaturan.
-- Data transaksi dipisahkan per user melalui Row Level Security (RLS).
