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

## 2026-06-11 추가: 끊김 감지·이어서 시작·지난 동선
- LocationTracker.resume(uid): startedAt·기존 points 보존하고 active=true로 되살려 재기록.
- 끊김 감지: 타임라인 진입 시 문서 active=true인데 isRecording=false면 비정상 끊김으로 보고
  "이어서 시작/아니오" 다이얼로그 1회. 아니오 → active=false로 마감.
- route_map_view.dart: 지도+폴리라인+재생을 공용 위젯 RouteMapView로 추출(오늘·지난 동선 공용).
  parseRoutePoints()도 여기로 이동(중복 제거). 재생 버튼은 지도 우하단 오버레이로 이동.
- driver_timeline_history_page.dart: uid 단일 where로 날짜 목록(클라 정렬 desc), 탭 시 그 날 경로 보기.
- 한글 요일은 로케일 데이터 미초기화라 'ko' DateFormat 대신 수동 매핑(_kWeek).

## 2026-06-11 미니게임 변경: 스윙 러시 → 블록 퍼즐(테트리스류)
- 스윙 러시(swing_rush_game.dart)는 완성난이도 높아 폐기·삭제. 블록 퍼즐로 대체.
- block_puzzle_game.dart: 10x20 보드, 7블록(I,O,T,S,Z,J,L) 4x4 문자열 정의 + 간단 벽킥.
  AnimationController(repeat) 프레임 + dt 누적으로 중력 낙하. CustomPainter 렌더.
  조작 버튼: ◀ ⟳ ▶ 하드드롭. 줄 클리어 점수[100/300/500/800]×레벨, 10줄마다 레벨업(속도↑).
- 점수 저장: 게임오버 시 game_scores/{uid} (uid,name,score,updatedAt)에 "최고점 갱신 시에만" set.
  name은 users/{uid}.name 1회 조회.
- game_ranking_page.dart: game_scores 전체 구독→화면 정렬(규칙 F). 상위 10 + 본인이 10등 밖이면
  본인 순위만 따로 표시. 라이더 수 적어 전량 조회 OK.
- tokens.dart에 kBlue/kGreen 추가(블록 7색용, 규칙 A 준수).
- ★ Firestore 규칙에 game_scores 추가 필요(콘솔): match /game_scores/{docId} { allow read, write: if request.auth != null; }
- 배경음악: audioplayers 추가, assets/Tetris_Bradinsky.mp3(로열티프리 코로베이니키) 무한반복.
  시작 시 재생·게임오버/나갈 때 정지. 우상단 🔊/🔇 음소거 토글(shared_preferences 'game_muted').
  곡 멜로디는 퍼블릭도메인 민요라 사용 OK, 게임명은 "블록 퍼즐" 유지(테트리스 상표 회피).

## 2026-06-11 하단 4버튼 카드를 하단바로 고정 + 기사 메뉴 개편
- 관리자·기사 모두 build를 Column[Expanded(기존 패널/Stack), 하단 고정 _bottomMenuCard] 구조로 변경.
  하단바는 스크롤되지 않고 항상 보임(관리자는 모든 서브뷰에서도 보이는 영구 내비 역할).
- 기사 하단바 순서: 설정 | 협력업체 | 미니게임 | 타임라인. "준비중"→"협력업체"로 교체.
  DriverSoonPage는 더 이상 사용 안 해 삭제. driver_partners_page.dart 신설(준비중입니다!! + 6개 업종 목록).
- 미니게임 시작화면 시작버튼 아래 "배달플랫폼 알림 루틴 설정 필수!!" 핑크 안내 추가.

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
