-- Ching Massage and Spa — migration to v3 schema
-- Run this in the Supabase SQL editor.
--
-- Safe for your existing data: your 3 real bookings in `bookings` are
-- preserved (only new columns are added). `booking_guests` is currently
-- empty (no one has checked in yet), so it's safely dropped and recreated
-- with the new structure: guest_name added, payment_method/payment_status
-- removed (payment is now shared per booking, not per guest).

alter table bookings add column if not exists payment_method text check (payment_method in ('Cash', 'GCash'));
alter table bookings add column if not exists payment_status text not null default 'Unpaid' check (payment_status in ('Paid', 'Unpaid'));

drop table if exists booking_guests;

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

create index if not exists booking_guests_booking_idx on booking_guests (booking_id);
create index if not exists booking_guests_bed_idx on booking_guests (bed_number);

alter table booking_guests enable row level security;

create policy "Allow anon read" on booking_guests for select using (true);
create policy "Allow anon insert" on booking_guests for insert with check (true);
create policy "Allow anon update" on booking_guests for update using (true) with check (true);

alter publication supabase_realtime add table booking_guests;
