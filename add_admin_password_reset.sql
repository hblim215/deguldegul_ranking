-- 데굴데굴 볼링 기록실 - 관리자(동호회장/총무)가 회원 비밀번호를 기본값으로 초기화
-- add_signup_profile.sql 적용 이후, Supabase SQL Editor에서 이 파일을 실행하세요.
--
-- 비밀번호를 잊은 회원을 위해, bowling_admins에 등록된 관리자만
-- 회원 계정의 비밀번호를 기본 비밀번호(sure1!)로 되돌릴 수 있게 합니다.
-- 회원은 기본 비밀번호로 로그인한 뒤 [비밀번호 변경]으로 새 비밀번호를 정하면 됩니다.
--
-- 브라우저에서는 auth.users를 직접 수정할 수 없으므로 security definer 함수로 처리하고,
-- 함수 안에서 호출한 사람이 관리자인지 먼저 확인합니다.

create extension if not exists pgcrypto with schema extensions;

create or replace function public.admin_reset_member_password(target_member_id uuid)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  target_user_id uuid;
begin
  if not exists (
    select 1 from public.bowling_admins a where a.user_id = auth.uid()
  ) then
    raise exception '관리자만 비밀번호를 초기화할 수 있습니다.';
  end if;

  select m.user_id into target_user_id
  from public.bowling_members m
  where m.id = target_member_id;

  if target_user_id is null then
    raise exception '이 회원은 가입된 계정이 연결되어 있지 않습니다.';
  end if;

  update auth.users
  set encrypted_password = extensions.crypt('sure1!', extensions.gen_salt('bf')),
      updated_at = now()
  where id = target_user_id;
end;
$$;

-- 로그인한 사용자만 호출 가능 (관리자 여부는 함수 안에서 다시 확인)
revoke all on function public.admin_reset_member_password(uuid) from public, anon;
grant execute on function public.admin_reset_member_password(uuid) to authenticated;
