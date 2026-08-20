-- 데굴데굴 볼링 기록실 - 모임장소 추천 기능
-- 이전 마이그레이션(update_rls.sql, add_signup_profile.sql, add_self_delete_rls.sql, add_comments.sql)
-- 적용 이후, Supabase SQL Editor에서 이 파일을 실행하세요.

-- ============================================================
-- 1) bowling_members : 동(거주지)/자차 유무 컬럼 추가 + 본인 수정 허용
-- ============================================================
alter table public.bowling_members
  add column if not exists dong text,
  add column if not exists has_car boolean not null default false;

-- 로그인한 회원이면 누구나 다른 회원의 동/자차 정보를 등록·수정할 수 있음
-- (이름/별명/계정 연결 등 다른 컬럼은 보호하기 위해 dong/has_car 컬럼만 권한 부여)
drop policy if exists "members self update" on public.bowling_members;
drop policy if exists "members location update" on public.bowling_members;
create policy "members location update"
on public.bowling_members
for update
to authenticated
using (true)
with check (true);

grant update (dong, has_car) on public.bowling_members to authenticated;

-- ============================================================
-- 2) bowling_venues : 볼링장 후보 (위치/가격/후기)
-- ============================================================
create table if not exists public.bowling_venues (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  dong text not null,
  address text,
  price_info text,
  review text,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.bowling_venues enable row level security;

drop policy if exists "venues public read" on public.bowling_venues;
create policy "venues public read"
on public.bowling_venues
for select
to anon, authenticated
using (true);

drop policy if exists "venues authenticated insert" on public.bowling_venues;
create policy "venues authenticated insert"
on public.bowling_venues
for insert
to authenticated
with check (created_by = auth.uid());

drop policy if exists "venues self delete" on public.bowling_venues;
create policy "venues self delete"
on public.bowling_venues
for delete
to authenticated
using (
  created_by = auth.uid()
  or exists (select 1 from public.bowling_admins a where a.user_id = auth.uid())
);

grant select on public.bowling_venues to anon, authenticated;
grant insert, delete on public.bowling_venues to authenticated;

-- ============================================================
-- 3) bowling_meetups : 모임(날짜)
-- ============================================================
create table if not exists public.bowling_meetups (
  id uuid primary key default gen_random_uuid(),
  meetup_date date not null,
  note text,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.bowling_meetups enable row level security;

drop policy if exists "meetups public read" on public.bowling_meetups;
create policy "meetups public read"
on public.bowling_meetups
for select
to anon, authenticated
using (true);

drop policy if exists "meetups authenticated insert" on public.bowling_meetups;
create policy "meetups authenticated insert"
on public.bowling_meetups
for insert
to authenticated
with check (created_by = auth.uid());

drop policy if exists "meetups self delete" on public.bowling_meetups;
create policy "meetups self delete"
on public.bowling_meetups
for delete
to authenticated
using (
  created_by = auth.uid()
  or exists (select 1 from public.bowling_admins a where a.user_id = auth.uid())
);

grant select on public.bowling_meetups to anon, authenticated;
grant insert, delete on public.bowling_meetups to authenticated;

-- ============================================================
-- 4) bowling_meetup_attendees : 모임 참석 체크
-- ============================================================
create table if not exists public.bowling_meetup_attendees (
  id uuid primary key default gen_random_uuid(),
  meetup_id uuid not null references public.bowling_meetups(id) on delete cascade,
  member_id uuid not null references public.bowling_members(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (meetup_id, member_id)
);

alter table public.bowling_meetup_attendees enable row level security;

drop policy if exists "attendees public read" on public.bowling_meetup_attendees;
create policy "attendees public read"
on public.bowling_meetup_attendees
for select
to anon, authenticated
using (true);

-- 점수 등록과 마찬가지로, 로그인한 회원이면 누구나 다른 회원의 참석 여부도
-- 대신 체크/해제할 수 있음(총무 등 운영 편의를 위해 본인 제한을 두지 않음)
drop policy if exists "attendees self insert" on public.bowling_meetup_attendees;
drop policy if exists "attendees insert" on public.bowling_meetup_attendees;
create policy "attendees insert"
on public.bowling_meetup_attendees
for insert
to authenticated
with check (true);

drop policy if exists "attendees self delete" on public.bowling_meetup_attendees;
drop policy if exists "attendees delete" on public.bowling_meetup_attendees;
create policy "attendees delete"
on public.bowling_meetup_attendees
for delete
to authenticated
using (true);

grant select on public.bowling_meetup_attendees to anon, authenticated;
grant insert, delete on public.bowling_meetup_attendees to authenticated;
