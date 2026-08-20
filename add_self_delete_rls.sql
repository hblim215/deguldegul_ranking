-- 데굴데굴 볼링 기록실 - 본인 기록 삭제 허용
-- update_rls.sql, add_signup_profile.sql 적용 이후, Supabase SQL Editor에서 이 파일을 실행하세요.
--
-- 기존에는 bowling_admins에 등록된 관리자만 점수를 삭제할 수 있었습니다.
-- 이제 로그인한 회원이 "본인이 등록한(=본인 계정과 연결된 회원의)" 기록도
-- 직접 삭제할 수 있도록 정책을 추가합니다. 관리자 삭제 정책(scores admin delete)은 그대로 유지됩니다.

drop policy if exists "scores self delete" on public.bowling_scores;
create policy "scores self delete"
on public.bowling_scores
for delete
to authenticated
using (
  exists (
    select 1
    from public.bowling_members m
    where m.id = bowling_scores.member_id
      and m.user_id = auth.uid()
  )
);

grant delete on public.bowling_scores to authenticated;
