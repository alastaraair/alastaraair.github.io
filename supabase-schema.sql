create table if not exists public.alastara_bookings (
  id uuid primary key default gen_random_uuid(), created_at timestamptz not null default now(),
  user_id uuid references auth.users(id) on delete set null, booking_ref text unique not null,
  trip jsonb not null, passenger_details jsonb not null, addons jsonb not null default '[]',
  payment_details jsonb not null, total numeric(10,2) not null, currency text not null default 'CHF'
);
alter table public.alastara_bookings enable row level security;
create policy "Users can read own bookings" on public.alastara_bookings for select to authenticated using (auth.uid() = user_id);
create policy "Users can create own bookings" on public.alastara_bookings for insert to authenticated with check (auth.uid() = user_id);
create table if not exists public.alastara_profiles (
  id uuid primary key references auth.users(id) on delete cascade, full_name text, phone text, created_at timestamptz default now()
);
alter table public.alastara_profiles enable row level security;
create policy "Read own profile" on public.alastara_profiles for select to authenticated using (auth.uid() = id);
create policy "Insert own profile" on public.alastara_profiles for insert to authenticated with check (auth.uid() = id);
create policy "Update own profile" on public.alastara_profiles for update to authenticated using (auth.uid() = id);
