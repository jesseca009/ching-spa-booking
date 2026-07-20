-- Ching Massage and Spa — restrict database access to signed-in staff
-- Run this in the Supabase SQL editor AFTER you've:
--   1. Created a staff login: Authentication → Users → Add User
--      (check "Auto Confirm User" so it doesn't need email verification)
--   2. Disabled public sign-ups: Authentication → Providers → Email →
--      turn off "Allow new users to sign up" (so no one can create an
--      account through the app's API without you knowing)
--
-- This replaces the old "anyone with the URL" policies with
-- "must be logged in" policies. The app's login screen handles this via
-- Supabase Auth — no code changes needed beyond what's already in index.html.

drop policy if exists "Allow anon read" on bookings;
drop policy if exists "Allow anon insert" on bookings;
drop policy if exists "Allow anon update" on bookings;

drop policy if exists "Allow anon read" on booking_guests;
drop policy if exists "Allow anon insert" on booking_guests;
drop policy if exists "Allow anon update" on booking_guests;

create policy "Staff can read" on bookings
  for select using (auth.role() = 'authenticated');
create policy "Staff can insert" on bookings
  for insert with check (auth.role() = 'authenticated');
create policy "Staff can update" on bookings
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "Staff can read" on booking_guests
  for select using (auth.role() = 'authenticated');
create policy "Staff can insert" on booking_guests
  for insert with check (auth.role() = 'authenticated');
create policy "Staff can update" on booking_guests
  for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
