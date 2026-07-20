-- Ching Massage and Spa — Inventory tracking
-- Run this in the Supabase SQL editor.

create table inventory_items (
  id uuid primary key default gen_random_uuid(),
  item_name text not null,
  unit text not null,
  starting_stock numeric not null default 0,
  restock_added numeric not null default 0,
  category text not null check (category in ('Consumable', 'Equipment')),
  condition text,
  notes text,
  created_at timestamptz not null default now()
);

create table daily_usage_log (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  item_id uuid not null references inventory_items(id) on delete cascade,
  item_name text not null,
  qty_used numeric not null default 0,
  logged_by text,
  notes text,
  created_at timestamptz not null default now(),
  unique (date, item_id)
);

create index daily_usage_log_date_idx on daily_usage_log (date);
create index daily_usage_log_item_idx on daily_usage_log (item_id);

alter table inventory_items enable row level security;
alter table daily_usage_log enable row level security;

create policy "Staff can read" on inventory_items for select using (auth.role() = 'authenticated');
create policy "Staff can insert" on inventory_items for insert with check (auth.role() = 'authenticated');
create policy "Staff can update" on inventory_items for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "Staff can read" on daily_usage_log for select using (auth.role() = 'authenticated');
create policy "Staff can insert" on daily_usage_log for insert with check (auth.role() = 'authenticated');
create policy "Staff can update" on daily_usage_log for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

alter publication supabase_realtime add table inventory_items;
alter publication supabase_realtime add table daily_usage_log;

-- Pre-load starting items (quantities default to 0 — edit them in the
-- Summary/Equipment tabs once actual counts are known)
insert into inventory_items (item_name, unit, starting_stock, category) values
  ('Disposable Sheet', 'pcs', 0, 'Consumable'),
  ('Disposable for Face', 'pcs', 0, 'Consumable'),
  ('Ear Candles', 'pcs', 0, 'Consumable'),
  ('Massage Oil 1L', 'bottles', 0, 'Consumable'),
  ('Foot Lotion', 'gallons', 0, 'Consumable'),
  ('Epsom Salt', 'kgs', 0, 'Consumable'),
  ('Air Freshener + Linen Spray', 'gallons', 0, 'Consumable'),
  ('Martayulit', 'bottles', 0, 'Consumable');

insert into inventory_items (item_name, unit, starting_stock, category) values
  ('Towel (Body)', 'pcs', 0, 'Equipment'),
  ('Towel (Foot)', 'pcs', 0, 'Equipment'),
  ('Towel (Face)', 'pcs', 0, 'Equipment'),
  ('Scrub Suit', 'pcs', 0, 'Equipment'),
  ('Timer', 'pcs', 0, 'Equipment'),
  ('Sleep Mask', 'pcs', 0, 'Equipment'),
  ('Glass Bottle', 'pcs', 0, 'Equipment'),
  ('Cup Storage', 'pcs', 0, 'Equipment'),
  ('Heating Pad', 'pcs', 0, 'Equipment'),
  ('Hot Stone', 'pcs', 0, 'Equipment'),
  ('Foot Basin', 'pcs', 0, 'Equipment'),
  ('Ventosa', 'pcs', 0, 'Equipment'),
  ('Scrapping Stick', 'pcs', 0, 'Equipment'),
  ('Gua Sha', 'pcs', 0, 'Equipment'),
  ('Humidifier', 'pcs', 0, 'Equipment'),
  ('Sauna', 'pcs', 0, 'Equipment'),
  ('Speaker', 'pcs', 0, 'Equipment'),
  ('Extension', 'pcs', 0, 'Equipment'),
  ('Dimmer', 'pcs', 0, 'Equipment'),
  ('Slippers', 'pairs', 0, 'Equipment');
