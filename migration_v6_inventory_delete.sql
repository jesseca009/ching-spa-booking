-- Ching Massage and Spa — allow staff to delete inventory items
-- Run this in the Supabase SQL editor. Without it, delete requests will
-- silently do nothing (RLS blocks DELETE by default until a policy
-- explicitly allows it — same issue we hit earlier with bookings).
--
-- Both tables need a delete policy: deleting an inventory_items row
-- cascades to delete its daily_usage_log rows too (on delete cascade),
-- and that cascade is itself subject to daily_usage_log's own RLS.

create policy "Staff can delete" on inventory_items
  for delete using (auth.role() = 'authenticated');

create policy "Staff can delete" on daily_usage_log
  for delete using (auth.role() = 'authenticated');
