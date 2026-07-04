-- ============================================================
-- GTIP — Government Training Intelligence Platform
-- Supabase PostgreSQL Schema (with Row Level Security)
-- ============================================================

create extension if not exists "uuid-ossp";

-- ROLES
create type user_role as enum ('student','supervisor','admin');
create type report_status as enum ('upcoming','pending','approved','rejected');
create type task_status as enum ('todo','in_progress','done');

-- USERS / PROFILES
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role user_role not null default 'student',
  email text unique not null,
  phone text,
  department text,
  photo_url text,
  personal_logo_url text,
  ministry_logo_url text default '/assets/ministry-logo.png',
  linkedin text, telegram text, x_handle text,
  cv_url text,
  languages text[],
  interests text[],
  supervisor_id uuid references profiles(id),
  created_at timestamptz default now()
);

-- WEEKS (weekly reports)
create table weeks (
  id uuid primary key default uuid_generate_v4(),
  student_id uuid references profiles(id) on delete cascade,
  week_number int not null check (week_number between 1 and 12),
  title text not null,
  status report_status default 'upcoming',
  report_date date,
  summary text,
  daily_activities jsonb default '[]',
  legal_analysis text,
  learning_outcomes text,
  challenges text,
  solutions text,
  reflection text,
  ai_analysis text,
  supervisor_notes text,
  score int check (score between 0 and 100),
  created_at timestamptz default now(),
  unique(student_id, week_number)
);

-- TASKS
create table tasks (
  id uuid primary key default uuid_generate_v4(),
  week_id uuid references weeks(id) on delete cascade,
  student_id uuid references profiles(id) on delete cascade,
  title text not null,
  priority text check (priority in ('low','medium','high')),
  difficulty text check (difficulty in ('low','medium','high')),
  department text,
  time_spent numeric,
  supervisor_id uuid references profiles(id),
  status task_status default 'todo',
  tags text[],
  notes text,
  created_at timestamptz default now()
);

-- ATTACHMENTS
create table attachments (
  id uuid primary key default uuid_generate_v4(),
  week_id uuid references weeks(id) on delete cascade,
  uploaded_by uuid references profiles(id),
  file_name text not null,
  file_type text,
  storage_path text not null,
  size_bytes bigint,
  created_at timestamptz default now()
);

-- SKILLS
create table skills (
  id uuid primary key default uuid_generate_v4(),
  student_id uuid references profiles(id) on delete cascade,
  name text not null,
  level int check (level between 0 and 100) default 0,
  source_week uuid references weeks(id)
);

-- CERTIFICATES
create table certificates (
  id uuid primary key default uuid_generate_v4(),
  student_id uuid references profiles(id) on delete cascade,
  title text not null,
  issuer text,
  file_url text,
  issued_at date
);

-- NOTIFICATIONS
create table notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references profiles(id) on delete cascade,
  message text not null,
  read boolean default false,
  created_at timestamptz default now()
);

-- REPORTS (final/aggregated)
create table reports (
  id uuid primary key default uuid_generate_v4(),
  student_id uuid references profiles(id) on delete cascade,
  type text check (type in ('weekly','final','ministry','custom')),
  content text,
  pdf_url text,
  created_at timestamptz default now()
);

-- AUDIT LOGS
create table audit_logs (
  id uuid primary key default uuid_generate_v4(),
  actor_id uuid references profiles(id),
  action text not null,
  entity text,
  entity_id uuid,
  metadata jsonb default '{}',
  created_at timestamptz default now()
);

-- SYSTEM SETTINGS
create table settings (
  key text primary key,
  value jsonb not null
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table profiles enable row level security;
alter table weeks enable row level security;
alter table tasks enable row level security;
alter table attachments enable row level security;
alter table skills enable row level security;
alter table certificates enable row level security;
alter table notifications enable row level security;
alter table reports enable row level security;
alter table audit_logs enable row level security;

-- Helper: current user's role
create or replace function auth_role() returns user_role as $$
  select role from profiles where id = auth.uid();
$$ language sql stable;

-- PROFILES
create policy "self read" on profiles for select using (id = auth.uid() or auth_role() in ('supervisor','admin'));
create policy "self update" on profiles for update using (id = auth.uid());

-- WEEKS
create policy "student manages own weeks" on weeks for all
  using (student_id = auth.uid() or auth_role() in ('supervisor','admin'))
  with check (student_id = auth.uid() or auth_role() in ('supervisor','admin'));

-- TASKS
create policy "task access" on tasks for all
  using (student_id = auth.uid() or auth_role() in ('supervisor','admin'))
  with check (student_id = auth.uid() or auth_role() in ('supervisor','admin'));

-- ATTACHMENTS
create policy "attachment access" on attachments for all
  using (uploaded_by = auth.uid() or auth_role() in ('supervisor','admin'));

-- SKILLS / CERTS / NOTIFICATIONS / REPORTS
create policy "own skills" on skills for all using (student_id = auth.uid() or auth_role() in ('supervisor','admin'));
create policy "own certs" on certificates for all using (student_id = auth.uid() or auth_role() in ('supervisor','admin'));
create policy "own notifications" on notifications for all using (user_id = auth.uid());
create policy "own reports" on reports for all using (student_id = auth.uid() or auth_role() in ('supervisor','admin'));

-- AUDIT LOGS: admin only
create policy "admin audit read" on audit_logs for select using (auth_role() = 'admin');
create policy "system audit insert" on audit_logs for insert with check (true);
