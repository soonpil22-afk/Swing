# 📍 SwingTiger 코드 지도 (lib)

> **헷갈릴 때 이 파일만 열면 돼요.** 외울 필요 없어요 — 여기서 찾으면 됩니다.
>
> 현재는 모든 파일이 `lib/` 안에 평평하게 있어요. 아래는 **분류(= 앞으로 만들 폴더)별**로 묶은 거예요.
> "기사 화면 고치고 싶다 → 🛵 기사 칸에서 찾기" 식으로 쓰세요.

---

## 🧱 핵심 (lib 루트 유지)
| 파일 | 역할 |
|---|---|
| `main.dart` | 앱 진입점 (+ 로그인) ⚠️첫줄주석없음 |
| `tokens.dart` | **색·크기 토큰 단일 출처** — 색 바꾸려면 여기 |
| `firebase_options.dart` | 플랫폼별 Firebase 초기화 옵션 |

## 🔑 auth/ — 로그인·가입
| 파일 | 역할 |
|---|---|
| `register_page.dart` | 회원가입 페이지 ⚠️첫줄주석없음 |
| `user_approval_page.dart` | 가입 승인/사용자 처리 ⚠️첫줄주석없음 |

## 🛠️ admin/ — 관리자 화면
| 파일 | 역할 |
|---|---|
| `admin_page.dart` | 관리자 메인 페이지 (홈·하단탭) ⚠️첫줄주석없음 |
| `admin_chat_page.dart` | 관리자 1:1 상담 (목록 + 채팅) |
| `admin_common.dart` | 관리자 서브페이지 공용 스캐폴드 (뒤로가기 헤더 래퍼) |
| `admin_lease_alerts_page.dart` | 공제 납부 현황 — 라이더별 리스비/기타 진행·알림 |
| `admin_ranking_page.dart` | 출금 랭킹 더보기 (전체 순위) |
| `admin_rider_history_page.dart` | 라이더 정산내역/누적정산 + 날짜별 상세 |
| `admin_rider_manage_page.dart` | 라이더 관리 — 목록/검색 + 은행·계좌·리스비 설정 |
| `admin_withdrawal_page.dart` | 출금신청 처리 — 요청대기 카드 + 지급완료 |

## 🛵 driver/ — 기사 화면
| 파일 | 역할 |
|---|---|
| `driver_page.dart` | 기사 메인 페이지 (홈·하단 4버튼) ⚠️첫줄주석없음 |
| `driver_chat_page.dart` | 기사 1:1 상담 (공용 ChatView 사용) |
| `driver_common.dart` | 기사 공용 헬퍼 (포맷·안내창·헤더·배지) |
| `driver_history_page.dart` | 정산내역 카드 + 출금내역 조회 |
| `driver_lease_page.dart` | 공제 현황 — 리스비/기타 전체현황 카드 |
| `driver_partners_page.dart` | 협력업체 안내 (준비중·제휴 예정) |
| `driver_settings_page.dart` | 설정 — 내 정보(이름·은행·계좌) |
| `driver_timeline_page.dart` | 타임라인 — 동선 기록 시작/종료, 오늘 경로 지도 |
| `driver_timeline_history_page.dart` | 지난 동선 — 날짜별 기록 + 경로 다시보기 |

## 🤝 shared/ — 공용 (관리자·기사 둘 다 씀)
| 파일 | 역할 |
|---|---|
| `chat_view.dart` | **공용** 1:1 채팅 위젯 (mySide로 시점만 다름) |
| `lease_summary_card.dart` | **공용** 리스비/기타 "전체 현황" 카드 |
| `withdrawal_breakdown_card.dart` | **공용** 출금내역/누적정산 "기간별 합계" 카드 |
| `lease_status.dart` | **공용** 납부 상태(칩) 판정 + 기준일 계산 |
| `settlement.dart` | **공용** 정산 계산 단일 출처 (날짜별 공제·순출금액) |
| `glass_shine_button.dart` | 공용 글래스 샤인 버튼 위젯 |
| `app_dialogs.dart` | 공용 다이얼로그 (종료 확인 등) |
| `location_tracker.dart` | 동선 기록 서비스 (위치→Firestore 누적) |
| `route_map_view.dart` | 경로를 지도에 그리고 재생하는 공용 위젯 |

## 🎮 game/ — 미니게임
| 파일 | 역할 |
|---|---|
| `block_puzzle_game.dart` | 블록 퍼즐 (테트리스류) + 점수 랭킹 연동 |
| `game_ranking_page.dart` | 미니게임 점수 랭킹 (상위 10 + 본인 순위) |

## 👑 superadmin/ — 슈퍼관리자
| 파일 | 역할 |
|---|---|
| `super_admin_page.dart` | 운영 제어 (앱 전체 사용 on/off 등) |

---

### 🔎 찾는 법
- **색/크기 바꾸기** → `tokens.dart`
- **기사 화면** → 🛵 driver
- **관리자 화면** → 🛠️ admin
- **둘 다 쓰는 카드/위젯** → 🤝 shared (여기 있는 건 한 곳만 고치면 양쪽 다 바뀜)
- **새 파일 만들 때** → 분류에 맞는 폴더 + 앞에 `admin_`/`driver_` 접두어 + 첫 줄 한글 주석 (안 그러면 또 미아됨)
