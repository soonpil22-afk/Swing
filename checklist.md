# 유지보수 리팩터링 체크리스트

백업: lib 폴더 통째로 외부 폴더에 백업 완료. git도 단계마다 커밋.

## #1 디자인 토큰 공유 (tokens.dart)
- [ ] tokens.dart 생성 (공통 색 + 그림자, 값은 기존과 100% 동일 확인됨)
- [ ] main.dart 팔레트 → 토큰 alias 교체 + analyze 0
- [ ] register_page.dart 팔레트 → alias 교체 + analyze 0
- [ ] super_admin_page.dart 팔레트 → alias 교체 + analyze 0
- [ ] driver_page.dart 팔레트 → alias 교체 + analyze 0
- [ ] admin_page.dart 팔레트 → alias 교체 + analyze 0
- [ ] 웹에서 R 눌러 색 변화 없음 눈으로 확인

## #3 데이터 로딩 일관성 점검
- [ ] 각 페이지 .get() 사용처 전수 조사
- [ ] "화면 열린 동안 바뀌어야 하는데 .get()인 곳" 목록화
- [ ] 실시간 필요한 곳 snapshots()/리스너로 전환 + analyze 0

## #2 admin_page.dart 파일 분리 (가장 위험 → 마지막)
- [ ] 공유 헬퍼(_adminPanelScaffold 등) → admin_common.dart 로 이동(공개화)
- [ ] _WithdrawalRequestPage → admin_withdrawal_page.dart
- [ ] _RiderManagePage → admin_rider_manage_page.dart
- [ ] _LeaseAlertsPage → admin_lease_alerts_page.dart
- [ ] _RiderHistoryPage → admin_rider_history_page.dart
- [ ] _ChatListPage + _AdminChatPage → admin_chat_page.dart
- [ ] _FullRankingPage → admin_ranking_page.dart
- [ ] 각 이동마다 analyze 0 + 커밋
