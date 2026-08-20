-- 데굴데굴 볼링 기록실 - Supabase 초기 설정
-- 1) 먼저 Supabase Authentication > Users에서 관리자 계정을 생성합니다.
-- 2) 생성된 User UUID를 아래 YOUR_ADMIN_USER_UUID 위치에 넣고 실행하세요.

create extension if not exists pgcrypto;

create table if not exists public.bowling_members (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.bowling_scores (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.bowling_members(id) on delete restrict,
  score integer not null check (score between 0 and 300),
  played_at date not null default current_date,
  created_at timestamptz not null default now()
);

create table if not exists public.bowling_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.bowling_members enable row level security;
alter table public.bowling_scores enable row level security;
alter table public.bowling_admins enable row level security;

drop policy if exists "members public read" on public.bowling_members;
create policy "members public read"
on public.bowling_members
for select
to anon, authenticated
using (true);

drop policy if exists "scores public read" on public.bowling_scores;
create policy "scores public read"
on public.bowling_scores
for select
to anon, authenticated
using (true);

drop policy if exists "scores admin insert" on public.bowling_scores;
create policy "scores admin insert"
on public.bowling_scores
for insert
to authenticated
with check (
  exists (
    select 1
    from public.bowling_admins a
    where a.user_id = auth.uid()
  )
);

drop policy if exists "scores admin delete" on public.bowling_scores;
create policy "scores admin delete"
on public.bowling_scores
for delete
to authenticated
using (
  exists (
    select 1
    from public.bowling_admins a
    where a.user_id = auth.uid()
  )
);

-- 클라이언트가 필요한 최소 권한만 부여
grant usage on schema public to anon, authenticated;
grant select on public.bowling_members to anon, authenticated;
grant select on public.bowling_scores to anon, authenticated;
grant insert, delete on public.bowling_scores to authenticated;

-- 예시 회원. 실제 회원명으로 수정해도 됩니다.
insert into public.bowling_members (name)
values ('임한별'), ('김OO'), ('이OO')
on conflict (name) do nothing;

-- ★ 반드시 본인의 관리자 User UUID로 교체
insert into public.bowling_admins (user_id)
values ('YOUR_ADMIN_USER_UUID'::uuid)
on conflict (user_id) do nothing;
