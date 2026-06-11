# 타임라인(동선 기록) 기능 체크리스트

## 목표
기사가 "기록 시작"을 누르면 GPS 동선을 자동 기록하고(앱 백그라운드 포함), 하루 경로를
지도(google_maps_flutter)에 폴리라인으로 보여준다. 경로를 차례대로 재생(애니메이션)한다.
"기록 종료" 또는 자정(24:00) 자동 종료.

## 결정 사항 (context-notes.md 참고)
- 지도: google_maps_flutter (API 키 필요)
- 위치: geolocator (distanceFilter 기반, 배터리 절약)
- 기록: 수동 시작/종료 + 자정 자동 종료, 백그라운드 지속(안드 포그라운드 서비스)
- 데이터: location_tracks/{uid}_{yyyy-MM-dd} 문서에 points 배열 누적

## 작업
- [x] 1. 패키지 추가 (geolocator, google_maps_flutter) → pub get 성공
- [x] 2. 안드로이드 네이티브 설정 (위치/백그라운드 권한, 포그라운드 서비스, Maps API 키 자리)
- [x] 3. iOS 네이티브 설정 (Info.plist 위치 설명·백그라운드 모드, AppDelegate Maps 키 자리)
- [x] 4. 웹 설정 (Maps JS 스크립트 자리) + 웹 GPS 비활성 안내 → 웹 빌드 성공
- [x] 5. LocationTracker 서비스 (스트림·Firestore 기록·자정 자동종료)
- [x] 6. DriverTimelinePage (지도+기록 토글+경로 폴리라인+재생)
- [x] 7. driver_page 타임라인 버튼을 DriverTimelinePage로 교체
- [ ] 8. Firestore 규칙에 location_tracks 추가 → 로컬 규칙 파일 없음(콘솔 관리). context-notes에 추가할 규칙 명시함. 사용자가 콘솔에 반영 필요.
- [x] 9. `flutter analyze` error 0 + `flutter build web` 성공 확인

## 사용자 액션 필요
- [ ] Google Maps API 키 발급 후 안내한 위치에 입력
- [ ] 실제 단말에서 GPS 기록/지도 동작 테스트(웹·에뮬레이터로는 한계)
