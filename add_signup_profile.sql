-- 데굴데굴 볼링 기록실 - 회원가입 시 실명/별명 저장을 위한 스키마 변경
-- update_rls.sql 적용 이후, Supabase SQL Editor에서 이 파일을 실행하세요.

-- 1) bowling_members에 별명(nickname), 가입 계정 연결(user_id) 컬럼 추가
alter table public.bowling_members
  add column if not exists nickname text,
  add column if not exists user_id uuid references auth.users(id) on delete set null;

-- 계정 하나당 회원 레코드가 1개만 연결되도록 (user_id가 있는 행에 한해 유니크)
create unique index if not exists bowling_members_user_id_key
  on public.bowling_members(user_id)
  where user_id is not null;

-- 2) 로그인한 사용자가 회원가입 시 자기 자신의 회원 레코드를 생성할 수 있도록 허용
--    (INSERT 시 user_id가 반드시 본인 auth.uid()와 같아야 함)
drop policy if exists "members self insert" on public.bowling_members;
create policy "members self insert"
on public.bowling_members
for insert
to authenticated
with check (user_id = auth.uid());

grant insert on public.bowling_members to authenticated;

-- 참고: bowling_members.name에는 기존에 unique 제약이 걸려 있습니다.
-- 회원가입 시 입력한 "실명"이 이미 수동으로 등록된 회원명과 겹치면
-- 가입 과정에서 회원 레코드 생성이 실패할 수 있습니다(로그인 자체는 됩니다).
-- 필요하다면 아래처럼 name unique 제약을 완화할 수 있습니다.
-- alter table public.bowling_members drop constraint if exists bowling_members_name_key;
