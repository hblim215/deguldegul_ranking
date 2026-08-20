# 🎳 데굴데굴 볼링 기록실

## 구성
- GitHub Pages: 화면(HTML/CSS/JavaScript) 호스팅
- Supabase: 회원/점수 DB + 관리자 로그인
- 회사 게시판: GitHub Pages 주소를 iframe으로 삽입

## 1. Supabase 프로젝트 만들기
1. Supabase에 로그인하고 새 프로젝트를 만듭니다.
2. Authentication > Users에서 총무용 계정을 1개 만듭니다.
3. 해당 사용자의 UUID를 복사합니다.
4. SQL Editor를 열고 `supabase_setup.sql` 내용을 붙여넣습니다.
5. `YOUR_ADMIN_USER_UUID`를 복사한 UUID로 바꾼 다음 Run 합니다.

왜 이렇게 하나요?
- 점수 조회는 게시판을 보는 모든 사람에게 허용합니다.
- 점수 등록/삭제는 `bowling_admins`에 등록된 관리자 계정만 허용합니다.
- 브라우저용 키가 노출되어도 RLS 정책이 DB 권한을 제한합니다.

## 2. Supabase URL / Publishable key 넣기
Supabase 프로젝트의 Connect 또는 Settings > API Keys에서 다음 두 값을 확인합니다.

- Project URL
- Publishable key (`sb_publishable_...`)

`index.html`에서 아래 두 줄을 찾아 교체합니다.

```js
const SUPABASE_URL = "https://YOUR_PROJECT.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_YOUR_KEY";
```

중요:
- Publishable key는 브라우저 코드에 사용할 수 있습니다.
- Secret key / service_role key는 절대 `index.html`에 넣으면 안 됩니다.

## 3. 로컬에서 화면 확인
`index.html`을 더블클릭하지 말고 간단한 웹서버로 확인하는 편이 좋습니다.

Windows PowerShell:
```powershell
cd 파일이_있는_폴더
python -m http.server 8000
```

브라우저:
```text
http://localhost:8000/
```

## 4. GitHub Pages에 올리기
1. GitHub에서 새 저장소를 만듭니다.
2. GitHub Free를 쓴다면 Pages용 저장소는 Public으로 만듭니다.
3. `index.html`을 저장소 최상위에 업로드합니다.
4. Repository > Settings > Pages로 이동합니다.
5. Deploy from a branch를 선택합니다.
6. Branch를 `main`, Folder를 `/ (root)`로 선택해 저장합니다.
7. 생성된 `https://사용자명.github.io/저장소명/` 주소에서 기록실이 열리는지 확인합니다.

주의:
- Public 저장소이므로 `index.html` 자체는 누구나 볼 수 있습니다.
- 그래서 Secret key를 절대 넣지 않고 Publishable key + RLS를 사용하는 것입니다.
- 점수 데이터 역시 현재 구성에서는 URL을 아는 사람이 조회할 수 있습니다. 회사 외부 공개를 원하지 않으면 이후 내부 호스팅/인증 구조로 변경하세요.

## 5. 회사 게시판 iframe
게시판 HTML에 아래처럼 넣습니다.

```html
<iframe
  src="https://사용자명.github.io/저장소명/"
  width="100%"
  height="900"
  style="border:0; border-radius:12px;">
</iframe>
```

## 6. 회원 추가
Supabase > Table Editor > `bowling_members`에서 행을 추가하면 됩니다.
- `name`: 회원명
- `active`: true

회원 삭제보다는 `active=false`로 바꾸는 것을 권장합니다.
기존 점수 기록을 유지하면서 화면의 신규 점수 등록 목록에서만 빼기 쉽기 때문입니다.

## 현재 들어있는 기능
- 누적 게임 수
- 클럽 전체 최고점
- AVG 1위
- 회원별 게임 수 / 최고점 / 에버리지 랭킹
- 최근 20게임 기록
- 총무 로그인
- 한 번에 1~3게임 점수 등록
- 관리자 기록 삭제
- 모바일/iframe 반응형 화면

## 다음 확장 후보
- 활동일별 3게임 AVG
- 월간 AVG / 월간 랭킹
- 개인 성장 그래프
- 핸디캡 계산
- 출석 횟수
- 정기전 순위
