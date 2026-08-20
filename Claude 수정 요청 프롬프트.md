현재 사내 볼링 동호회 **"데굴데굴 볼링 기록실"** 웹페이지를 만들고 있습니다.

이미 기본적인 `index.html`과 Supabase DB 구축까지 되어 있으므로 처음부터 새로 설계하지 말고, 아래의 현재 상태와 최종 요구사항을 기준으로 기존 코드를 수정해주세요.

## 1. 서비스 구조

회사 게시판에서는 JavaScript `<script>`가 차단되지만 `<iframe>`은 사용 가능합니다.

따라서 최종 구조는 다음과 같습니다.

```text
회사 게시판
    ↓ iframe
GitHub Pages에 배포된 index.html
    ↓
Supabase
    ├─ 회원 데이터
    ├─ 볼링 점수 데이터
    └─ 로그인/권한 관리
```

GitHub Pages 주소를 회사 게시판에서 iframe으로 호출할 예정입니다.

---

## 2. 현재 Supabase 구성

Supabase 프로젝트는 이미 생성되어 있습니다.

다음 테이블도 생성되어 있습니다.

### bowling_members

회원 정보 저장.

주요 컬럼:

```text
id
name
active
created_at
```

예시 회원:

```text
임한별
김OO
이OO
```

### bowling_scores

게임별 점수 저장.

주요 컬럼:

```text
id
member_id
score
played_at
created_at
```

`member_id`는 `bowling_members.id`를 FK로 참조합니다.

점수는 0~300만 허용합니다.

### bowling_admins

관리자 Supabase Authentication User ID 저장.

```text
user_id
created_at
```

관리자 계정은 Supabase Authentication에 이미 만들어져 있으며,
해당 UUID가 `bowling_admins.user_id`에 등록되어 있습니다.

---

# 3. 원하는 권한 구조

최종적으로 권한은 아래처럼 구성하고 싶습니다.

| 기능 | 비로그인 사용자 | 일반 로그인 회원 | 관리자 |
|---|---|---|---|
| 기록 조회 | 가능 | 가능 | 가능 |
| 에버리지/랭킹 조회 | 가능 | 가능 | 가능 |
| 점수 등록 | 불가능 | 가능 | 가능 |
| 점수 삭제 | 불가능 | 불가능 | 가능 |

즉,

```text
anon
→ SELECT만 가능

authenticated
→ SELECT + INSERT 가능

admin
→ SELECT + INSERT + DELETE 가능
```

이어야 합니다.

일반 회원도 로그인하면 점수를 등록할 수 있어야 합니다.

현재 단계에서는 로그인한 회원이 회원 Select Box에서 회원을 선택해서 점수를 등록할 수 있도록 해도 됩니다.

즉, 로그인 계정과 `bowling_members`를 1:1 매핑해서 자기 점수만 등록하도록 제한하는 기능은 아직 구현하지 않아도 됩니다.

---

# 4. Supabase RLS 확인

기존에는 관리자만 INSERT 가능하도록 아래와 비슷한 정책이 있었습니다.

이를 일반 로그인 사용자도 INSERT 가능하도록 수정해야 합니다.

필요하다면 아래 정책을 기준으로 SQL을 정리해주세요.

```sql
drop policy if exists "scores admin insert"
on public.bowling_scores;

drop policy if exists "scores authenticated insert"
on public.bowling_scores;

create policy "scores authenticated insert"
on public.bowling_scores
for insert
to authenticated
with check (true);

grant insert
on public.bowling_scores
to authenticated;
```

조회는 비로그인 사용자도 가능해야 합니다.

예:

```sql
create policy "scores public read"
on public.bowling_scores
for select
to anon, authenticated
using (true);
```

회원 조회도 동일합니다.

```sql
create policy "members public read"
on public.bowling_members
for select
to anon, authenticated
using (true);
```

삭제는 `bowling_admins`에 현재 로그인한 `auth.uid()`가 존재하는 경우에만 가능해야 합니다.

예:

```sql
create policy "scores admin delete"
on public.bowling_scores
for delete
to authenticated
using (
    exists (
        select 1
        from public.bowling_admins a
        where a.user_id = auth.uid()
    )
);
```

`bowling_admins` 테이블에도 RLS가 활성화되어 있으므로 로그인 사용자가 자기 관리자 여부를 판별할 수 있도록 다음 정책이 필요합니다.

```sql
create policy "admins read own row"
on public.bowling_admins
for select
to authenticated
using (user_id = auth.uid());

grant select
on public.bowling_admins
to authenticated;
```

기존 정책과 충돌하지 않도록 현재 SQL을 확인해서 필요한 `DROP POLICY IF EXISTS`를 포함한 최종 SQL을 만들어주세요.

중복 정책이 생기지 않게 해주세요.

---

# 5. 현재 HTML의 문제

현재 HTML은 다음과 같은 구조입니다.

```text
볼링 기록
랭킹
최근 기록

[총무 메뉴]

총무 메뉴 클릭
    ↓
로그인 화면
    ↓
점수 등록
```

하지만 이제 일반 회원도 점수를 등록할 수 있으므로 **"총무 메뉴"라는 개념을 제거하고 싶습니다.**

---

# 6. 원하는 HTML UI

메인 화면은 다음 구조로 변경해주세요.

```text
🎳 데굴데굴 볼링 기록실

등록된 게임
전체 최고점
현재 AVG 1위


🏆 누적 에버리지 랭킹

순위 / 회원 / 게임수 / 최고점 / 에버리지


🗓 최근 경기 기록

날짜 / 회원 / 점수


────────────────────────

✏️ 점수 등록

로그인 전

이메일
비밀번호

[로그인]

"로그인하면 점수를 등록할 수 있습니다."


로그인 후

회원
[ 임한별 ▼ ]

활동 날짜
[ 2026-08-18 ]

1게임
[    ]

2게임
[    ]

3게임
[    ]

[점수 등록]

[로그아웃]
```

점수는 1~3게임 중 입력된 값만 저장합니다.

예:

```text
1게임 155
2게임 178
3게임 190
```

등록하면 `bowling_scores`에 3개의 row가 추가되어야 합니다.

---

# 7. 관리자 UI

관리자로 로그인했을 때만 최근 경기 기록에 **삭제 버튼**을 보여주세요.

일반 회원에게는 삭제 버튼 자체가 보이면 안 됩니다.

현재 코드처럼 단순히

```javascript
const loggedIn = !!data.session;
```

만으로 관리자 여부를 판단하면 안 됩니다.

관리자 여부는 반드시 `bowling_admins`를 확인해야 합니다.

예:

```javascript
async function isAdmin() {

    const {
        data: { user }
    } = await db.auth.getUser();

    if (!user) {
        return false;
    }

    const { data, error } = await db
        .from("bowling_admins")
        .select("user_id")
        .eq("user_id", user.id)
        .maybeSingle();

    return !error && !!data;
}
```

이를 이용해서

```text
일반 회원 로그인
→ 점수 등록 O
→ 삭제 버튼 X

관리자 로그인
→ 점수 등록 O
→ 삭제 버튼 O
```

가 되도록 구현해주세요.

RLS에서도 실제 DELETE 권한을 관리자에게만 허용해야 하므로 UI 숨김만으로 권한을 제어하면 안 됩니다.

---

# 8. 기존 기능 유지

현재 구현된 아래 기능은 그대로 유지해주세요.

- 전체 등록 게임 수
- 전체 최고점
- 현재 AVG 1위
- 회원별 누적 게임 수
- 회원별 최고점
- 회원별 누적 에버리지
- 에버리지 기준 랭킹
- 최근 경기 기록
- Supabase Authentication 로그인
- 1~3게임 한번에 등록
- 반응형 화면
- iframe에서 자연스럽게 보이는 UI

에버리지는 다음과 같이 계산합니다.

```text
회원의 모든 bowling_scores.score 합계
/
해당 회원 게임 수
```

소수점 한 자리까지 표시해주세요.

---

# 9. Supabase 연결

현재 `index.html`에는 다음 값이 실제 Supabase 값으로 설정되어 있습니다.

```javascript
const SUPABASE_URL = "...";
const SUPABASE_PUBLISHABLE_KEY = "...";
```

이 값들은 유지해주세요.

절대 `service_role key`나 Secret key를 프론트엔드에 사용하지 마세요.

---

# 10. 구현 시 주의사항

DB를 새로 만들지 마세요.

기존 테이블:

```text
bowling_members
bowling_scores
bowling_admins
```

을 그대로 사용해주세요.

`localStorage`를 점수 저장소로 사용하지 마세요.

모든 점수는 Supabase `bowling_scores`에 저장되어야 합니다.

또한 HTML에서 사용자 입력값이나 DB의 회원명을 출력할 때 XSS 문제가 없도록 처리해주세요.

iframe 내부에서 사용할 예정이므로 화면은 가로 100% 기준으로 반응형으로 만들어주세요.

---

# 11. 결과물

다음 두 가지를 만들어주세요.

1. 수정된 최종 `index.html`
2. 현재 Supabase에 추가/수정해야 하는 RLS 정책을 모은 `update_rls.sql`

기존 `index.html`을 제공하면 해당 파일을 직접 수정하는 방식으로 작업해주세요.

코드를 작성하기 전에 기존 코드 구조를 먼저 분석하고, 어떤 부분을 변경할 것인지 간단히 설명한 뒤 수정해주세요.