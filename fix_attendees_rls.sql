-- 데굴데굴 볼링 기록실 - 참석 체크 권한 완화
-- add_venue_meetup.sql 적용 이후, Supabase SQL Editor에서 이 파일을 실행하세요.
--
-- 기존에는 "본인 회원 레코드"에 대해서만 참석 체크(추가)가 가능했습니다.
-- 하지만 점수 등록과 마찬가지로, 로그인한 회원이라면 누구나 다른 회원의
-- 참석 여부도 대신 체크/해제할 수 있도록(총무 등 운영 편의를 위해) 정책을 완화합니다.

drop policy if exists "attendees self insert" on public.bowling_meetup_attendees;
create policy "attendees insert"
on public.bowling_meetup_attendees
for insert
to authenticated
with check (true);

drop policy if exists "attendees self delete" on public.bowling_meetup_attendees;
create policy "attendees delete"
on public.bowling_meetup_attendees
for delete
to authenticated
using (true);

grant insert, delete on public.bowling_meetup_attendees to authenticated;
