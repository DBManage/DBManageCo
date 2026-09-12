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


-- Vinyl Management
create table if not exists public.vinyl_rolls (
  id bigint primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  color text not null,
  roll_inches numeric(10,2) not null check (roll_inches > 0),
  remaining_inches numeric(10,2) not null check (remaining_inches >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.vinyl_usage (
  id bigint primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  roll_id bigint not null references public.vinyl_rolls(id) on delete cascade,
  used_inches numeric(10,2) not null check (used_inches > 0),
  remaining_inches numeric(10,2) not null check (remaining_inches >= 0),
  created_at timestamptz not null default now()
);

alter table public.vinyl_rolls enable row level security;
alter table public.vinyl_usage enable row level security;

grant select, insert, update, delete on public.vinyl_rolls to authenticated;
grant select, insert, update, delete on public.vinyl_usage to authenticated;

drop policy if exists "Users can view their own vinyl rolls" on public.vinyl_rolls;
create policy "Users can view their own vinyl rolls"
on public.vinyl_rolls for select to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can insert their own vinyl rolls" on public.vinyl_rolls;
create policy "Users can insert their own vinyl rolls"
on public.vinyl_rolls for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Users can update their own vinyl rolls" on public.vinyl_rolls;
create policy "Users can update their own vinyl rolls"
on public.vinyl_rolls for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own vinyl rolls" on public.vinyl_rolls;
create policy "Users can delete their own vinyl rolls"
on public.vinyl_rolls for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can view their own vinyl usage" on public.vinyl_usage;
create policy "Users can view their own vinyl usage"
on public.vinyl_usage for select to authenticated using (auth.uid() = user_id);

drop policy if exists "Users can insert their own vinyl usage" on public.vinyl_usage;
create policy "Users can insert their own vinyl usage"
on public.vinyl_usage for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "Users can update their own vinyl usage" on public.vinyl_usage;
create policy "Users can update their own vinyl usage"
on public.vinyl_usage for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own vinyl usage" on public.vinyl_usage;
create policy "Users can delete their own vinyl usage"
on public.vinyl_usage for delete to authenticated using (auth.uid() = user_id);

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'vinyl_rolls'
  ) then
    alter publication supabase_realtime add table public.vinyl_rolls;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'vinyl_usage'
  ) then
    alter publication supabase_realtime add table public.vinyl_usage;
  end if;
end $$;
