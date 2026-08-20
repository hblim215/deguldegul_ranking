-- 데굴데굴 볼링 기록실 - 대전 볼링장 후보 추가 등록 (2차)
-- seed_venues.sql을 이미 실행했다면 이어서 이 파일만 실행하면 됩니다.
-- ⚠️ 한 번만 실행하세요. 다시 실행하면 중복 등록됩니다.

insert into public.bowling_venues (name, dong, address, price_info, review, created_by) values
(
  'JK레인즈',
  '대동',
  '대전 동구 동대전로 67',
  null,
  '지하철 대동역 3번 출구 바로 앞, 대형 쇼핑몰 건물 내 위치. 큐비카 AMF 20레인, 범퍼레인 4개, 프로숍·카페 운영 (2021년 오픈 기사 기준, 현재 운영 여부는 방문 전 확인 권장)',
  null
);
