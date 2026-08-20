-- 데굴데굴 볼링 기록실 - 회원 위치정보(동/자차) 수정 권한 완화
-- add_venue_meetup.sql 적용 이후, Supabase SQL Editor에서 이 파일을 실행하세요.
--
-- 기존에는 "본인 회원 레코드"의 동/자차만 본인이 수정할 수 있었습니다.
-- 이제 로그인한 회원이면 누구나 다른 회원의 동/자차 정보도 등록·수정할 수 있게 합니다.
-- 단, 실수나 악의적인 변경으로부터 이름/별명/계정 연결 등은 보호하기 위해
-- "동(dong), 자차 여부(has_car)" 두 컬럼만 수정 가능하도록 컬럼 단위로 권한을 제한합니다.

drop policy if exists "members self update" on public.bowling_members;
drop policy if exists "members location update" on public.bowling_members;
create policy "members location update"
on public.bowling_members
for update
to authenticated
using (true)
with check (true);

-- 기존에 부여했던 전체 컬럼 UPDATE 권한을 회수하고, dong/has_car 컬럼만 재부여합니다.
revoke update on public.bowling_members from authenticated;
grant update (dong, has_car) on public.bowling_members to authenticated;
