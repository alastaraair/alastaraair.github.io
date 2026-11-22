-- Alastara booking-request schema. Run in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  booking_reference text not null unique default ('AL-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))),
  origin text not null check (length(origin) = 3),
  destination text not null check (length(destination) = 3),
  departure_date date not null,
  return_date date,
  cabin text not null check (cabin in ('Economy','Premium Economy','Business','First')),
  passengers integer not null check (passengers between 1 and 9),
  aircraft text,
  flight_number text,
  base_fare numeric(10,2) not null check (base_fare >= 0),
  extras jsonb not null default '[]'::jsonb,
  passenger_details jsonb not null default '{}'::jsonb,
  total numeric(10,2) not null check (total >= 0),
  status text not null default 'request' check (status in ('request','draft','pending','confirmed','cancelled')),
  created_at timestamptz not null default now(),
  constraint bookings_route_not_same check (origin <> destination),
  constraint bookings_dates_valid check (return_date is null or return_date >= departure_date)
);
create index if not exists bookings_user_created_idx on public.bookings(user_id, created_at desc);

alter table public.bookings enable row level security;

revoke all on public.bookings from anon;
grant select, insert on public.bookings to authenticated;

drop policy if exists "booking_read_own" on public.bookings;
create policy "booking_read_own" on public.bookings for select to authenticated using (auth.uid() = user_id);
drop policy if exists "booking_insert_own" on public.bookings;
create policy "booking_insert_own" on public.bookings for insert to authenticated with check (auth.uid() = user_id);
