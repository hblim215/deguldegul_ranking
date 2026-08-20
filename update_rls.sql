-- 데굴데굴 볼링 기록실 - RLS 정책 업데이트
-- 목적: 일반 로그인 회원도 점수를 등록(INSERT)할 수 있도록 정책을 변경합니다.
-- 조회(SELECT)는 비로그인 사용자도 가능해야 하고,
-- 삭제(DELETE)는 여전히 bowling_admins에 등록된 관리자만 가능해야 합니다.
--
-- supabase_setup.sql을 이미 실행한 프로젝트의 SQL Editor에서 이 파일을 실행하세요.
-- 기존 정책과 중복되지 않도록 DROP POLICY IF EXISTS를 먼저 실행합니다.

-- ============================================================
-- 1) bowling_scores : 조회는 누구나, 등록은 로그인 회원 누구나
-- ============================================================

-- 조회 정책 (변경 없음, 존재 보장을 위해 재생성)
drop policy if exists "scores public read" on public.bowling_scores;
create policy "scores public read"
on public.bowling_scores
for select
to anon, authenticated
using (true);

-- 기존: 관리자만 등록 가능했던 정책 제거
drop policy if exists "scores admin insert" on public.bowling_scores;
drop policy if exists "scores authenticated insert" on public.bowling_scores;

-- 신규: 로그인한 회원이면 누구나 등록 가능
create policy "scores authenticated insert"
on public.bowling_scores
for insert
to authenticated
with check (true);

grant insert on public.bowling_scores to authenticated;

-- 삭제는 관리자만 가능 (기존 정책 유지, 존재 보장을 위해 재생성)
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

grant delete on public.bowling_scores to authenticated;

-- ============================================================
-- 2) bowling_members : 조회는 누구나 (변경 없음, 존재 보장을 위해 재생성)
-- ============================================================

drop policy if exists "members public read" on public.bowling_members;
create policy "members public read"
on public.bowling_members
for select
to anon, authenticated
using (true);

-- ============================================================
-- 3) bowling_admins : 로그인 사용자가 "내가 관리자인지"만 확인 가능
--    (기존에는 SELECT 정책이 없어 클라이언트에서 관리자 여부를
--     확인할 방법이 없었습니다. 화면의 isAdmin() 체크를 위해 필요합니다.)
-- ============================================================

drop policy if exists "admins read own row" on public.bowling_admins;
create policy "admins read own row"
on public.bowling_admins
for select
to authenticated
using (user_id = auth.uid());

grant select on public.bowling_admins to authenticated;
