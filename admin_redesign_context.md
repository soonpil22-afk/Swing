# admin_page.dart 재설계 컨텍스트 노트

## 현재 구조 (변경 전)
- `AdminPage`/`_AdminPageState`: AppBar(로고+로그아웃) + 3탭(공지사항/공제설정/출금내역) TabController + 하단 4메뉴박스
- 서브 클래스: `_WithdrawalRequestPage`, `_RiderManagePage`, `_LeaseAlertsPage`, `_RiderHistoryPage`, `_ChatListPage`, `_AdminChatPage`
- 현재 팔레트(골드 계열): `_bg`, `_accent`, `_accentDim`, `_surface`, `_surface2`, `_surface3`, `_border`, `_text/2/3`, `_green`, `_red`, `_orange`

## 목표 구조 (기사페이지 대시보드형)
전체배경 → 메인배경 패널 → 세로 스크롤:
1. 인사 (동그라미 차트 + "안녕하세요 관리자 님." + 로그아웃 버튼) ← driver 그대로, 이름='관리자' 고정
2. 차트 카드 (일간/주간/월간 누적 지급액)
3. 출금 랭킹 TOP3 + 더보기(전체회원)
4. 메뉴 카드: 출금신청/출금내역 · 라이더관리(라이더/리스비) · 공제설정 · 공지사항/1:1상담

## 팔레트 매핑 (driver 기준)
- _appBg=0xFF090E1A, _panel=0xFF070C18, _surface=0xFF0D1427, _card=0xFF0E2C3C
- _elevated=0xFF303854, _chip=0xFF18203A
- _text=0xFFFBFBFB, _text2=0xFF787C8D, _text3=0xFF515D6D
- _teal=0xFF4AE3ED(메인), _purple, _pink, _amber, _red, _orange
- _cardBorder=0x4D303854, _borderDim=0x33303854
- _cardShadow = [BoxShadow(0xD9000000, blur 11, offset(4,6))] (오른쪽+아래)

## 결정 사항
- 차트 데이터: admin_settlement_logs '지급완료' amount 날짜별 누적 (입금확인분 누적)
- 출금 랭킹 TOP3: **주간/월간 토글**, 해당 기간 지급완료 총액 순
- 메뉴 네비게이션: 기존 서브페이지 재사용
  - 출금신청/출금내역 → _WithdrawalRequestPage(또는 탭)
  - 라이더 → _RiderManagePage, 리스비 → _LeaseAlertsPage
  - 공제설정 → 요율 설정 화면(_settingsTab 내용)
  - 공지사항 → 공지 편집, 1:1상담 → _ChatListPage

## 토큰 매핑(완료) — 이름 유지, 값만 네이비+민트
- _bg=090E1A, _surface=0D1427(카드), _surface2=18203A(칩/탭트랙/다이얼), _surface3=0E2C3C(인디케이터/버튼)
- _accent=4AE3ED(민트), _accentDim=303854(테두리), _border=4D303854, _borderDim=33303854
- _text=FBFBFB, _text2=787C8D, _text3=515D6D, _red/_orange/_green 유지

## 진행 로그
- S1 완료: 팔레트 14토큰 네이비+민트로 이식 (recolor). analyze 에러 0.
- S2 완료: 홈을 대시보드로 재구성.
  - AppBar+3탭+하단메뉴 제거, TabController/SingleTickerProviderStateMixin 제거
  - 구조: Scaffold(_bg) → SafeArea/Padding → Container(_panel) → ClipRRect → 대시보드 or 서브뷰
  - `_homeView`(null/notice/settings/withdrawal) 상태로 같은 State 안에서 화면 전환 (setState 갱신 보존)
  - 인사(_greeting, 관리자) + 메뉴 그룹 카드 4개(_menuGroupCard/_menuPillBtn/_badgePill)
    - 출금신청[출금신청·출금내역] / 라이더관리[라이더·리스비] / 공제설정 / 공지사항[공지사항·1:1상담]
    - badge 카운트(출금신청 요청대기/리스비 미납/상담 미읽음) 유지
  - 공지/공제설정/출금내역 → _subView로 전환(뒤로가기 헤더). 출금내역 진입 시 _loadWithdrawalData 호출.
  - 추가 토큰: _panel/_purple/_pink/_amber/_cardShadow, _greet*, _menu* (모두 사용됨)
- S3 완료: 차트 카드(누적 지급액).
  - `_adminChartCard` + `_chartToggle` + `_AdminAreaChartPainter`(기사 차트 포팅, 링게이지 제외)
  - 데이터: `_loadAdminChart` — admin_settlement_logs '지급완료' amount를 approvedAt(없으면 date) 기준 byDay 집계 → 일/주/월 최근 7버킷 series + labels, grandTotal(누적 총액)
  - 헤드라인 = 누적 총 지급액(_chGrandTotal), 토글은 추이 차트 granularity, delta는 마지막/직전 버킷 비교
  - import 'dart:math' as math; 추가, intl은 hide TextDirection로 변경(painter TextDirection.ltr 충돌 해결), _elevated 토큰 추가(=303854)
  - 토큰: _chart*, _chTog*, _ch* (전부 사용)
- S3+ 링 게이지 추가: 목표치 편집 포함.
  - `_ringTargets`[일/주/월] (기본 20만/100만/400만), `_targetButton`(기간색, 탭하면 `_editChartTarget` 다이얼로그), `_ringGauge`+`_ringColorFor`+`_RingGaugePainter`(포팅, _teal=_accent 별칭)
  - pct = 최근 버킷값(last) / 목표. 차트 카드 우측에 링 배치(기사 차트와 동일 레이아웃)
- S4 완료: 출금 랭킹 TOP3 카드.
  - `_loadAdminChart`에 기사별 이번주/이번달 지급합계(riderName 기준) 계산 추가 → `_rankWeek`/`_rankMonth`(내림차순)
  - `_rankingCard`(주간/월간 토글 `_rankToggle`, TOP3 행 `_rankRow`, 더보기→`_openFullRanking`)
  - `_FullRankingPage`(전체회원 랭킹, 패널 구조)
  - 순위 뱃지 색: 1=amber 2=text2(은) 3=orange(동)
  - 토큰: _rank*, _rankBadge* 등
- S5 완료: 공통 패널 래퍼 `_adminPanelScaffold(context, title, child)` 추가 + 전 서브페이지 적용.
  - 적용: _WithdrawalRequestPage, _RiderManagePage, _LeaseAlertsPage, _ChatListPage, _AdminChatPage(입력창 유지), _RiderHistoryPage(탭은 인라인 패널)
  - 전부 AppBar 제거 → 패널(전체배경→메인배경) + 뒤로가기 헤더로 통일. analyze 에러 0.
- S6 완료: 출금신청 카드 외형+헤더 토큰화 + 그림자(_cardShadow). 토큰 [6] _wr*. (펼침 상세 행은 미토큰화)
- S7 완료: 라이더관리 목록 카드 그림자+토큰([7] _rm*), 리스비 카드 그림자(상태색 유지).
- S8 완료: 공제설정(_settingsTab) 메인 카드 그림자.
- S9 완료: 공지사항(_noticeTab) — 통계카드/공지박스(_noticeBox)/가입신청카드 그림자. 1:1상담은 S5 패널 적용으로 구조 완료(말풍선/리스트는 대화 UI라 카드 그림자 비대상).
- 공통 패널 래퍼: _adminPanelScaffold(context, title, child).
- === admin 재설계 1차 완료 (S1~S9): 전체 구조·팔레트·주요 카드 그림자 통일 ===
- 남은 선택작업: 출금신청 펼침 상세 행, 라이더/리스비 카드 내부 행의 글씨/숫자 세부 토큰화(원하면 화면 지정해 진행).

## 토큰 재정리 (driver_page 스타일, 메뉴 허브별 번호 섹션) — 완료
상단 const 블록을 4개 허브로 번호 섹션화. 값만 바꾸면 Ctrl+S로 조정 가능.
- [1] 출금신청: [1-1] 출금신청 카드 `_wr*`, [1-2] 출금내역 `_wh*`
- [2] 라이더관리: [2-1] 라이더 목록 `_rm*`, [2-2] 리스비 `_la*`(여백/정보행/버튼)
- [3] 공제설정: [3-1] 리포트 업로드 카드 `_st*`(여백/카드/안내/수정저장/구분선/항목행/업로드버튼)
- [4] 공지사항: [4-1] 공지 `_nt*`(통계카드/공지박스/가입신청), [4-2] 1:1상담 `_cs*`(목록 카드)
- 각 단계마다 flutter analyze error 0 확인. 기존 24 issues(dead code: _statsTab/_showWithdrawalSheet/_lastUploadTime/_fmt 등)만 잔존.
- 알려진 기존 dead code(제 작업 무관): _statsTab, _showWithdrawalSheet, _lastUploadTime, _fmt 미사용.

## 리스비 전체현황 카드 스타일 통일 (driver와 100% 일치) — 완료
- 요청: 기사페이지(_leaseSummaryCard, driver_page.dart:3464) 색/글씨크기/테두리색/배경색/스타일만 admin에 그대로. 로직은 유지.
- 토큰값 변경(_la*): _laInfoLabelColor _text2→_text, _laInfoFontSize 11→12, _laCardBorder _elevated→0x4D303854(_cardBorder값), _laCardTitleColor _text2→_text, _laCardTitleFontSize 12→13, _laRowFontSize 11→12, _laRowValueFontSize 12→16.
- _infoRow 헬퍼에 labelColor/labelFs 파라미터 추가(driver _infoRow2와 동일 시그니처).
- 인라인: 헤더 아이콘 moped/_text2/15 → directions_bike_outlined/_teal/16, 칩 bg/border/글씨 0xFF18203A·0x4D303854·11·pad(8,3)·radius6, 구분선 _teal→_elevated@0.6 margin v10, 진행/납부 라벨·값 _amber, 잔여 _teal, 진행 total 17, 진행바 track 0xFF18203A, 행 간격 driver값(5/10/6/8/3).
- 유지(로직): 데이터 계산, 기간 칩 납기초과 분홍/민트 색, 입금확인/취소 버튼.
- flutter analyze: No issues found.

## 리스비 카드 강조색 단순화 (admin + driver 동일) — 완료
- 규칙: 강조(주의)는 카드 테두리에만 _pink. 이름·뱃지는 상태 무관 항상 _teal. 주황(_orange) 제거.
- admin(_LeaseAlertsPage): 테두리 로직 → 완납 teal / hasDue(_pink) / hasRiderPaid teal. 이름칩 항상 teal(bg/border/글씨). 뱃지 입금완료!·오늘 납기!·납기초과 전부 teal. 이름 옆 "리스비" 글자 삭제 + orphan _laTagFontSize 토큰 제거.
- driver: _lsCardBorderAlert _amber→_pink, _lpDueBoxColor("오늘 납기일" 박스) _orange→_teal.
- admin analyze 0건. driver 11건은 전부 기존 dead code/스타일 lint(편집 위치 444·480행과 무관).

## 관리자 버튼 글래스 샤인 전환 — 완료
- admin_page 전 버튼을 GlassShineButton으로. 의미별 색: 확인/저장/입금확인/입금완료/업로드=teal, 취소=text2(회색), 초기화=pink.
- 동일 다이얼로그 "확인" 3곳 replace_all 처리. 입금완료 버튼은 onPressed(async) 보존 위해 껍데기만 2단계 교체.
- orphan 토큰 9개 제거(_laBtnBg/_laBtnText/_laConfirmBorder/_laCancelBorder/_laPlusBorder/_laPlusText/_stUploadBg/_stUploadText/_stUploadBorder). analyze 0.

## 테스트 시드/삭제 — 완료
- lib/dev_seed.dart: seedTestData()/deleteTestData(). 모든 시드 문서에 isTestData:true 마커.
- 가짜 기사 10명(users, role=driver/isApproved) + lease_payments(매일20/주1회8/매월3 회차, paidCount·납기상태(오늘/초과/정상)·riderPaid 다양화) + admin_settlement_logs(기사당 3건, approvedAt 최근7일/주/월 → 차트·랭킹·총배달건수). 문서ID 고정(test_rider_n, _c$c, _log$k)이라 재실행 시 덮어씀.
- 관리자 대시보드 최상단에 임시 _devSeedPanel(🧪 시드 생성/삭제 글래스 버튼) 추가. 배포 전 제거 대상: dev_seed.dart import, _devBusy 필드, _devSeedPanel()/_runDev(), _dashboard()의 _devSeedPanel() 호출.
- Firestore 보안규칙상 쓰기는 관리자 로그인 상태에서 실행 권장.

## 헤더 박스 정리 + 강조색 핑크→앰버 (admin + driver) — 완료
- admin 헤더: 이름 배경 박스 제거·글씨 _text, 매일 박스 _amber, 오늘 납기 박스 _teal(! 제거), 두 박스 글씨 크기=이름 크기.
- 강조색 핑크→앰버(핑크 비호감): admin 카드 테두리(hasDue)·기간 납기초과 칩·일일 납부방식 라벨 → _amber. driver _lsCardBorderAlert·_lsInfoPinkColor·_lsPayMethodLabelColor → _amber.
- 이름 크기 _laRiderNameFontSize 13→14 (매일·오늘 납기 박스도 연동).

## 폰트 Pretendard 전역 적용 — 완료
- Pretendard는 Google Fonts 미포함 → PretendardVariable.ttf를 assets/fonts에 번들(가변폰트 1개).
- pubspec fonts 등록 + main.dart MaterialApp theme: ThemeData(fontFamily: 'Pretendard'). 핫리스타트 필요.

## 글래스 샤인 버튼 — 로그인 + 기사페이지 전 버튼 적용 — 완료
- 참고: 프로젝트 루트 "Button Styles.html" 3번 .b-glass(반투명 유리 + 누를 때 빛줄기 sweep).
- 공통 위젯 lib/glass_shine_button.dart (GlassShineButton): label?/icon?/accent/textColor/width?/height/radius/fontSize/loading/pill. BackdropFilter blur 8 + 흰색 반투명 + accent 테두리 + 누름 시 skew sweep 애니메이션 + scale 0.975.
- 색은 앱 _teal(#4AE3ED) 기본. 의미별 색 유지: 확인/입금완료=teal, 출금신청=amber, 취소·새로고침=text2(회색), 로그아웃=purple.
- main.dart 로그인 버튼(_buildLoginBtn 제거, _chip orphan 제거).
- driver_page: 로그아웃 아이콘, 출금신청(_WithdrawButton 러닝라이트 클래스+_RunningBorderPainter+_wBtnGlow* 토큰 제거), 리스비 입금완료, 새로고침, 다이얼로그 확인(정보/리스비/공지), 출금확인 취소·확인, 목표편집 취소·저장.
- orphan 토큰 30개 정리(_greetLogout색2, _tgtDlg색2, _wBtn/_wBtnGlow, _wdlg버튼색, _ntcDlgBtn색, _lpPayBtn색). analyze error/warning 0, unused 0.
