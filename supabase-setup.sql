-- DB Manage / Supabase setup
-- Run this entire script in Supabase -> SQL Editor.

create table if not exists public.projects (
  id bigint primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  client text not null,
  vehicle text not null,
  vehicle_type text,
  due_date date,
  status text not null default 'Create Design',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.projects enable row level security;

grant select, insert, update, delete on public.projects to authenticated;

drop policy if exists "Users can view their own projects" on public.projects;
create policy "Users can view their own projects"
on public.projects for select to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert their own projects" on public.projects;
create policy "Users can insert their own projects"
on public.projects for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update their own projects" on public.projects;
create policy "Users can update their own projects"
on public.projects for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own projects" on public.projects;
create policy "Users can delete their own projects"
on public.projects for delete to authenticated
using (auth.uid() = user_id);

-- Enable live database changes for this table.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'projects'
  ) then
    alter publication supabase_realtime add table public.projects;
  end if;
end $$;


-- VINYL MANAGEMENT
-- Stores vinyl in Supabase so inventory syncs between phone and computer.
create table if not exists public.vinyl_rolls (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  color text not null,
  roll_length_inches numeric(12,2) not null check (roll_length_inches > 0),
  remaining_inches numeric(12,2) not null check (remaining_inches >= 0),
  swatch text not null default '#111111',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint vinyl_remaining_not_over_roll check (remaining_inches <= roll_length_inches)
);

-- If the table already existed from an earlier vinyl version, make sure
-- the columns required by the current app exist.
alter table public.vinyl_rolls
  add column if not exists color text;
alter table public.vinyl_rolls
  add column if not exists roll_length_inches numeric(12,2);
alter table public.vinyl_rolls
  add column if not exists remaining_inches numeric(12,2);
alter table public.vinyl_rolls
  add column if not exists swatch text default '#111111';
alter table public.vinyl_rolls
  add column if not exists created_at timestamptz default now();
alter table public.vinyl_rolls
  add column if not exists updated_at timestamptz default now();

alter table public.vinyl_rolls enable row level security;

grant select, insert, update, delete on public.vinyl_rolls to authenticated;

drop policy if exists "Users can view their own vinyl rolls" on public.vinyl_rolls;
create policy "Users can view their own vinyl rolls"
on public.vinyl_rolls for select to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert their own vinyl rolls" on public.vinyl_rolls;
create policy "Users can insert their own vinyl rolls"
on public.vinyl_rolls for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can update their own vinyl rolls" on public.vinyl_rolls;
create policy "Users can update their own vinyl rolls"
on public.vinyl_rolls for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own vinyl rolls" on public.vinyl_rolls;
create policy "Users can delete their own vinyl rolls"
on public.vinyl_rolls for delete to authenticated
using (auth.uid() = user_id);

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'vinyl_rolls'
  ) then
    alter publication supabase_realtime add table public.vinyl_rolls;
  end if;
end $$;
