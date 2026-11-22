-- Run in Supabase SQL Editor
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  booking_reference text unique default upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6)),
  origin text not null, destination text not null,
  departure_date date not null, return_date date,
  cabin text not null, passengers text not null,
  aircraft text, base_fare numeric not null, extras jsonb not null default '[]'::jsonb,
  total numeric not null, status text not null default 'draft',
  created_at timestamptz not null default now()
);

alter table public.bookings enable row level security;
drop policy if exists "Customers can read own bookings" on public.bookings;
create policy "Customers can read own bookings" on public.bookings for select to authenticated using (auth.uid() = user_id);
drop policy if exists "Customers can create own bookings" on public.bookings;
create policy "Customers can create own bookings" on public.bookings for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Customers can update own bookings" on public.bookings;
create policy "Customers can update own bookings" on public.bookings for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Customers can delete own bookings" on public.bookings;
create policy "Customers can delete own bookings" on public.bookings for delete to authenticated using (auth.uid() = user_id);
