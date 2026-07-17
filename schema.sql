-- Ching Massage and Spa — Booking System (v3: two-stage booking + attendance check-in)
-- This is the canonical FRESH-INSTALL script — use it only for a brand new
-- Supabase project. If you already have data (as of writing: 3 real
-- bookings), run migration_v3.sql instead, which preserves it.

create extension if not exists pgcrypto;

drop table if exists booking_guests;
drop table if exists bookings;

-- Stage 1: quick booking (the party/reservation)
create table bookings (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  customer_name text not null,
  contact_number text not null,
  booking_date date not null,
  booking_time time not null,
  num_guests int not null default 1 check (num_guests between 1 and 8),
  booked_via text not null check (booked_via in ('Facebook', 'Walk-in', 'Call/Text')),
  booking_status text not null default 'Confirmed'
    check (booking_status in ('Confirmed', 'Pending', 'Ongoing', 'Completed', 'Cancelled')),
  -- Shared for the whole party, filled in at check-in
  payment_method text check (payment_method in ('Cash', 'GCash')),
  payment_status text not null default 'Unpaid' check (payment_status in ('Paid', 'Unpaid'))
);

-- Stage 2: per-guest details, filled in at check-in (only for guests marked Present)
create table booking_guests (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  booking_id uuid not null references bookings(id) on delete cascade,
  guest_number int not null,
  guest_name text not null,
  service text not null,
  addon text not null default 'None',
  bed_number int not null check (bed_number between 1 and 8),
  notes text,
  unique (booking_id, guest_number)
);

create index bookings_date_idx on bookings (booking_date);
create index booking_guests_booking_idx on booking_guests (booking_id);
create index booking_guests_bed_idx on booking_guests (bed_number);

-- No staff login yet, so the anon/publishable key needs direct read/write
-- access. Open to anyone with the URL + key — acceptable for a private
-- internal tool, but don't share the link publicly.
alter table bookings enable row level security;
alter table booking_guests enable row level security;

create policy "Allow anon read" on bookings for select using (true);
create policy "Allow anon insert" on bookings for insert with check (true);
create policy "Allow anon update" on bookings for update using (true) with check (true);

create policy "Allow anon read" on booking_guests for select using (true);
create policy "Allow anon insert" on booking_guests for insert with check (true);
create policy "Allow anon update" on booking_guests for update using (true) with check (true);

-- Enable realtime updates on both tables
alter publication supabase_realtime add table bookings;
alter publication supabase_realtime add table booking_guests;
