# 리팩터링 컨텍스트 노트

## 배경
출시 직전 유지보수 개선. 사용자(코딩 입문)·웹앱(flutter run web-server :5001)으로 테스트 중.

## #1 토큰 공유 — 결정
- 모든 파일의 공통 색·그림자 값이 **100% 동일**함을 grep으로 확인.
  - 색: surface 0D1427, elevated 303854, text FBFBFB, text2 787C8D, teal 4AE3ED,
    purple 9F66E6, pink E672BA, amber E6C97F, orange E08F2A, red E05252,
    appBg 090E1A, panel 070C18, chip 18203A, borderDim 33303854, cardBorder 4D303854, text3 515D6D
  - 그림자: cardShadow=Color(0xD9000000),blur11,offset(4,6) / panelShadow=Color(0xFF18203A),blur11,offset(4,6)
- **방식: alias 유지** — 사용처(_teal 등 수백 곳) 안 건드리고, 각 파일의 *정의*만
  `const _teal = kTeal;` 로 교체. tokens.dart 가 단일 출처.
- 공개 토큰 미사용은 lint 없음(top-level public). private alias 미사용은 lint 나므로
  각 파일이 **실제 쓰는 토큰만** alias.
- 파일별 고유 토큰(_chip=driver, _red=driver, _orange=admin, _text3=super_admin)도
  tokens.dart에 포함(단일 출처), 쓰는 파일에서만 alias.

## #3 로딩 일관성 — 기준
- 화면 열려있는 동안 값이 바뀔 수 있는 데이터 = snapshots()/리스너.
- 한 번만 읽고 끝(앱 설정 등) = .get() 유지 OK.
- 이미 고친 곳: 기사 차트(정산로그·미출금 구독), 관리자 출금내역 탭, 출금랭킹.

## #2 파일 분리 — 주의점
- admin_page.dart 의 서브페이지들은 독립 클래스(_WithdrawalRequestPage 등)라 이동 가능.
- 단, 최상위 공유함수 `_adminPanelScaffold`(line~2469) 와 공유 토큰을 참조 →
  공유분을 admin_common.dart(공개)로 먼저 빼야 함.
- 메인 _AdminPageState 는 분리하지 않음(거대 단일 상태, 위험). 서브페이지만 추출.
