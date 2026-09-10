-- 회원이 로그인한 상태에서 본인 정보(닉네임, 동네/차량 여부 등)를 직접 수정할 수 있게 하는 권한 설정
-- Supabase 대시보드 > SQL Editor 에서 이 스크립트를 실행하세요.
--
-- 실제로 겪은 에러: 닉네임 변경 시 "permission denied for table bowling_members"
-- -> bowling_members 테이블에 UPDATE 권한/정책이 없어서 로그인한 사용자가 본인 정보조차
--    수정할 수 없었던 상태입니다. 아래 스크립트로 "본인 행만" 수정할 수 있게 허용합니다.

grant update on public.bowling_members to authenticated;

alter table public.bowling_members enable row level security;

-- 본인 계정에 연결된 회원 행만 수정 가능. 관리자(bowling_admins)는 다른 회원 것도 수정 가능.
drop policy if exists "bowling_members_update_own" on public.bowling_members;
create policy "bowling_members_update_own"
  on public.bowling_members
  for update
  using (
    user_id = auth.uid()
    or exists (
      select 1 from public.bowling_admins a
      where a.user_id = auth.uid()
    )
  )
  with check (
    user_id = auth.uid()
    or exists (
      select 1 from public.bowling_admins a
      where a.user_id = auth.uid()
    )
  );
