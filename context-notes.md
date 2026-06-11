# 타임라인(동선 기록) 컨텍스트 노트

진행하며 내린 결정과 이유를 계속 덧붙인다.

## 2026-06-11 초기 결정
- **요청**: 타임라인 메뉴(현재 준비중)에 실제 GPS 동선 기록 + 지도 표시 기능.
  - 5요건: 실시간 위치 자동기록 / 동선 자동기록 / 하루 경로 한눈에 / 차례대로 재생 / 배터리 걱정없는 GPS.
- **지도 = google_maps_flutter** (사용자 선택). → Google Cloud API 키 필요. 발급은 사용자 몫.
- **기록 모델 = 수동 시작/종료 + 자정 자동종료, 앱 닫아도 지속** (사용자 선택).
- **위치 패키지 = geolocator (무료)**. 이유: google_maps_flutter와 궁합, distanceFilter로 배터리 절약,
  안드 포그라운드 서비스 옵션 내장. 완전 강제종료 생존은 미보장(아래 한계).

## 2026-06-11 지도 변경: google_maps_flutter → flutter_map (OSM)
- 사용자 요청: Google Maps API 키 발급 부담 → 키 불필요한 flutter_map(OpenStreetMap)으로 교체.
- 제거: google_maps_flutter 의존성, 안드 매니페스트 Maps 키 meta-data, iOS AppDelegate GMSServices,
  웹 index.html Maps 스크립트. (위치 권한은 geolocator용으로 유지)
- 추가: flutter_map, latlong2. 타일은 OSM 공개 타일서버.
- 테스트용 "샘플 동선 넣기" 버튼은 검증 후 제거함. 그 자리에 "기록 시작 전 위치 권한 설정 → 항상 허용"
  핑크 안내 문구로 교체.

## 한계 (사용자에게 고지함)
- geolocator + 안드 포그라운드 서비스: 백그라운드·앱 스와이프 제거까지는 기록 지속.
  단, OS 강제종료 시 멈출 수 있음. 완전 생존은 유료 flutter_background_geolocation 필요.
- iOS: 백그라운드 모드 location + allowBackgroundLocationUpdates로 suspend 중 지속.
  강제종료(force-quit) 후엔 멈춤(애플 정책).
- 웹: 백그라운드 GPS 불가. 웹에서는 기록 기능 비활성 + 안내만.

## 데이터 모델
- 컬렉션 `location_tracks`, 문서 ID `${uid}_${yyyy-MM-dd}` (하루 1문서, 단순 조회).
  - 필드: uid, date(yyyy-MM-dd), startedAt(ts), endedAt(ts|null), active(bool),
    points: [{lat, lng, t(epochMs)}, ...]
- SwingTiger 규칙 F 준수: where+orderBy 조합 회피. 문서 단건 조회로 정렬 불필요.
- 1MB 문서 한도: distanceFilter(기본 20m)로 포인트 수 제한. 하루 수백~수천 포인트 예상(안전).

## Firestore 규칙 (콘솔에 직접 추가 필요 — 로컬 .rules 파일 없음)
```
match /location_tracks/{docId} {
  allow read, write: if request.auth != null;
}
```
규칙 미추가 시 permission-denied로 기록·조회 무한로딩(규칙 I 참고).

## API 키 자리
- 안드: android/app/src/main/AndroidManifest.xml <meta-data android:name="com.google.android.geo.API_KEY">
- iOS: ios/Runner/AppDelegate.swift (GMSServices.provideAPIKey) — 또는 AppDelegate에 추가
- 웹: web/index.html <script ...maps...key=>
