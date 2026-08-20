-- 데굴데굴 볼링 기록실 - 모임 기록(bowling_meetups)에 "간 볼링장" 연결 추가
-- add_venue_meetup.sql, fix_member_location_rls.sql 적용 이후,
-- Supabase SQL Editor에서 이 파일을 실행하세요.
--
-- "모임 기록" 탭에서 날짜 + 간 볼링장 + 참여자를 함께 저장하기 위해
-- bowling_meetups에 bowling_venues를 가리키는 venue_id 컬럼을 추가합니다.
-- (참여자는 기존 bowling_meetup_attendees 테이블을 그대로 사용합니다.)

alter table public.bowling_meetups
  add column if not exists venue_id uuid references public.bowling_venues(id) on delete set null;

-- select/insert/delete 정책과 grant는 add_venue_meetup.sql에서 이미
-- 테이블 단위로 부여되어 있으므로 컬럼 추가만으로 충분합니다.
-- (컬럼 단위로 grant를 제한한 적이 없어 별도 grant가 필요 없습니다.)
