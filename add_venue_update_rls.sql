-- 데굴데굴 볼링 기록실 - 볼링장 정보 수정(UPDATE) 권한 추가
-- add_venue_meetup.sql 적용 이후, Supabase SQL Editor에서 이 파일을 실행하세요.
--
-- 기존에는 bowling_venues에 SELECT/INSERT/DELETE 정책만 있고 UPDATE 정책이 없어서
-- 등록된 볼링장 정보(이름/동/주소/가격/후기)를 수정할 수 없었습니다.
-- 삭제 정책과 동일한 기준(등록한 본인 또는 관리자)으로 수정을 허용합니다.

drop policy if exists "venues self update" on public.bowling_venues;
create policy "venues self update"
on public.bowling_venues
for update
to authenticated
using (
  created_by = auth.uid()
  or exists (select 1 from public.bowling_admins a where a.user_id = auth.uid())
)
with check (
  created_by = auth.uid()
  or exists (select 1 from public.bowling_admins a where a.user_id = auth.uid())
);

grant update on public.bowling_venues to authenticated;
