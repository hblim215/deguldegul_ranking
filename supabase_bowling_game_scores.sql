-- 볼링 미니게임 공유 랭킹용 테이블
-- Supabase 대시보드 > SQL Editor 에서 이 스크립트를 실행하세요.

create table if not exists public.bowling_game_scores (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.bowling_members(id) on delete cascade,
  score integer not null check (score >= 0 and score <= 300),
  played_at timestamptz not null default now()
);

alter table public.bowling_game_scores enable row level security;

-- 누구나 랭킹을 볼 수 있음
drop policy if exists "bowling_game_scores_select_all" on public.bowling_game_scores;
create policy "bowling_game_scores_select_all"
  on public.bowling_game_scores
  for select
  using (true);

-- 로그인한 사용자는 누구든(재미로 하는 미니게임이라 본인 계정이 아닌
-- 다른 회원을 골라 대신 기록해도 되도록) 점수를 등록할 수 있음
drop policy if exists "bowling_game_scores_insert_authenticated" on public.bowling_game_scores;
create policy "bowling_game_scores_insert_authenticated"
  on public.bowling_game_scores
  for insert
  with check (auth.uid() is not null);
