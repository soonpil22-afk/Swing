# 유지보수 리팩터링 체크리스트

백업: lib 폴더 통째로 외부 폴더에 백업 완료. git도 단계마다 커밋.

## #1 디자인 토큰 공유 (tokens.dart) — 완료
- [x] tokens.dart 생성 (공통 색 + 그림자, 값 100% 동일 확인)
- [x] main / register / super_admin / driver / admin 팔레트 → alias 교체 + analyze 0

## #3 데이터 로딩 일관성 점검 — 완료
- [x] .get() 전수 조사
- [x] 기사 홈 app_status(킬스위치)·공지 → snapshots() 실시간화 + analyze 0
- [x] 서브페이지(.get())는 열 때마다 새로 보는 화면이라 유지

## #2 admin_page.dart 파일 분리 — 완료 (5,260 → 2,456줄)
- [x] 공유 스캐폴드 → admin_common.dart (공개화)
- [x] _ChatListPage+_AdminChatPage → admin_chat_page.dart
- [x] _WithdrawalRequestPage → admin_withdrawal_page.dart
- [x] _LeaseAlertsPage → admin_lease_alerts_page.dart
- [x] _RiderHistoryPage → admin_rider_history_page.dart
- [x] _RiderManagePage → admin_rider_manage_page.dart
- [x] _FullRankingPage → admin_ranking_page.dart
- [x] 각 이동마다 analyze 0 + 커밋
