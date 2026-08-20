-- 데굴데굴 볼링 기록실 - 방명록(댓글) 기능
-- 이전 마이그레이션(update_rls.sql, add_signup_profile.sql, add_self_delete_rls.sql) 적용 이후,
-- Supabase SQL Editor에서 이 파일을 실행하세요.

-- 1) 댓글 테이블 생성
create table if not exists public.bowling_comments (
  id uuid primary key default gen_random_uuid(),
  member_id uuid references public.bowling_members(id) on delete set null,
  user_id uuid references auth.users(id) on delete set null,
  content text not null check (char_length(trim(content)) > 0 and char_length(content) <= 500),
  created_at timestamptz not null default now()
);

alter table public.bowling_comments enable row level security;

-- 2) 조회는 누구나 가능
drop policy if exists "comments public read" on public.bowling_comments;
create policy "comments public read"
on public.bowling_comments
for select
to anon, authenticated
using (true);

-- 3) 작성은 로그인한 회원만, 본인 계정으로만 작성 가능
drop policy if exists "comments authenticated insert" on public.bowling_comments;
create policy "comments authenticated insert"
on public.bowling_comments
for insert
to authenticated
with check (user_id = auth.uid());

-- 4) 삭제는 작성자 본인 또는 관리자만 가능
drop policy if exists "comments self delete" on public.bowling_comments;
create policy "comments self delete"
on public.bowling_comments
for delete
to authenticated
using (
  user_id = auth.uid()
  or exists (
    select 1
    from public.bowling_admins a
    where a.user_id = auth.uid()
  )
);

grant select on public.bowling_comments to anon, authenticated;
grant insert, delete on public.bowling_comments to authenticated;
