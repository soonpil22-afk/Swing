import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border, BorderStyle, TextSpan;
import 'main.dart';
import 'glass_shine_button.dart';
import 'tokens.dart';
import 'admin_chat_page.dart';
import 'admin_withdrawal_page.dart';
import 'admin_lease_alerts_page.dart';
import 'admin_rider_manage_page.dart';
import 'admin_ranking_page.dart';

// ═══════════════════════════════════════════════════════════════════════
// 공통 색 팔레트 (tokens.dart 단일 출처를 가리키는 별칭)
// ═══════════════════════════════════════════════════════════════════════
const _surface  = kSurface;  // 카드
const _elevated = kElevated; // 트랙 · 테두리
const _text  = kText;
const _text2 = kText2;
const _teal     = kTeal;     // 민트 (메인 액센트)
const _purple   = kPurple;   // 보라
const _pink     = kPink;     // 핑크
const _amber    = kAmber;    // 노랑
// 카드 그림자 (모든 카드 공통)
const List<BoxShadow> _cardShadow = kCardShadow;

// ═══════════════════════════════════════════════════════════════════════
// 1. 전체배경
// ═══════════════════════════════════════════════════════════════════════
const _appBg    = kAppBg; // 전체 화면 Scaffold 배경색

// ═══════════════════════════════════════════════════════════════════════
// 2. 메인배경 (inset 패널) — 모든 페이지 공통
// ═══════════════════════════════════════════════════════════════════════
const _panel    = kPanel; // 메인 배경(패널) 배경색
// 메인 패널 그림자
const List<BoxShadow> _panelShadow = kPanelShadow;
// 메인 패널 테두리·여백
const Color  _panelBorderColor = _elevated; // 패널 테두리 색
const double _panelBorderAlpha = 1.0;        // 패널 테두리 투명도 (1.0=솔리드)
const double _panelBorderWidth = 1;          // 패널 테두리 두께
const double _panelOuterPad    = 10;
const double _panelRadius      = 24;
// 서브페이지 헤더 아래 경계선 (더보기·출금신청·라이더관리·공제설정·공지사항 공통)
const Color  _subDivColor       = _elevated; // 경계선 색
const double _subDivMarginH     = 15;        // 경계선 좌우 여백(끝까지 안 붙음)
// 페이지별 헤더↔경계선 / 경계선↔카드 갭 (각자 따로 조정)
const double _wrPageGapHeaderDiv = 0; const double _wrPageGapDivCard = 4; // 출금신청
const double _rmPageGapHeaderDiv = 0; const double _rmPageGapDivCard = 4; // 라이더관리
const double _stPageGapHeaderDiv = 0; const double _stPageGapDivCard = 0; // 공제설정
const double _ntPageGapHeaderDiv = 0; const double _ntPageGapDivCard = 4; // 공지사항
// 탭 ↔ 첫 카드 갭 (페이지별)
const double _ntTabToStatGap    = 2; // 공지사항 탭 ↔ 누적방문 카드 갭
const double _ntStatToNoticeGap = 8; // 누적방문 카드 ↔ 공지사항 갭
// ═══════════════════════════════════════════════════════════════════════
// 3. 안녕하세요 (인사)
// ═══════════════════════════════════════════════════════════════════════
// ── 색 (팔레트에서 선택) ──
const Color _greetIconOuterColor  = _teal;    // 바깥 원 색
const Color _greetIconInnerColor  = _purple;  // 안쪽 원 색
const Color _greetHelloColor      = _text;    // "안녕하세요," 글씨 색
const Color _greetNameColor       = _amber;   // 이름 글씨 색
const Color _greetSuffixColor     = _text;    // " 님" 글씨 색
const Color _greetLogoutIconColor = _purple;  // 로그아웃 아이콘 색
// ── 글씨 크기 (각각 따로) ──
const double _greetHelloFontSize  = 18;  // "안녕하세요," 크기
const double _greetNameFontSize   = 18;  // 관리자
const double _greetSuffixFontSize = 18;  // " 님" 크기
// ── 숫자 (아이콘·버튼 크기/여백) ──
const double _greetIconOuterSize  = 22;  // 바깥 원 지름
const double _greetIconInnerSize  = 12;  // 안쪽 원 지름
const double _greetIconGap        = 12;  // 원과 글씨 사이 간격
const double _greetLogoutBoxSize  = 38;  // 로그아웃 버튼 크기
const double _greetLogoutRadius   = 10;  // 로그아웃 버튼 모서리
const double _greetLogoutIconSize = 19;  // 로그아웃 아이콘 크기
// ── 표시 문구 ──
const String _greetHelloText    = '안녕하세요!! ';
const String _greetSuffixText   = '님.';
const String _greetNameFallback = '관리자';

// 대시보드 섹션 사이 간격
const double _gapGreetChart = 6; // 인사 ↔ 차트
const double _gapChartRank  = 6; // 차트 ↔ 출금랭킹
const double _gapRankMenu   = 6; // 출금랭킹 ↔ 하단 메뉴카드

// ═══════════════════════════════════════════════════════════════════════
// 4. 차트 (누적 지급액 · 일간/주간/월간)
// ═══════════════════════════════════════════════════════════════════════
const _chartCardBg     = _surface;
const _chartCardBorder = _elevated;
const double _chartCardRadius = 14;
const double _chartCardPadL   = 2;  // 차트카드 안쪽 여백 왼
const double _chartCardPadT   = 12;  // 위
const double _chartCardPadR   = 2;  // 오른
const double _chartCardPadB   = 10;  // 아래
// 토글
const double _chTogFontSize   = 12;   // 토글 글씨 크기
const double _chTogPadH       = 10;
const double _chTogPadV       = 5;
const double _chTogGap        = 6;
const double _chTogRadius     = 20;
const _chTogUnselColor  = _text2;     // 미선택 글씨
// "총 지급액" 라벨 색은 기간 색(일간 민트/주간 핑크/월간 보라)을 따라감
const double _chLabelFontSize  = 13;  // 1줄 "총 지급액" 글씨 크기 (색=기간색)
const double _chLine1LeftPad   = 45;  // 1줄(총지급액) 오른쪽 이동
const double _chLine2LeftPad   = 24;  // 2줄(금액 원) 오른쪽 이동
const double _chLine3LeftPad   = 16;  // 3줄(증감률) 오른쪽 이동
const double _chHeadGap1       = 4;   // 1줄(총지급액) ↔ 2줄(금액) 간격
const double _chHeadGap2       = 8;   // 2줄(금액) ↔ 3줄(증감률) 간격
const _chAmtColor       = _text;      // 금액 숫자 색
const double _chAmtFontSize    = 22;  // 금액 숫자 크기
const _chUnitColor      = _text;      // " 원" 글씨 색
const double _chUnitFontSize   = 14;  // " 원" 글씨 크기
const double _chDeltaFontSize  = 13;  // 증감률 글씨 크기
const double _chCompareFontSize = 12; // "전일 대비" 글씨 크기
// 차트 카드 테두리·줄 간격
const double _chartCardBorderAlpha = 0.3; // 카드 테두리 투명도
const double _chartCardBorderWidth = 1;   // 카드 테두리 두께
const double _chGapToggleHead = 14; // 토글줄 ↔ 총지급액 갭
const double _chGapTextRing   = 12; // 텍스트 ↔ 링게이지 갭
const double _chGapHeadChart  = 16; // 헤더 ↔ 차트 갭
const double _chGapChartAxis  = 8;  // 차트 ↔ 요일라벨 갭
const double _chTrendIconSize = 16; // 증감 아이콘 크기
const double _chGapTrendPct   = 4;  // 증감아이콘 ↔ % 갭
const double _chGapPctCompare = 6;  // % ↔ 대비문구 갭
// 영역 차트
const _chartLineColor   = _teal;    // 차트 선 색(민트)
const double _chartLineWidth = 2.5;
const double _chartHeight    = 64;    // 차트 높이
const double _chartPeakDotOuter = 3.6;
const double _chartPeakDotInner = 1.6;
const _chartPeakDotColor   = Color(0xFFFBFBFB);
const _chartPeakLabelColor = _text;
const double _chartPeakLabelFontSize = 10.5;
const _chAxisLabelColor = _text2;     // 아래 요일/날짜 라벨 색
const double _chAxisLabelFontSize = 11;
// 링 게이지 + 목표
const double _ringBoxSize       = 84; // 링 전체 크기
const double _ringStroke        = 9;  // 링 두께
const double _ringPctFontSize   = 18; // 가운데 % 글씨 크기
const double _ringLabelFontSize = 10; // "달성" 글씨 크기
const double _ringTrackAlpha    = 0.5;// 배경 트랙 투명도
const double _targetFontSize    = 11; // 목표 버튼 글씨 크기
const double _targetPadH        = 11;
const double _targetPadV        = 5;
const double _targetRadius      = 20;
const double _targetBgAlpha     = 0.12;
const double _targetBorderAlpha = 0.5;
// 목표 금액 입력 다이얼로그
const _tgtDlgBg          = _surface;  // 다이얼로그 배경색
const _tgtDlgBorderColor = _elevated;   // 다이얼로그 테두리 색
const double _tgtDlgBorderWidth = 1;  // 다이얼로그 테두리 두께
const double _tgtDlgRadius      = 14; // 다이얼로그 모서리

// ═══════════════════════════════════════════════════════════════════════
// 5. 출금랭킹 (TOP5)  ·  5-1 더보기(전체 랭킹 페이지, 카드/행 상수 공유)
// ═══════════════════════════════════════════════════════════════════════
const _rankCardBg     = _surface;
const _rankCardBorder = _elevated;
const double _rankCardRadius = 14;
const double _rankCardPadL   = 16;  // 랭킹카드 안쪽 여백 왼
const double _rankCardPadT   = 8;  // 위
const double _rankCardPadR   = 16;  // 오른
const double _rankCardPadB   = 8;  // 아래
const _rankTitleColor   = _text;
const double _rankTitleFontSize = 14;  // "출금 랭킹 TOP5" 글씨 크기
const double _rankTitleIconSize = 18;
const _rankMoreColor    = _text2;
const double _rankMoreFontSize  = 12;  // "더보기" 글씨 크기
const _rankNameColor    = _text;
const double _rankNameFontSize  = 13;  // 이름 글씨 크기
const _rankAmtColor     = _teal;
const double _rankAmtFontSize   = 14;  // 금액 숫자 크기
const double _rankAmtUnitFontSize = 12;// " 원" 글씨 크기
const double _rankBadgeSize     = 24;  // 순위 뱃지 칸 크기
const double _rankBadgeFontSize = 12;  // 순위 숫자 크기(4·5등)
const double _rankMedalSize     = 26;  // 메달 아이콘 크기(1·2·3등)
const _rankGold   = Color.fromARGB(255, 241, 201, 97); // 1등 금
const _rankSilver = Color.fromARGB(255, 200, 207, 216); // 2등 은(밝게)
const _rankBronze = Color.fromARGB(255, 177, 118, 79); // 3등 동
const _rankEtc    = _text;            // 4등~ 숫자 색
const double _rankRowPadV       = 5;   // 행 위아래 여백
const _rankEmptyColor   = _text2;
const double _rankEmptyFontSize = 12;
// 랭킹 카드 테두리·아이콘·줄 간격
const _rankTitleIconColor    = _amber;   // 트로피 아이콘 색
const double _rankCardBorderWidth = 0.5;   // 카드 테두리 두께
const double _rankMoreIconSize    = 16;  // 더보기 화살표 크기
const _rankAmtUnitColor      = _text;    // " 원" 글씨 색
const double _rankGapIconTitle   = 8;    // 트로피 ↔ 제목 갭
const double _rankGapTitleToggle = 12;   // 제목줄 ↔ 토글 갭
const double _rankGapToggleList  = 10;   // 토글 ↔ 목록 갭
const double _rankGapBadgeName   = 12;   // 순위뱃지 ↔ 이름 갭

// ═══════════════════════════════════════════════════════════════════════
// 6. 하단 4버튼 카드
// ═══════════════════════════════════════════════════════════════════════
const _menuCardBg      = _surface;
const double _menuCardRadius   = 14;  // 카드 모서리
const _menuTitleColor  = _text;
// 하단 메뉴 카드 4칸 (경계선 구분)
const double _menuItemIconSize      = 24; // 칸 아이콘 크기
const double _menuItemLabelFontSize = 11; // 칸 글씨 크기
const double _menuCardPadL          = 0;  // 하단메뉴 카드 안쪽 여백 왼
const double _menuCardPadT          = 10; // 위
const double _menuCardPadR          = 0;  // 오른
const double _menuCardPadB          = 10; // 아래
const double _menuItemDividerH      = 36; // 세로 경계선 높이
const _menuDividerColor             = _elevated; // 경계선 색

// ═══════════════════════════════════════════════════════════════════════
// 7. 출금신청 버튼 + 페이지 (탭)
// ═══════════════════════════════════════════════════════════════════════
// ── 공통 허브 탭 (출금신청·라이더관리·공지사항 탭 공용) ──
const _tabTrackColor      = _surface;  // 탭 전체 배경(트랙)
const _tabIndicatorColor  = _surface; // 선택된 탭 배경(=chip)
const _tabSelColor        = _teal;   // 선택 탭 글씨(민트)
const _tabUnselColor      = _text2;    // 미선택 탭 글씨
const double _tabFontSize        = 14; // 탭 글씨 크기
const double _tabTrackRadius     = 10; // 트랙 모서리
const double _tabIndicatorRadius = 7;  // 선택탭 모서리
const double _tabTrackPad        = 3;  // 트랙 안쪽 여백
// ── [7-2] 출금내역 (조회·합계·토글) ──
const _whSubColor       = _text2;  // 소계 행 라벨/값 색
const double _whSubFontSize = 11;  // 소계 행 글씨 크기
const _whTogLabelColor  = _text;  // 토글 라벨 색
const double _whTogFontSize = 12;  // 토글 글씨 크기
const _whTogIconColor   = _text2;  // 토글 펼침 아이콘 색
const double _whTogIconSize = 14;  // 토글 아이콘 크기
const _whSubBoxBg       = _surface;  // 펼침 박스 배경
const double _whSubBoxRadius = 8;  // 펼침 박스 모서리
const _whSubBoxBorder   = _elevated; // 펼침 박스 테두리
const double _whBtnHeight = 30;    // 조회/초기화 버튼 높이
const double _whBtnPadH   = 6;    // 버튼 좌우 여백
const double _whBtnRadius = 7;     // 버튼 모서리
const _whBtnFilledBg    = _teal; // 채운 버튼(조회) 배경
const _whBtnFilledText  = _panel;  // 채운 버튼 글씨
const _whBtnLineBorder  = _elevated; // 외곽선 버튼(초기화) 테두리
const _whBtnLineText    = _teal; // 외곽선 버튼 글씨
const double _whBtnFontSize = 12;  // 버튼 글씨 크기
// 출금내역 외곽 카드 + 배달수수료 행
const _whCardBg     = _surface;    // 카드 배경
const _whCardBorder = _elevated;   // 카드 테두리 색
const double _whCardBorderWidth = 1; // 카드 테두리 두께
const _whGrossColor = _text;       // "배달수수료(세전)" 색
const double _whGrossFontSize = 12;// "배달수수료(세전)" 크기
const double _whGapDateToBtn = 8;  // 마지막일 ↔ 조회 버튼 갭
const double _whGapBtnToBtn  = 6;  // 조회 ↔ 초기화 버튼 갭
const double _whTabToCardGap = 2; // 출금내역 탭 ↔ 카드 갭

// ═══════════════════════════════════════════════════════════════════════
// 8. 라이더관리 버튼 + 페이지 (탭)
// ═══════════════════════════════════════════════════════════════════════


// ═══════════════════════════════════════════════════════════════════════
// 9. 공제설정 버튼 + 페이지
// ═══════════════════════════════════════════════════════════════════════
// ── [9-1] 리포트 업로드 카드 ──
const double _stPadL = 15;  // 카드 바깥 여백 왼
const double _stPadT = 12;  // 위
const double _stPadR = 15;  // 오른
const double _stPadB = 15;  // 아래
const double _stCardPadL = 16; // 카드 안쪽 여백 왼
const double _stCardPadT = 14; // 위
const double _stCardPadR = 16; // 오른
const double _stCardPadB = 16; // 아래
const _stCardBg     = _surface;  // 카드 배경
const _stCardBorder = _elevated;   // 카드 테두리
const double _stCardBorderWidth = 1; // 카드 테두리 두께
const double _stCardRadius = 16; // 카드 모서리
const _stWarnColor       = _teal; // 안내문구(설정 가능 상태) 색
const _stWarnLockedColor = _pink;       // 안내문구(잠금 상태) 색
const double _stWarnFontSize = 12;     // 안내문구 글씨 크기
const _stEditColor     = _teal; // 수정 버튼 글씨/테두리 색
const _stEditActiveBg  = _teal; // 저장(편집중) 버튼 배경
const _stEditActiveText = _surface;    // 저장(편집중) 버튼 글씨 색
const double _stEditFontSize = 12;   // 수정/저장 글씨 크기
const _stRowDivider     = _elevated; // 항목 구분선 색
const _stLabelColor = _text2; // 항목 라벨 색
const _stValueColor = _text;  // 항목 값 색
const _stUnitColor  = _text2; // 단위(% / 원 / 건) 색
const double _stLabelFontSize = 12; // 라벨 글씨 크기
const double _stValueFontSize = 12; // 값 글씨 크기
const double _stUnitFontSize  = 11; // 단위 글씨 크기
const _stPromoActionColor = _teal;     // +추가/-제거 색
const double _stPromoActionFontSize = 11;// +추가/-제거 글씨 크기
const double _stUploadW = 200;     // 업로드 버튼 너비
const double _stUploadH = 46;      // 업로드 버튼 높이
const double _stUploadRadius = 22; // 업로드 버튼 모서리
const double _stUploadFontSize = 13; // 업로드 버튼 글씨 크기

// ═══════════════════════════════════════════════════════════════════════
// 10. 공지사항 버튼 + 페이지 (탭)
// ═══════════════════════════════════════════════════════════════════════
// ── [10-1] 공지사항 — 통계 카드 + 공지 박스 + 가입신청 ──
const _ntStatCardBg     = _surface; // 통계 카드 배경
const _ntStatCardBorder = _elevated;  // 통계 카드 테두리
const double _ntStatCardBorderWidth = 1; // 통계 카드 테두리 두께
const double _ntBoxBorderWidth = 1;      // 공지 박스 테두리 두께
const double _ntJoinCardBorderWidth = 1; // 가입신청 카드 테두리 두께
const double _ntStatCardRadius = 16;// 통계 카드 모서리
const _ntStatDivider = _elevated;  // 통계 항목 구분선
const _ntStatLabelColor = _text;   // 통계 라벨 색
const double _ntStatLabelFontSize = 10; // 통계 라벨 크기
const _ntStatValueColor = _teal;  // 통계 숫자 색
const double _ntStatValueFontSize = 16; // 통계 숫자 크기
const _ntBoxBg     = _surface; // 공지 박스 배경
const _ntBoxBorder = _elevated;  // 공지 박스 테두리
const double _ntBoxRadius = 16;// 공지 박스 모서리
const _ntTitleIconColor = _teal; // 공지 헤더 아이콘 색
const _ntTitleColor = _text;      // "공지사항" 글씨 색
const double _ntTitleFontSize = 13;// "공지사항" 글씨 크기
const _ntEditColor      = _teal; // 수정 버튼 글씨/테두리
const _ntEditActiveText = _surface;  // 저장(편집중) 글씨
const double _ntEditFontSize = 12; // 수정/저장 글씨 크기
const _ntDivider = _elevated;     // 공지 박스 구분선
const _ntFieldBg     = _surface;     // 공지 입력/표시 박스 배경
const _ntTextColor = _text2;       // 공지 본문 글씨 색
const _ntHintColor = _text2;       // 공지 힌트/빈내용 색
const double _ntFontSize = 13;     // 공지 본문 글씨 크기
const _ntStampColor = _text2;      // 마지막 수정 시각 색
const double _ntStampFontSize = 10;// 마지막 수정 시각 크기
const _ntJoinCardBg     = _surface; // 가입신청 카드 배경
const _ntJoinCardBorder = _elevated;  // 가입신청 카드 테두리
const double _ntJoinCardRadius = 12;// 가입신청 카드 모서리
const _ntJoinIconColor  = _teal;  // 가입신청 아이콘 색
const _ntJoinLabelColor = _text2;   // "가입신청"/"님" 글씨 색
const _ntJoinNameColor  = _teal;  // 신청자 이름 색
const double _ntJoinLabelFontSize  = 12; // "가입신청" 글씨 크기
const double _ntJoinNameFontSize   = 18; // 신청자 이름 크기
const double _ntJoinSuffixFontSize = 16; // " 님" 크기
const double _ntJoinBtnFontSize    = 11; // 승인/거절 버튼 글씨 크기
const _ntApproveBg   = _teal; // 승인 버튼 배경
const _ntApproveText = _text;   // 승인 버튼 글씨
// 1:1 상담 카드 상수(_cs*)는 admin_chat_page.dart 로 이동

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  String? _homeView; // null=대시보드, 'notice' | 'settings' | 'withdrawal'

  // 차트(누적 지급액) 상태
  int _chartPeriod = 0; // 0=일간 1=주간 2=월간
  bool _chLoaded = false;
  List<List<double>> _chSeries = [[], [], []];
  List<List<String>> _chLabels = [[], [], []];
  final List<int> _ringTargets = [200000, 1000000, 4000000]; // 일/주/월 목표

  // 출금 랭킹 상태
  int _rankPeriod = 0; // 0=일간 1=주간 2=월간
  List<MapEntry<String, double>> _rankDay = [];
  List<MapEntry<String, double>> _rankWeek = [];
  List<MapEntry<String, double>> _rankMonth = [];

  bool isEditingRates  = false;
  bool _settingsLocked = false;

  final _employmentCtrl = TextEditingController(text: "0.8");
  final _accidentCtrl   = TextEditingController(text: "0.8");
  final _taxCtrl        = TextEditingController(text: "3.3");
  final _feeCtrl        = TextEditingController(text: "0");
  final _commissionCtrl = TextEditingController(text: "0");

  List<Map<String, TextEditingController>> perOrderList  = [];
  List<Map<String, TextEditingController>> incentiveList = [];

  int _visitTotal = 0, _visitToday = 0, _pushCount = 0;

  bool _isEditingNotice = false;
  final TextEditingController _noticeCtrl = TextEditingController();
  bool _noticeLoaded = false;

  // 출금내역 탭 상태
  DateTime? lStart, lEnd;
  double lGross = 0, lEmp = 0, lAcc = 0, lTax = 0;
  double lMission = 0, lPerOrder = 0, lRange = 0;
  double lIns = 0, lWd = 0, lComm = 0, lLease = 0, lTotal = 0;
  bool lLoaded = false, lLoading = false;
  bool lPromo = false, lTaxExp = false, lDedu = false, lCommExp = false;

  @override
  void initState() {
    super.initState();
    _addRow(true); _addRow(false);
    _loadRates();
    _loadLastUploadTime();
    _loadVisitStats();
    _loadNotice();
    _loadAdminChart();
    _loadTargets();
  }

  // 목표 금액(일/주/월) Firestore에서 로드 — 재로그인해도 유지
  Future<void> _loadTargets() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin_settings').doc('chart_targets').get();
      final d = doc.data();
      if (d == null || !mounted) return;
      setState(() {
        _ringTargets[0] = (d['daily']   as num?)?.toInt() ?? _ringTargets[0];
        _ringTargets[1] = (d['weekly']  as num?)?.toInt() ?? _ringTargets[1];
        _ringTargets[2] = (d['monthly'] as num?)?.toInt() ?? _ringTargets[2];
      });
    } catch (_) {}
  }

  // 지급완료 누적 지급액 차트 데이터 로드
  Future<void> _loadAdminChart() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('admin_settlement_logs')
          .where('status', isEqualTo: '지급완료')
          .get();

      String dk(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
      DateTime weekStart(DateTime d) {
        final b = DateTime(d.year, d.month, d.day);
        return b.subtract(Duration(days: (b.weekday - DateTime.wednesday + 7) % 7));
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final curWeekStart = weekStart(today);
      final curMonthStr = DateFormat('yyyy-MM').format(today);
      // 랭킹 주간: 수요일 시작(수~화). 가장 최근 수요일부터
      final rankWeekStart = today
          .subtract(Duration(days: (today.weekday - DateTime.wednesday + 7) % 7));

      final Map<String, double> byDay = {};
      final Map<String, double> riderDay = {};
      final Map<String, double> riderWeek = {};
      final Map<String, double> riderMonth = {};
      for (final d in snap.docs) {
        final data = d.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;

        // ── 차트: 배달 날짜별 정산액 (누적정산과 동일하게 항목별 net 합산) ──
        final items = (data['items'] as List<dynamic>?) ?? [];
        final lease = (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
        final perDayLease = items.isNotEmpty ? lease / items.length : 0.0;
        for (final raw in items) {
          final it = Map<String, dynamic>.from(raw as Map);
          final idate = it['date'] as String? ?? '';
          if (idate.length < 10) continue;
          double n(String k) => (it[k] as num?)?.toDouble() ?? 0;
          final net = n('deliveryFee') + n('promoTotal') - n('tax') -
              (n('withdrawalFee') + n('commissionAmt')) - n('insuranceFee') - perDayLease;
          byDay[idate] = (byDay[idate] ?? 0) + net;
        }

        // ── 랭킹: 기사별 지급 합계 (입금완료 처리일 기준, 출금 총액) ──
        String? key;
        final ts = data['approvedAt'] as Timestamp?;
        if (ts != null) {
          key = dk(ts.toDate());
        } else if ((data['date'] as String?)?.isNotEmpty == true) {
          key = data['date'] as String;
        }
        if (key == null) continue;
        final rnRaw = (data['riderName'] as String?)?.trim();
        final rn = (rnRaw == null || rnRaw.isEmpty) ? '이름없음' : rnRaw;
        final dt = DateTime.tryParse(key);
        if (dt != null) {
          final dOnly = DateTime(dt.year, dt.month, dt.day);
          if (dOnly == today) {
            riderDay[rn] = (riderDay[rn] ?? 0) + amount; // 일간(오늘)
          }
          if (!dOnly.isBefore(rankWeekStart)) {
            riderWeek[rn] = (riderWeek[rn] ?? 0) + amount; // 주간(수~화)
          }
          if (key.length >= 7 && key.substring(0, 7) == curMonthStr) {
            riderMonth[rn] = (riderMonth[rn] ?? 0) + amount; // 월간(당월)
          }
        }
      }

      // 일간: 최근 7일
      final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
      final seriesD = days.map((d) => byDay[dk(d)] ?? 0).toList();
      final labelsD = days.map((d) {
        const wd = ['월', '화', '수', '목', '금', '토', '일'];
        return wd[d.weekday - 1];
      }).toList();

      // 주간: 최근 7주(수요일 시작, 수~화)
      final Map<String, double> byWeek = {};
      byDay.forEach((k, v) {
        final dt = DateTime.tryParse(k);
        if (dt != null) {
          final ws = dk(weekStart(dt));
          byWeek[ws] = (byWeek[ws] ?? 0) + v;
        }
      });
      final weeks =
          List.generate(7, (i) => curWeekStart.subtract(Duration(days: (6 - i) * 7)));
      final seriesW = weeks.map((w) => byWeek[dk(w)] ?? 0).toList();
      final labelsW = weeks.map((w) => '${w.month}/${w.day}').toList();

      // 월간: 최근 7개월
      final Map<String, double> byMonth = {};
      byDay.forEach((k, v) {
        if (k.length >= 7) byMonth[k.substring(0, 7)] = (byMonth[k.substring(0, 7)] ?? 0) + v;
      });
      final months = List.generate(7, (i) => DateTime(today.year, today.month - (6 - i), 1));
      final seriesM = months.map((m) => byMonth[DateFormat('yyyy-MM').format(m)] ?? 0).toList();
      final labelsM = months.map((m) => '${m.month}월').toList();

      // 랭킹 정렬(내림차순)
      final rd = riderDay.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final rw = riderWeek.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final rm = riderMonth.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (mounted) {
        setState(() {
          _chSeries = [seriesD, seriesW, seriesM];
          _chLabels = [labelsD, labelsW, labelsM];
          _rankDay = rd;
          _rankWeek = rw;
          _rankMonth = rm;
          _chLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('차트 로드 실패: $e');
      if (mounted) setState(() => _chLoaded = true);
    }
  }

  Future<void> _loadWithdrawalData() async {
    if (lLoading) return;
    setState(() { lLoading = true; lLoaded = false; });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('admin_settlement_logs').where('status', isEqualTo: '지급완료').get();
      double gross = 0, emp = 0, acc = 0, tax = 0;
      double mission = 0, perOrder = 0, range = 0, ins = 0, wd = 0, comm = 0, lease = 0, total = 0;

      final hasFilter = lStart != null || lEnd != null;
      final endDay = lEnd != null
          ? DateTime(lEnd!.year, lEnd!.month, lEnd!.day, 23, 59, 59)
          : null;

      for (final d in snap.docs) {
        final data = d.data();
        final items = (data['items'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];

        if (!hasFilter) {
          total += (data['amount'] as num?)?.toDouble() ?? 0;
          if (items.isNotEmpty) {
            lease += (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
            for (final item in items) {
              gross    += (item['deliveryFee']    as num?)?.toDouble() ?? 0;
              emp      += (item['employmentTax']  as num?)?.toDouble() ?? 0;
              acc      += (item['accidentTax']    as num?)?.toDouble() ?? 0;
              tax      += (item['incomeTax']      as num?)?.toDouble() ?? 0;
              mission  += (item['missionFee']     as num?)?.toDouble() ?? 0;
              perOrder += (item['perOrderAmount'] as num?)?.toDouble() ?? 0;
              range    += (item['rangeAmount']    as num?)?.toDouble() ?? 0;
              ins      += (item['insuranceFee']   as num?)?.toDouble() ?? 0;
              wd       += (item['withdrawalFee']  as num?)?.toDouble() ?? 0;
              comm     += (item['commissionAmt']  as num?)?.toDouble() ?? 0;
            }
          } else {
            final msg = data['message']?.toString() ?? '';
            gross    += _regexExtract(msg, '배달수수료\\(세전\\)').abs();
            emp      += _regexExtract(msg, '고용보험').abs();
            acc      += _regexExtract(msg, '산재보험').abs();
            tax      += _regexExtract(msg, '원천세').abs();
            mission  += _regexExtract(msg, '미션금액').abs();
            perOrder += _regexExtract(msg, '건당프로모션').abs();
            range    += _regexExtract(msg, '구간프로모션').abs();
            ins      += _regexExtract(msg, '시간제보험').abs();
            wd       += _regexExtract(msg, '출금수수료').abs();
            comm     += _extractCommission(msg);
            lease    += _regexExtract(msg, '리스비\\(일\\)').abs();
          }
        } else {
          int matchedCount = 0;
          for (final item in items) {
            final itemDate = DateTime.tryParse(item['date'] as String? ?? '');
            if (itemDate == null) continue;
            if (lStart != null && itemDate.isBefore(lStart!)) continue;
            if (endDay != null && itemDate.isAfter(endDay)) continue;
            matchedCount++;
            gross    += (item['deliveryFee']    as num?)?.toDouble() ?? 0;
            emp      += (item['employmentTax']  as num?)?.toDouble() ?? 0;
            acc      += (item['accidentTax']    as num?)?.toDouble() ?? 0;
            tax      += (item['incomeTax']      as num?)?.toDouble() ?? 0;
            mission  += (item['missionFee']     as num?)?.toDouble() ?? 0;
            perOrder += (item['perOrderAmount'] as num?)?.toDouble() ?? 0;
            range    += (item['rangeAmount']    as num?)?.toDouble() ?? 0;
            ins      += (item['insuranceFee']   as num?)?.toDouble() ?? 0;
            wd       += (item['withdrawalFee']  as num?)?.toDouble() ?? 0;
            comm     += (item['commissionAmt']  as num?)?.toDouble() ?? 0;
          }
          if (matchedCount > 0 && items.isNotEmpty) {
            final fullLease = (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
            lease += fullLease * matchedCount / items.length;
          }
        }
      }

      if (hasFilter) {
        total = gross + (mission + perOrder + range) - (emp + acc + tax) - (wd + comm) - ins - lease;
      }

      setState(() {
        lGross = gross; lEmp = emp; lAcc = acc; lTax = tax;
        lMission = mission; lPerOrder = perOrder; lRange = range;
        lIns = ins; lWd = wd; lComm = comm; lLease = lease; lTotal = total;
        lLoaded = true; lLoading = false;
      });
    } catch (e) { setState(() { lLoaded = true; lLoading = false; }); }
  }

  @override
  void dispose() {
    _employmentCtrl.dispose(); _accidentCtrl.dispose();
    _taxCtrl.dispose(); _feeCtrl.dispose(); _commissionCtrl.dispose();
    _noticeCtrl.dispose();
    super.dispose();
  }

  // === Data Loaders ======================================================================

  Future<void> _loadVisitStats() async {
    try {
      final today    = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayDoc = await FirebaseFirestore.instance.collection('visit_stats').doc(today).get();
      final totalDoc = await FirebaseFirestore.instance.collection('visit_stats').doc('total').get();
      final pushDoc  = await FirebaseFirestore.instance.collection('push_stats').doc('count').get();
      if (mounted) {
        setState(() {
          _visitToday = (todayDoc.data()?['count'] ?? 0) as int;
          _visitTotal = (totalDoc.data()?['count'] ?? 0) as int;
          _pushCount  = (pushDoc.data()?['count']  ?? 0) as int;
        });
      }
    } catch (e) { debugPrint('통계 로드 실패: $e'); }
  }

  Future<void> _loadNotice() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('system_settings').doc('notice').get();
      if (doc.exists) _noticeCtrl.text = doc.data()?['content'] as String? ?? '';
      if (mounted) setState(() => _noticeLoaded = true);
    } catch (e) { debugPrint('공지 로드 실패: $e'); }
  }

  Future<void> _saveNotice() async {
    final content = _noticeCtrl.text.trim();
    try {
      await FirebaseFirestore.instance.collection('system_settings').doc('notice').set({
        'content': content, 'updatedAt': FieldValue.serverTimestamp(), 'isVisible': content.isNotEmpty,
      });
      if (mounted) { setState(() => _isEditingNotice = false); _showDialog("공지사항이 저장되었습니다!"); }
    } catch (e) { _showDialog("저장 실패. 다시 시도해주세요."); }
  }

  Future<void> _loadLastUploadTime() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('admin_settings').doc('upload_lock').get();
      if (doc.exists && doc.data()?['lastUploadDate'] != null) {
        final dt = DateTime.tryParse(doc.data()!['lastUploadDate'] as String);
        if (dt != null && mounted) {
          final now = DateTime.now();
          final isToday = now.day == dt.day && now.month == dt.month && now.year == dt.year;
          setState(() => _settingsLocked = isToday);
        }
      }
    } catch (e) { debugPrint('업로드 시간 로드 실패: $e'); }
  }

  Future<void> _saveLastUploadTime() async {
    final now = DateTime.now();
    await FirebaseFirestore.instance.collection('admin_settings').doc('upload_lock').set({
      'lastUploadDate': DateFormat('yyyy-MM-dd').format(now),
    });
    if (mounted) setState(() => _settingsLocked = true);
  }

  Future<void> _loadRates() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('admin_settings').doc('rates').get();
      if (!doc.exists) return;
      final d = doc.data()!;
      String fmtNum(double v) => v == v.truncateToDouble() ? NumberFormat('#,###').format(v.toInt()) : v.toString();
      setState(() {
        _employmentCtrl.text = fmtNum((d['employmentRate'] ?? 0.8).toDouble());
        _accidentCtrl.text   = fmtNum((d['accidentRate']   ?? 0.8).toDouble());
        _taxCtrl.text        = fmtNum((d['taxRate']        ?? 3.3).toDouble());
        _feeCtrl.text        = fmtNum((d['withdrawalFee']  ?? 0).toDouble());
        _commissionCtrl.text = fmtNum((d['commissionRate'] ?? 0).toDouble());
        _loadList(d['perOrderList'],  perOrderList);
        _loadList(d['incentiveList'], incentiveList);
      });
    } catch (e) { debugPrint('요율 로드 실패: $e'); }
  }

  void _loadList(dynamic src, List<Map<String, TextEditingController>> target) {
    final list = src as List<dynamic>? ?? [];
    if (list.isEmpty) return;
    target.clear();
    for (final item in list) {
      target.add({
        'min':    TextEditingController(text: item['min']?.toString()    ?? ''),
        'max':    TextEditingController(text: item['max']?.toString()    ?? ''),
        'amount': TextEditingController(text: item['amount']?.toString() ?? ''),
      });
    }
  }

  // === Actions ======================================================================

  Future<void> _saveRates() async {
    try {
      await FirebaseFirestore.instance.collection('admin_settings').doc('rates').set({
        'employmentRate': double.tryParse(_employmentCtrl.text.replaceAll(',', '')) ?? 0.8,
        'accidentRate':   double.tryParse(_accidentCtrl.text.replaceAll(',', ''))   ?? 0.8,
        'taxRate':        double.tryParse(_taxCtrl.text.replaceAll(',', ''))        ?? 3.3,
        'withdrawalFee':  double.tryParse(_feeCtrl.text.replaceAll(',', ''))        ?? 0,
        'commissionRate': double.tryParse(_commissionCtrl.text.replaceAll(',', '')) ?? 0,
        'perOrderList':  _serList(perOrderList),
        'incentiveList': _serList(incentiveList),
        'updatedAt':     FieldValue.serverTimestamp(),
      });
      if (mounted) { setState(() => isEditingRates = false); _showDialog("공제 설정 저장완료!!"); }
    } catch (_) { _showDialog("저장 실패. 다시 시도해주세요."); }
  }

  List<Map<String, String>> _serList(List<Map<String, TextEditingController>> src) =>
      src.map((r) => {
        'min':    r['min']!.text.trim().replaceAll(',', ''),
        'max':    r['max']!.text.trim().replaceAll(',', ''),
        'amount': r['amount']!.text.trim().replaceAll(',', ''),
      }).toList();

  void _addRow(bool isPerOrder) {
    setState(() {
      final row = {'min': TextEditingController(), 'max': TextEditingController(), 'amount': TextEditingController()};
      isPerOrder ? perOrderList.add(row) : incentiveList.add(row);
    });
  }

  void _removeRow(bool isPerOrder, int i) {
    setState(() {
      if (isPerOrder) { if (perOrderList.length  > 1) perOrderList.removeAt(i); }
      else            { if (incentiveList.length > 1) incentiveList.removeAt(i); }
    });
  }

  Future<void> _approveUser(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).update({'isApproved': true, 'role': 'driver'});

  Future<void> _rejectUser(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).delete();

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  Future<void> _uploadReport() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['xlsx', 'xls', 'ods'], withData: true);
    if (result == null || result.files.single.bytes == null) return;
    if (!mounted) return;

    showDialog(context: context, barrierDismissible: false, builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _elevated, width: 1)),
        child: const Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: _teal),
          SizedBox(height: 16),
          Text("파일 분석 중...", style: TextStyle(color: _text2, fontSize: 13)),
          SizedBox(height: 4),
          Text("잠시만 기다려 주세요", style: TextStyle(color: _text2, fontSize: 11)),
        ]),
      ),
    ));

    try {
      final riderMap = await compute(_parseExcelBytes, result.files.single.bytes!);
      if (riderMap.isEmpty) throw Exception("유효한 데이터가 없습니다.");

      final reportDate = riderMap.values.first['date'] as String?
          ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      // ── 기존: delivery_reports 저장 ──────────────────────
      final dateRef = FirebaseFirestore.instance
          .collection('delivery_reports').doc(reportDate);
      await dateRef.set({
        'date':       reportDate,
        'uploadedAt': FieldValue.serverTimestamp(),
        'riderCount': riderMap.length,
      });
      final riders = riderMap.values.toList();
      for (int i = 0; i < riders.length; i += 100) {
        final chunk = riders.sublist(i, (i + 100).clamp(0, riders.length));
        final batch = FirebaseFirestore.instance.batch();
        for (final r in chunk) {
          batch.set(dateRef.collection('riders').doc(r['reportId'] as String), {
            'reportId':      r['reportId'],
            'name':          r['name'],
            'deliveryFee':   r['deliveryFee'],
            'deliveryCount': r['deliveryCount'],
            'date':          reportDate,
            'uploadedAt':    FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }

      // ── 신규: unpaid_balance 자동 누적 ────────────────
      final matched = await _saveUnpaidBalances(riderMap, reportDate);

      if (!mounted) return;
      Navigator.pop(context);
      await _saveLastUploadTime();
      _showDialog(
          "업로드 완료!\n$reportDate 기준\n전체 ${riderMap.length}명 중 $matched명 매칭");
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showDialog("업로드 실패\n$e");
    }
  }

  // === Helpers ======================================================================

  double _regexExtract(String msg, String key) {
    final match = RegExp('$key[^:：]*[：:][\\s]*([-\\d,]+)').firstMatch(msg);
    if (match == null) return 0;
    return double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0;
  }

  double _extractCommission(String msg) {
    final match = RegExp(r'(?<![가-힣])협력사수수료\([^)]+\)\s*[：:]\s*([\d,]+)').firstMatch(msg);
    if (match == null) return 0;
    return double.tryParse(match.group(1)!.replaceAll(',', '')) ?? 0;
  }

  String _fmt(String val) {
    final n = double.tryParse(val.replaceAll(',', ''));
    if (n == null) return val;
    return n == n.truncateToDouble() ? NumberFormat('#,###').format(n.toInt()) : NumberFormat('#,###.##').format(n);
  }
  String _fmtC(double v) => NumberFormat('#,###').format(v);

  // 1단계: 기사별 수수료 계산 (업로드 시 자동 호출)
  Map<String, dynamic> _calcRiderPay({
    required double deliveryFee,
    required int    deliveryCount,
    required String date,
    required double empRate,
    required double accRate,
    required double taxRateVal,
    required double wdFeeAmt,
    required double commRate,
    required List<Map<String, dynamic>> perOrderRatesList,
    required List<Map<String, dynamic>> incentiveRatesList,
  }) {
    double perOrderAmount = 0;
    for (final rule in perOrderRatesList) {
      final min    = rule['min']    as int;
      final max    = rule['max']    as int;
      final amount = rule['amount'] as double;
      if (deliveryCount >= min && (max == 0 || deliveryCount <= max)) {
        perOrderAmount = deliveryCount * amount; break;
      }
    }
    double rangeAmount = 0;
    for (final rule in incentiveRatesList) {
      final min    = rule['min']    as int;
      final max    = rule['max']    as int;
      final amount = rule['amount'] as double;
      if (deliveryCount >= min && (max == 0 || deliveryCount <= max)) {
        rangeAmount = amount; break;
      }
    }
    const missionFee = 0.0;
    final promoTotal = missionFee + perOrderAmount + rangeAmount;
    final baseAmt    = deliveryFee + promoTotal;
    final eTax       = (baseAmt * empRate    / 100).floorToDouble();
    final aTax       = (baseAmt * accRate    / 100).floorToDouble();
    final iTax       = (baseAmt * taxRateVal / 100).floorToDouble();
    final tTax       = eTax + aTax + iTax;
    final afterTax   = baseAmt - tTax;
    final commAmt    = (afterTax * commRate  / 100).floorToDouble();
    final wdFee      = deliveryFee > 0 ? wdFeeAmt : 0.0;
    final deduction  = wdFee;
    final finalAmt   = afterTax - commAmt - deduction;

    String fc(double v) => NumberFormat('#,###').format(v);
    String fr(double r) => r == r.truncateToDouble() ? r.toInt().toString() : r.toString();

    final message =
        "배달수수료(세전): ${fc(deliveryFee)}원\n"
        "미션금액: ${fc(missionFee)}원\n"
        "건당프로모션: ${fc(perOrderAmount)}원\n"
        "구간프로모션: ${fc(rangeAmount)}원\n"
        "세금: ${fc(tTax)}원\n"
        "고용보험(${fr(empRate)}%): ${fc(eTax)}원\n"
        "산재보험(${fr(accRate)}%): ${fc(aTax)}원\n"
        "원천세(${fr(taxRateVal)}%): ${fc(iTax)}원\n"
        "협력사수수료(${fr(commRate)}%): ${fc(commAmt)}원\n"
        "시간제보험: 0원\n"
        "출금수수료: ${fc(wdFee)}원\n"
        "최종배달수수료: ${fc(finalAmt)}원\n"
        "최종출금금액: ${fc(finalAmt)}원";

    return {
      'date':           date,
      'deliveryFee':    deliveryFee,
      'deliveryCount':  deliveryCount,
      'missionFee':     missionFee,
      'perOrderAmount': perOrderAmount,
      'rangeAmount':    rangeAmount,
      'promoTotal':     promoTotal,
      'employmentTax':  eTax,
      'accidentTax':    aTax,
      'incomeTax':      iTax,
      'tax':            tTax,
      'commissionAmt':  commAmt,
      'insuranceFee':   0.0,
      'withdrawalFee':  wdFee,
      'finalAmount':    finalAmt,
      'message':        message,
    };
  }

  // 1단계: 업로드 후 기사별 unpaid_balance 자동 누적
  Future<int> _saveUnpaidBalances(
      Map<String, Map<String, dynamic>> riderMap, String reportDate) async {
    int matched = 0; // 등록 기사(reportId 일치)와 매칭된 인원 수
    try {
      // 최신 요율 Firestore에서 로드
      final ratesDoc = await FirebaseFirestore.instance
          .collection('admin_settings').doc('rates').get();
      final rd = ratesDoc.data() ?? {};

      final empRate    = (rd['employmentRate'] ?? 0.8).toDouble();
      final accRate    = (rd['accidentRate']   ?? 0.8).toDouble();
      final taxRateVal = (rd['taxRate']        ?? 3.3).toDouble();
      final wdFeeAmt   = (rd['withdrawalFee']  ?? 0).toDouble();
      final commRate   = (rd['commissionRate'] ?? 0).toDouble();

      final perOrderRatesList = List<Map<String, dynamic>>.from(
        (rd['perOrderList'] as List<dynamic>? ?? []).map((e) => {
          'min':    int.tryParse(e['min']?.toString()    ?? '0') ?? 0,
          'max':    int.tryParse(e['max']?.toString()    ?? '0') ?? 0,
          'amount': double.tryParse(e['amount']?.toString() ?? '0') ?? 0.0,
        }));
      final incentiveRatesList = List<Map<String, dynamic>>.from(
        (rd['incentiveList'] as List<dynamic>? ?? []).map((e) => {
          'min':    int.tryParse(e['min']?.toString()    ?? '0') ?? 0,
          'max':    int.tryParse(e['max']?.toString()    ?? '0') ?? 0,
          'amount': double.tryParse(e['amount']?.toString() ?? '0') ?? 0.0,
        }));

      // 승인된 기사 전체 조회 → reportId 기준 매핑
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('role',       isEqualTo: 'driver')
          .where('isApproved', isEqualTo: true)
          .get();

      final Map<String, Map<String, dynamic>> ridMap = {};
      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final rid  = data['reportId'] as String?;
        if (rid != null && rid.isNotEmpty) {
          ridMap[rid] = {'uid': doc.id, 'name': data['name'] ?? ''};
        }
      }

      // 기사별 수수료 계산 → unpaid_balance 저장
      for (final entry in riderMap.entries) {
        final reportId  = entry.key;
        final riderData = entry.value;
        final userInfo  = ridMap[reportId];
        if (userInfo == null) continue;
        matched++;

        final uid       = userInfo['uid']  as String;
        final riderName = userInfo['name'] as String;
        final dFee      = (riderData['deliveryFee']   as num?)?.toDouble() ?? 0;
        final dCount    = (riderData['deliveryCount'] as num?)?.toInt()    ?? 0;
        if (dFee <= 0) continue;

        final payData = _calcRiderPay(
          deliveryFee:        dFee,
          deliveryCount:      dCount,
          date:               reportDate,
          empRate:            empRate,
          accRate:            accRate,
          taxRateVal:         taxRateVal,
          wdFeeAmt:           wdFeeAmt,
          commRate:           commRate,
          perOrderRatesList:  perOrderRatesList,
          incentiveRatesList: incentiveRatesList,
        );

        // 기존 미출금 읽기
        final ref      = FirebaseFirestore.instance.collection('unpaid_balance').doc(uid);
        final existing = await ref.get();

        List<Map<String, dynamic>> items = [];
        if (existing.exists) {
          final raw = existing.data()?['items'] as List<dynamic>? ?? [];
          items = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          // 같은 날짜 중복 제거 (재업로드 대비)
          items.removeWhere((item) => item['date'] == reportDate);
        }

        items.add(payData);
        // 날짜 오름차순 정렬
        items.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

        final newTotal = items.fold<double>(
            0, (s, i) => s + ((i['finalAmount'] as num?)?.toDouble() ?? 0));

        await ref.set({
          'uid':         uid,
          'riderName':   riderName,
          'items':       items,
          'totalAmount': newTotal,
          'updatedAt':   FieldValue.serverTimestamp(),
        });
      }
      debugPrint('unpaid_balance 저장 완료: ${riderMap.length}명');
    } catch (e) {
      debugPrint('⚠️ unpaid_balance 저장 실패: $e');
    }
    return matched;
  }

  void _showDialog(String title) {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _elevated, width: 1)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: GlassShineButton(
            label: "확인",
            onPressed: () => Navigator.pop(ctx),
            accent: _teal,
            pill: true,
            height: 46,
            fontSize: 14,
          )),
        ]),
      ),
    ));
  }

  // === BUILD ================================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_panelOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(_panelRadius),
              border: Border.all(
                  color: _panelBorderColor.withValues(alpha: _panelBorderAlpha),
                  width: _panelBorderWidth),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_panelRadius),
              child: _homeView == null ? _dashboard() : _subView(_homeView!),
            ),
          ),
        ),
      ),
    );
  }

  // === 대시보드 홈 ===========================================================
  Widget _dashboard() => ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        children: [
          _greeting(),
          const SizedBox(height: _gapGreetChart),
          _adminChartCard(),
          const SizedBox(height: _gapChartRank),
          _rankingCard(),
          const SizedBox(height: _gapRankMenu),
          _bottomMenuCard(),
        ],
      );

  // === 허브 서브 화면 (메뉴 카드 → 탭 페이지) — 같은 State 안에서 전환 ========
  Widget _subView(String view) {
    final String title;
    final Widget body;
    final double gapHeaderDiv; // 헤더 ↔ 경계선 갭 (페이지별)
    final double gapDivCard;   // 경계선 ↔ 카드 갭 (페이지별)
    switch (view) {
      case 'withdraw':
        title = '출금';
        body = _hubTabs(const ['출금신청', '출금내역'],
            [const WithdrawalRequestPage(embedded: true), _withdrawalTab()]);
        gapHeaderDiv = _wrPageGapHeaderDiv; gapDivCard = _wrPageGapDivCard;
        break;
      case 'rider':
        title = '라이더 관리';
        body = _hubTabs(const ['라이더', '리스비'], const [
          const RiderManagePage(embedded: true),
          const LeaseAlertsPage(embedded: true),
        ]);
        gapHeaderDiv = _rmPageGapHeaderDiv; gapDivCard = _rmPageGapDivCard;
        break;
      case 'notice':
        title = '공지 / 상담';
        body = _hubTabs(const ['공지사항', '1:1상담'],
            [_noticeTab(), const ChatListPage(embedded: true)]);
        gapHeaderDiv = _ntPageGapHeaderDiv; gapDivCard = _ntPageGapDivCard;
        break;
      case 'settings':
      default:
        title = '공제설정';
        body = _settingsTab();
        gapHeaderDiv = _stPageGapHeaderDiv; gapDivCard = _stPageGapDivCard;
    }
    return Column(children: [
      _adminBackHeader(title),
      SizedBox(height: gapHeaderDiv),
      Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: _subDivMarginH),
          color: _subDivColor),
      SizedBox(height: gapDivCard),
      Expanded(child: body),
    ]);
  }

  Widget _adminBackHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 16, 0),
        child: Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _text, size: 18),
            onPressed: () {
              setState(() => _homeView = null);
              _loadAdminChart(); // 대시보드 복귀 시 차트·출금랭킹 최신화
            },
          ),
          Text(title,
              style: const TextStyle(
                  color: _text, fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
      );

  // === 차트 카드 (누적 지급액) ===============================================
  // ═══════════════ 4. 차트 (로직) ═══════════════
  Widget _adminChartCard() {
    final periodColor = [_teal, _pink, _purple][_chartPeriod];
    final series = _chLoaded && _chSeries[_chartPeriod].isNotEmpty
        ? _chSeries[_chartPeriod]
        : <double>[];
    final labels = _chLoaded ? _chLabels[_chartPeriod] : <String>[];
    final compare = ['전일 대비', '전주 대비', '전월 대비'][_chartPeriod];
    final nz = series.where((v) => v != 0).toList();
    final last = nz.isNotEmpty ? nz.last : 0.0;
    final prev = nz.length >= 2 ? nz[nz.length - 2] : 0.0;
    final delta = prev != 0 ? (last - prev) / prev * 100 : 0.0;
    final up = delta >= 0;
    final target = _ringTargets[_chartPeriod];
    final pct = target > 0 ? (last / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          _chartCardPadL, _chartCardPadT, _chartCardPadR, _chartCardPadB),
      decoration: BoxDecoration(
        color: _chartCardBg,
        borderRadius: BorderRadius.circular(_chartCardRadius),
        border: Border.all(color: _chartCardBorder.withValues(alpha: _chartCardBorderAlpha), width: _chartCardBorderWidth),
        boxShadow: _cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [_chartToggle(), const Spacer(), _targetButton()]),
        const SizedBox(height: _chGapToggleHead),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(left: _chLine1LeftPad),
                child: Text("총 지급액",
                    style: TextStyle(color: periodColor, fontSize: _chLabelFontSize)),
              ),
              const SizedBox(height: _chHeadGap1),
              Padding(
                padding: const EdgeInsets.only(left: _chLine2LeftPad),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: NumberFormat('#,###').format(last.round()),
                      style: const TextStyle(
                          color: _chAmtColor,
                          fontSize: _chAmtFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5)),
                  const TextSpan(
                      text: ' 원',
                      style: TextStyle(
                          color: _chUnitColor,
                          fontSize: _chUnitFontSize,
                          fontWeight: FontWeight.w400)),
                ])),
              ),
              const SizedBox(height: _chHeadGap2),
              Padding(
                padding: const EdgeInsets.only(left: _chLine3LeftPad),
                child: Row(children: [
                  Icon(up ? Icons.trending_up : Icons.trending_down,
                      size: _chTrendIconSize, color: periodColor),
                  const SizedBox(width: _chGapTrendPct),
                  Text('${up ? '+' : ''}${delta.toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: periodColor,
                          fontSize: _chDeltaFontSize,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: _chGapPctCompare),
                  Text(compare,
                      style: TextStyle(
                          color: periodColor, fontSize: _chCompareFontSize)),
                ]),
              ),
            ]),
          ),
          const SizedBox(width: _chGapTextRing),
          SizedBox(
              width: _ringBoxSize, height: _ringBoxSize, child: _ringGauge(pct)),
        ]),
        const SizedBox(height: _chGapHeadChart),
        if (!_chLoaded)
          const SizedBox(
              height: _chartHeight,
              child: Center(child: CircularProgressIndicator(color: _teal)))
        else ...[
          SizedBox(
            height: _chartHeight,
            width: double.infinity,
            child: CustomPaint(painter: _AdminAreaChartPainter(series)),
          ),
          const SizedBox(height: _chGapChartAxis),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map((l) => Text(l,
                    style: const TextStyle(
                        color: _chAxisLabelColor,
                        fontSize: _chAxisLabelFontSize)))
                .toList(),
          ),
        ],
      ]),
    );
  }

  // === 출금 랭킹 TOP5 ========================================================
  // ═══════════════ 5. 출금랭킹 (로직) ═══════════════
  Widget _rankingCard() {
    final list = [_rankDay, _rankWeek, _rankMonth][_rankPeriod];
    final top5 = list.take(5).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(
          _rankCardPadL, _rankCardPadT, _rankCardPadR, _rankCardPadB),
      decoration: BoxDecoration(
        color: _rankCardBg,
        borderRadius: BorderRadius.circular(_rankCardRadius),
        border: Border.all(color: _rankCardBorder, width: _rankCardBorderWidth),
        boxShadow: _cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.emoji_events_outlined,
              color: _rankTitleIconColor, size: _rankTitleIconSize),
          const SizedBox(width: _rankGapIconTitle),
          const Text("출금 랭킹 TOP5",
              style: TextStyle(
                  color: _rankTitleColor,
                  fontSize: _rankTitleFontSize,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: () => _openFullRanking(list),
            child: const Row(children: [
              Text("더보기",
                  style: TextStyle(color: _rankMoreColor, fontSize: _rankMoreFontSize)),
              Icon(Icons.chevron_right, color: _rankMoreColor, size: _rankMoreIconSize),
            ]),
          ),
        ]),
        const SizedBox(height: _rankGapTitleToggle),
        _rankToggle(),
        const SizedBox(height: _rankGapToggleList),
        if (top5.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("해당 기간 지급 내역이 없습니다.",
                style: TextStyle(
                    color: _rankEmptyColor, fontSize: _rankEmptyFontSize)),
          )
        else
          ...List.generate(top5.length,
              (i) => _rankRow(i + 1, top5[i].key, top5[i].value)),
      ]),
    );
  }

  Widget _rankToggle() => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final sel = _rankPeriod == i;
          final c = [_teal, _pink, _purple][i];
          const names = ['일간', '주간', '월간'];
          return GestureDetector(
            onTap: () => setState(() => _rankPeriod = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: _chTogGap),
              padding: const EdgeInsets.symmetric(
                  horizontal: _chTogPadH, vertical: _chTogPadV),
              decoration: BoxDecoration(
                color: sel ? c.withValues(alpha: 0.16) : Colors.transparent,
                borderRadius: BorderRadius.circular(_chTogRadius),
                border: Border.all(
                    color: sel
                        ? c.withValues(alpha: 0.6)
                        : _elevated.withValues(alpha: 0.45)),
              ),
              child: Text(names[i],
                  style: TextStyle(
                      color: sel ? c : _chTogUnselColor,
                      fontSize: _chTogFontSize,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ),
          );
        }),
      );

  Widget _rankRow(int rank, String name, double amount) {
    final badgeColor = rank == 1
        ? _rankGold
        : rank == 2
            ? _rankSilver
            : rank == 3
                ? _rankBronze
                : _rankEtc; // 4·5등은 옅게
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _rankRowPadV),
      child: Row(children: [
        // 1·2·3등 = 금·은·동 메달 아이콘 / 4·5등 = 숫자
        SizedBox(
          width: _rankBadgeSize,
          height: _rankBadgeSize,
          child: rank <= 3
              ? Icon(Icons.military_tech, color: badgeColor, size: _rankMedalSize)
              : Center(
                  child: Text("$rank",
                      style: TextStyle(
                          color: badgeColor,
                          fontSize: _rankBadgeFontSize,
                          fontWeight: FontWeight.w700)),
                ),
        ),
        const SizedBox(width: _rankGapBadgeName),
        Expanded(
          child: Text(name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: _rankNameColor,
                  fontSize: _rankNameFontSize,
                  fontWeight: FontWeight.w600)),
        ),
        Text.rich(TextSpan(children: [
          TextSpan(
              text: NumberFormat('#,###').format(amount),
              style: const TextStyle(
                  color: _rankAmtColor,
                  fontSize: _rankAmtFontSize,
                  fontWeight: FontWeight.w700)),
          const TextSpan(
              text: ' 원',
              style: TextStyle(color: _rankAmtUnitColor, fontSize: _rankAmtUnitFontSize)),
        ])),
      ]),
    );
  }

  void _openFullRanking(List<MapEntry<String, double>> list) {
    final title = ['일간 출금 랭킹', '주간 출금 랭킹', '월간 출금 랭킹'][_rankPeriod];
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => FullRankingPage(title: title, ranking: list)));
  }

  Widget _targetButton() {
    final c = [_teal, _pink, _purple][_chartPeriod];
    return GestureDetector(
      onTap: _editChartTarget,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: _targetPadH, vertical: _targetPadV),
        decoration: BoxDecoration(
          color: c.withValues(alpha: _targetBgAlpha),
          borderRadius: BorderRadius.circular(_targetRadius),
          border: Border.all(color: c.withValues(alpha: _targetBorderAlpha)),
        ),
        child: Text('목표 ${NumberFormat('#,###').format(_ringTargets[_chartPeriod])} 원',
            style: TextStyle(
                color: c, fontSize: _targetFontSize, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _ringGauge(double pct) {
    final tip = _ringColorFor(pct);
    return Stack(alignment: Alignment.center, children: [
      CustomPaint(
          size: const Size(_ringBoxSize, _ringBoxSize),
          painter: _RingGaugePainter(pct)),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text('${(pct * 100).round()}%',
            style: TextStyle(
                color: tip,
                fontSize: _ringPctFontSize,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 1),
        Text('달성', style: TextStyle(color: tip, fontSize: _ringLabelFontSize)),
      ]),
    ]);
  }

  Color _ringColorFor(double pct) {
    if (pct < 0.30) return _purple;
    if (pct < 0.32) return Color.lerp(_purple, _pink, (pct - 0.30) / 0.02)!;
    if (pct < 0.60) return _pink;
    if (pct < 0.62) return Color.lerp(_pink, _teal, (pct - 0.60) / 0.02)!;
    return _teal;
  }

  Future<void> _editChartTarget() async {
    const names = ['일간', '주간', '월간'];
    final ctrl =
        TextEditingController(text: _ringTargets[_chartPeriod].toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _tgtDlgBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_tgtDlgRadius),
            side: const BorderSide(
                color: _tgtDlgBorderColor, width: _tgtDlgBorderWidth)),
        title: Text('${names[_chartPeriod]} 목표 금액',
            style: const TextStyle(
                color: _text, fontSize: 15, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.right,
          style: const TextStyle(color: _text, fontSize: 15),
          cursorColor: _teal,
          decoration: const InputDecoration(
            suffixText: ' 원',
            suffixStyle: TextStyle(color: _text, fontSize: 15),
            hintText: '목표 금액 입력',
            hintStyle: TextStyle(color: _text2),
            enabledBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: _elevated)),
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: _elevated)),
          ),
        ),
        actions: [
          GlassShineButton(
            label: '취소',
            onPressed: () => Navigator.pop(ctx),
            accent: _text2,
            textColor: _text2,
            width: 84,
            height: 40,
            fontSize: 13,
          ),
          GlassShineButton(
            label: '저장',
            onPressed: () {
              final v =
                  int.tryParse(ctrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
              Navigator.pop(ctx, v);
            },
            accent: _teal,
            width: 84,
            height: 40,
            fontSize: 13,
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      setState(() => _ringTargets[_chartPeriod] = result);
      // 재로그인해도 유지되도록 Firestore 저장
      const keys = ['daily', 'weekly', 'monthly'];
      FirebaseFirestore.instance
          .collection('admin_settings')
          .doc('chart_targets')
          .set({keys[_chartPeriod]: result}, SetOptions(merge: true));
    }
  }

  Widget _chartToggle() => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final sel = _chartPeriod == i;
          final c = [_teal, _pink, _purple][i];
          const names = ['일간', '주간', '월간'];
          return GestureDetector(
            onTap: () => setState(() => _chartPeriod = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: _chTogGap),
              padding: const EdgeInsets.symmetric(
                  horizontal: _chTogPadH, vertical: _chTogPadV),
              decoration: BoxDecoration(
                color: sel ? c.withValues(alpha: 0.16) : Colors.transparent,
                borderRadius: BorderRadius.circular(_chTogRadius),
                border: Border.all(
                    color: sel
                        ? c.withValues(alpha: 0.6)
                        : _elevated.withValues(alpha: 0.45)),
              ),
              child: Text(names[i],
                  style: TextStyle(
                      color: sel ? c : _chTogUnselColor,
                      fontSize: _chTogFontSize,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ),
          );
        }),
      );

  // === 인사 ==================================================================
  // ═══════════════ 3. 안녕하세요 (로직) ═══════════════
  Widget _greeting() => Row(children: [
        Container(
          width: _greetIconOuterSize,
          height: _greetIconOuterSize,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: _greetIconOuterColor),
          child: Center(
            child: Container(
              width: _greetIconInnerSize,
              height: _greetIconInnerSize,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: _greetIconInnerColor),
            ),
          ),
        ),
        const SizedBox(width: _greetIconGap),
        Expanded(
          child: Text.rich(TextSpan(children: [
            const TextSpan(
                text: _greetHelloText,
                style: TextStyle(
                    color: _greetHelloColor,
                    fontSize: _greetHelloFontSize,
                    fontWeight: FontWeight.w700)),
            TextSpan(
                text: FirebaseAuth.instance.currentUser?.displayName ?? _greetNameFallback,
                style: const TextStyle(
                    color: _greetNameColor,
                    fontSize: _greetNameFontSize,
                    fontWeight: FontWeight.w700)),
            const TextSpan(
                text: _greetSuffixText,
                style: TextStyle(
                    color: _greetSuffixColor,
                    fontSize: _greetSuffixFontSize,
                    fontWeight: FontWeight.w700)),
          ])),
        ),
        GlassShineButton(
          onPressed: _logout,
          icon: Icons.logout_rounded,
          accent: _greetLogoutIconColor,
          textColor: _greetLogoutIconColor,
          width: _greetLogoutBoxSize,
          height: _greetLogoutBoxSize,
          radius: _greetLogoutRadius,
          fontSize: _greetLogoutIconSize - 3,
        ),
      ]);

  // === 하단 메뉴 카드 (한 카드 안 4칸, 세로 경계선으로 구분) ==================
  // ═══════════════ 6. 하단 4버튼 카드 (로직) ═══════════════
  Widget _bottomMenuCard() {
    Widget divider() => Container(width: 1, height: _menuItemDividerH, color: _menuDividerColor);
    return Container(
      padding: const EdgeInsets.fromLTRB(
          _menuCardPadL, _menuCardPadT, _menuCardPadR, _menuCardPadB),
      decoration: BoxDecoration(
        color: _menuCardBg,
        borderRadius: BorderRadius.circular(_menuCardRadius),
        border: Border.all(color: _elevated.withValues(alpha: _panelBorderAlpha), width: 1),
        boxShadow: _cardShadow,
      ),
      child: Row(children: [
        Expanded(
            child: _bottomMenuItem(Icons.campaign_outlined, _pink, "공지사항",
                () => setState(() => _homeView = 'notice'),
                badgeStream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('unreadByAdmin', isEqualTo: true)
                    .snapshots(),
                counter: (docs) => docs.length,
                badgeColor: _pink)),
        divider(),
        Expanded(
            child: _bottomMenuItem(Icons.tune_rounded, _amber, "공제설정",
                () => setState(() => _homeView = 'settings'))),
        divider(),
        Expanded(
            child: _bottomMenuItem(Icons.manage_accounts_rounded, _purple, "라이더관리",
                () => setState(() => _homeView = 'rider'),
                badgeStream: FirebaseFirestore.instance
                    .collection('lease_payments')
                    .where('isPaid', isEqualTo: false)
                    .snapshots(),
                counter: (docs) {
                  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  return docs
                      .where((d) {
                        final dd = (d.data() as Map)['dueDate'] as String? ?? '';
                        return dd.isNotEmpty && dd.compareTo(today) <= 0;
                      })
                      .map((d) => (d.data() as Map)['uid'])
                      .toSet()
                      .length;
                },
                badgeColor: _pink)),
        divider(),
        Expanded(
            child: _bottomMenuItem(Icons.payment_rounded, _teal, "출금신청", () {
          setState(() => _homeView = 'withdraw');
          if (!lLoading) _loadWithdrawalData(); // 진입할 때마다 최신으로 다시 로드
        },
                badgeStream: FirebaseFirestore.instance
                    .collection('withdrawal_requests')
                    .where('status', isEqualTo: '요청대기')
                    .snapshots(),
                counter: (docs) => docs.length,
                badgeColor: _pink)),
      ]),
    );
  }

  Widget _bottomMenuItem(IconData icon, Color color, String label, VoidCallback onTap,
      {Stream<QuerySnapshot>? badgeStream,
      int Function(List<QueryDocumentSnapshot>)? counter,
      Color badgeColor = _pink}) {
    Widget iconW = Icon(icon, color: color, size: _menuItemIconSize);
    if (badgeStream != null) {
      iconW = StreamBuilder<QuerySnapshot>(
        stream: badgeStream,
        builder: (_, snap) {
          final c = snap.hasData ? counter!(snap.data!.docs) : 0;
          return Stack(clipBehavior: Clip.none, children: [
            Icon(icon, color: color, size: _menuItemIconSize),
            if (c > 0)
              Positioned(
                top: -5,
                right: -6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration:
                      BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                  child: Center(
                      child: Text(c > 9 ? "9+" : "$c",
                          style: const TextStyle(
                              color: _text, fontSize: 8, fontWeight: FontWeight.w700))),
                ),
              ),
          ]);
        },
      );
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        iconW,
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                color: _menuTitleColor,
                fontSize: _menuItemLabelFontSize,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // 허브 페이지의 탭 레이아웃 (DefaultTabController로 컨트롤러 생략)
  Widget _hubTabs(List<String> tabs, List<Widget> views) => DefaultTabController(
        length: tabs.length,
        child: Column(children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 4, 15, 8),
            padding: const EdgeInsets.all(_tabTrackPad),
            decoration: BoxDecoration(
                color: _tabTrackColor,
                borderRadius: BorderRadius.circular(_tabTrackRadius)),
            child: TabBar(
              indicator: BoxDecoration(
                  color: _tabIndicatorColor,
                  borderRadius: BorderRadius.circular(_tabIndicatorRadius),
                  border: Border.all(color: _elevated, width: 1)),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: _tabSelColor,
              unselectedLabelColor: _tabUnselColor,
              dividerColor: Colors.transparent,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: _tabFontSize),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w400, fontSize: _tabFontSize),
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          Expanded(child: TabBarView(children: views)),
        ]),
      );

  Widget _sheetDateBtn(BuildContext ctx, DateTime? date, String hint, Function(DateTime) onPick) =>
      GestureDetector(
        onTap: () async {
          final p = await showDatePicker(context: ctx, initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2026), lastDate: DateTime(2030),
              builder: (c, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _teal)), child: child!));
          if (p != null) onPick(p);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(border: Border.all(color: _elevated), borderRadius: BorderRadius.circular(7)),
          child: Text(date != null ? DateFormat('MM-dd').format(date) : hint,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: date != null ? _teal : _text, fontSize: 12)),
        ),
      );

  // === 탭 1: 공지사항 =================================================================================

  // ═══════════════ 10-1. 공지사항 (로직) ═══════════════
  Widget _noticeTab() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(children: [
      // 누적방문 카드 (공지사항 위)
      Container(
        margin: const EdgeInsets.fromLTRB(15, _ntTabToStatGap, 15, 0),
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        decoration: BoxDecoration(color: _ntStatCardBg, borderRadius: BorderRadius.circular(_ntStatCardRadius), border: Border.all(color: _ntStatCardBorder, width: _ntStatCardBorderWidth), boxShadow: _cardShadow),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _statItem("누적 방문", _visitTotal),
            Container(width: 1, height: 24, color: _ntStatDivider),
            _statItem("오늘 방문", _visitToday),
            Container(width: 1, height: 24, color: _ntStatDivider),
            _statItem("푸시 발송", _pushCount),
          ]),
          Container(height: 1, color: _ntStatDivider, margin: const EdgeInsets.symmetric(vertical: 6)),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users')
                .where('role', isEqualTo: 'driver').where('isApproved', isEqualTo: true).snapshots(),
            builder: (_, snap) {
              final riderCount = snap.data?.docs.length ?? 0;
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('admin_settlement_logs')
                    .where('status', isEqualTo: '지급완료').snapshots(),
                builder: (_, snap2) {
                  int deliveryCount = 0;
                  for (final doc in snap2.data?.docs ?? []) {
                    final data  = doc.data() as Map<String, dynamic>;
                    final items = (data['items'] as List<dynamic>?) ?? [];
                    for (final item in items) {
                      deliveryCount += (item['deliveryCount'] as num?)?.toInt() ?? 0;
                    }
                  }
                  return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _statItem("총 라이더",   riderCount),
                    Container(width: 1, height: 24, color: _ntStatDivider),
                    _statItem("총 배달건수", deliveryCount),
                  ]);
                },
              );
            },
          ),
        ]),
      ),
      _noticeBox(),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('isApproved', isEqualTo: false).snapshots(),
        builder: (_, snap) {
          if (!snap.hasData || snap.data!.docs.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.fromLTRB(15, 12, 15, 0),
            padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
            decoration: BoxDecoration(color: _ntJoinCardBg, border: Border.all(color: _ntJoinCardBorder, width: _ntJoinCardBorderWidth), borderRadius: BorderRadius.circular(_ntJoinCardRadius), boxShadow: _cardShadow),
            child: Column(children: snap.data!.docs.map((doc) {
              final u = doc.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  const Icon(Icons.person_add, color: _ntJoinIconColor, size: 20),
                  const SizedBox(width: 6),
                  const Text("가입신청  ", style: TextStyle(color: _ntJoinLabelColor, fontSize: _ntJoinLabelFontSize, fontWeight: FontWeight.w600)),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: _ntJoinNameFontSize, fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(text: "${u['name']}", style: const TextStyle(color: _ntJoinNameColor)),
                        const TextSpan(text: " 님", style: TextStyle(color: _ntJoinLabelColor, fontSize: _ntJoinSuffixFontSize)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _approveUser(doc.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: _ntApproveBg, borderRadius: BorderRadius.circular(7)),
                      child: const Text("승인", style: TextStyle(color: _ntApproveText, fontSize: _ntJoinBtnFontSize, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _rejectUser(doc.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(border: Border.all(color: _pink.withAlpha(80)), borderRadius: BorderRadius.circular(7)),
                      child: const Text("거절", style: TextStyle(color: _pink, fontSize: _ntJoinBtnFontSize)),
                    ),
                  ),
                ]),
              );
            }).toList()),
          );
        },
      ),
      const SizedBox(height: 12),
    ]));
  }

  Widget _statItem(String label, int value) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(label, style: const TextStyle(color: _ntStatLabelColor, fontSize: _ntStatLabelFontSize)),
    const SizedBox(height: 2),
    Text(NumberFormat('#,###').format(value),
        style: const TextStyle(color: _ntStatValueColor, fontSize: _ntStatValueFontSize, fontWeight: FontWeight.w700)),
  ]);

  // === 공지사항 박스 =================================================================================

  Widget _noticeBox() {
    if (!_noticeLoaded) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(15, _ntStatToNoticeGap, 15, 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(color: _ntBoxBg, border: Border.all(color: _ntBoxBorder, width: _ntBoxBorderWidth), borderRadius: BorderRadius.circular(_ntBoxRadius), boxShadow: _cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.campaign_outlined, color: _ntTitleIconColor, size: 24),
          const SizedBox(width: 8),
          const Text("공지사항", style: TextStyle(color: _ntTitleColor, fontSize: _ntTitleFontSize, fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: () { if (_isEditingNotice) { _saveNotice(); } else { setState(() => _isEditingNotice = true); } },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _isEditingNotice ? _teal : Colors.transparent,
                border: Border.all(color: _isEditingNotice ? _elevated : _elevated, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_isEditingNotice ? "저장" : "수정",
                  style: TextStyle(color: _isEditingNotice ? _ntEditActiveText : _ntEditColor, fontSize: _ntEditFontSize, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
        Container(height: 1, color: _ntDivider, margin: const EdgeInsets.symmetric(vertical: 10)),
        if (_isEditingNotice)
          TextField(
            controller: _noticeCtrl, maxLines: 5,
            style: const TextStyle(color: _text, fontSize: _ntFontSize, height: 1.6), cursorColor: _teal,
            decoration: InputDecoration(
              hintText: "공지사항 내용을 입력하세요...", hintStyle: const TextStyle(color: _ntHintColor, fontSize: _ntFontSize),
              filled: true, fillColor: _ntFieldBg, contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _teal.withAlpha(60))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _teal, width: 1.5)),
            ),
          )
        else
          Container(
            width: double.infinity, constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _ntFieldBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _elevated, width: 1)),
            child: _noticeCtrl.text.isEmpty
                ? const Text("등록된 공지사항이 없습니다.", style: TextStyle(color: _ntHintColor, fontSize: _ntFontSize))
                : Text(_noticeCtrl.text, style: const TextStyle(color: _ntTextColor, fontSize: _ntFontSize, height: 1.6)),
          ),
        const SizedBox(height: 8),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('system_settings').doc('notice').snapshots(),
          builder: (_, snap) {
            if (!snap.hasData || !snap.data!.exists) return const SizedBox.shrink();
            final ts = snap.data!['updatedAt'];
            if (ts == null) return const SizedBox.shrink();
            return Text("마지막 수정: ${DateFormat('yyyy-MM-dd HH:mm').format((ts as Timestamp).toDate())}",
                style: const TextStyle(color: _ntStampColor, fontSize: _ntStampFontSize));
          },
        ),
      ]),
    );
  }

  // === 탭 3: 출금내역 =================================================================================

  Widget _withdrawalTab() {
    final totalTaxSum   = lEmp + lAcc + lTax;
    final totalPromoSum = lMission + lPerOrder + lRange;
    final totalFeeSum   = lWd + lComm;
    final totalDeduSum  = lIns + lLease;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, _whTabToCardGap, 15, 15),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(color: _whCardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _whCardBorder, width: _whCardBorderWidth)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: _sheetDateBtn(context, lStart, "시작일",   (d) => setState(() => lStart = d))),
            const Text(" ~ ", style: TextStyle(color: _text2, fontSize: 12)),
            Flexible(child: _sheetDateBtn(context, lEnd,   "마지막일", (d) => setState(() => lEnd   = d))),
            const SizedBox(width: _whGapDateToBtn),
            _smallBtn("조회",   _loadWithdrawalData, filled: true),
            const SizedBox(width: _whGapBtnToBtn),
            _smallBtn("초기화", () {
              if (lStart == null && lEnd == null) return; // 기본 상태면 변화 없음
              setState(() { lStart = lEnd = null; });
              _loadWithdrawalData(); // 전체 다시 로드
            }),
          ]),
          Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 5)),
          if (lLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: _teal)))
          else if (!lLoaded)
            const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("조회 버튼을 눌러주세요", style: TextStyle(color: _text2, fontSize: 12))))
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("배달수수료 (세전)", style: TextStyle(color: _whGrossColor, fontSize: _whGrossFontSize, fontWeight: FontWeight.w500)),
                Text("${_fmtC(lGross)} 원", style: const TextStyle(color: _whGrossColor, fontSize: _whGrossFontSize)),
              ]),
            ),
            _toggle("지원금합계", "${_fmtC(totalPromoSum)} 원", _text, lPromo,
                () => setState(() => lPromo = !lPromo), [
              _subC("건당프로모션", "${_fmtC(lPerOrder)} 원"),
              _sub("구간프로모션",  "${_fmtC(lRange)} 원"),
            ]),
            _toggle("세금합계", "${_fmtC(totalTaxSum)} 원", _pink, lTaxExp,
                () => setState(() => lTaxExp = !lTaxExp), [
              _subC("고용보험", "${_fmtC(lEmp)} 원", vc: _text2),
              _subC("산재보험", "${_fmtC(lAcc)} 원", vc: _text2),
              _subC("원천세",   "${_fmtC(lTax)} 원", vc: _text2),
            ]),
            _toggle("수수료합계", "${_fmtC(totalFeeSum)} 원", _pink, lCommExp,
                () => setState(() => lCommExp = !lCommExp), [
              _subC("출금수수료",   "${_fmtC(lWd)} 원",   vc: _text2),
              _subC("협력사수수료", "${_fmtC(lComm)} 원", vc: _text2),
            ]),
            _toggle("공제합계", "${_fmtC(totalDeduSum)} 원", _pink, lDedu,
                () => setState(() => lDedu = !lDedu), [
              _subC("시간제보험", "${_fmtC(lIns)} 원",   vc: _text2),
              _subC("리스비",     "${_fmtC(lLease)} 원", vc: _text2),
            ]),
            Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 10)),
            _row("총 출금금액", "${_fmtC(lTotal)} 원", lc: _teal, vc: _teal, bold: true, fs: 14),
          ],
        ]),
      ),
    );
  }

  // === 탭 3: 공제설정 =================================================================================

  // ═══════════════ 9. 공제설정 (로직) ═══════════════
  Widget _settingsTab() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(_stPadL, _stPadT, _stPadR, _stPadB),
    child: Container(
      padding: const EdgeInsets.fromLTRB(_stCardPadL, _stCardPadT, _stCardPadR, _stCardPadB),
      decoration: BoxDecoration(color: _stCardBg, borderRadius: BorderRadius.circular(_stCardRadius), border: Border.all(color: _stCardBorder, width: _stCardBorderWidth), boxShadow: _cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: (_settingsLocked ? _stWarnLockedColor : _stWarnColor).withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: (_settingsLocked ? _stWarnLockedColor : _stWarnColor).withAlpha(60)),
            ),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded, color: _settingsLocked ? _stWarnLockedColor : _stWarnColor, size: 20),
              const SizedBox(width: 6),
              Expanded(child: Text(
                _settingsLocked ? "업로드 완료!!\n23시 이후 설정 가능합니다." : "업로드 진행하기 전\n모든 설정을 완료해주세요!!",
                style: TextStyle(color: _settingsLocked ? _stWarnLockedColor : _stWarnColor, fontSize: _stWarnFontSize),
              )),
            ]),
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _settingsLocked ? null : () {
              if (isEditingRates) {
                _saveRates();
              } else {
                void fmt(TextEditingController c) {
                  final n = double.tryParse(c.text.replaceAll(',', ''));
                  if (n != null && n == n.truncateToDouble()) c.text = NumberFormat('#,###').format(n.toInt());
                }
                fmt(_feeCtrl); fmt(_commissionCtrl);
                setState(() => isEditingRates = true);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: _settingsLocked ? Colors.transparent : (isEditingRates ? _stEditActiveBg : Colors.transparent),
                border: Border.all(color: _settingsLocked ? _elevated : _elevated, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(isEditingRates ? "저장" : "수정",
                  style: TextStyle(
                      color: _settingsLocked ? _text2 : (isEditingRates ? _stEditActiveText : _stEditColor),
                      fontSize: _stEditFontSize, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
        Container(height: 1, color: _elevated, margin: const EdgeInsets.only(top: 16, bottom: 12)),
        _rateRow("고용 보험", _employmentCtrl, "%"),
        _rateRow("산재 보험", _accidentCtrl, "%"),
        _rateRow("원천세", _taxCtrl, "%"),
        _divider(),
        _promoHeader("건당 프로모션", true),
        for (int i = 0; i < perOrderList.length; i++) _rangeRow(perOrderList[i], "원", true, i),
        const SizedBox(height: 8),
        _promoHeader("구간 프로모션", false),
        for (int i = 0; i < incentiveList.length; i++) _rangeRow(incentiveList[i], "원", false, i),
        _divider(),
        _rateRow("출금 수수료", _feeCtrl, "원"),
        const SizedBox(height: 4),
        _rateRow("협력사수수료", _commissionCtrl, "%"),
        Container(height: 1, color: _elevated, margin: const EdgeInsets.only(top: 16, bottom: 12)),
        Center(
          child: SizedBox(
            width: _stUploadW, height: _stUploadH,
            child: GlassShineButton(
              label: "리포트 업로드",
              onPressed: _uploadReport,
              icon: Icons.upload,
              accent: _teal,
              height: _stUploadH,
              radius: _stUploadRadius,
              fontSize: _stUploadFontSize,
            ),
          ),
        ),
      ]),
    ),
  );

  Widget _rateRow(String label, TextEditingController ctrl, String unit) => Padding(
    padding: EdgeInsets.symmetric(vertical: isEditingRates ? 1 : 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: _stLabelColor, fontSize: _stLabelFontSize)),
      Row(children: [
        isEditingRates
            ? SizedBox(width: 80, child: TextField(
                controller: ctrl, textAlign: TextAlign.end,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: _stValueColor, fontSize: _stValueFontSize),
                cursorColor: _teal.withAlpha(60),
                onChanged: (v) {
                  final raw = v.replaceAll(',', '');
                  if (raw.contains('.')) return;
                  final n = int.tryParse(raw);
                  if (n != null) {
                    final f = NumberFormat('#,###').format(n);
                    if (f != v) ctrl.value = TextEditingValue(text: f, selection: TextSelection.collapsed(offset: f.length));
                  }
                },
                decoration: InputDecoration(
                  isDense: true, border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _teal.withAlpha(60))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _teal)),
                ),
              ))
            : Container(
                width: 80,
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _stRowDivider))),
                child: Text(_fmt(ctrl.text), textAlign: TextAlign.right, style: const TextStyle(color: _stValueColor, fontSize: _stValueFontSize)),
              ),
        const SizedBox(width: 4),
        Text(unit, style: const TextStyle(color: _stUnitColor, fontSize: _stUnitFontSize)),
      ]),
    ]),
  );

  Widget _promoHeader(String title, bool isPerOrder) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(title, style: const TextStyle(color: _stLabelColor, fontSize: _stLabelFontSize)),
    if (isEditingRates) Row(children: [
      GestureDetector(onTap: () => _addRow(isPerOrder), child: const Text("+ 추가", style: TextStyle(color: _stPromoActionColor, fontSize: _stPromoActionFontSize, fontWeight: FontWeight.w700))),
      const SizedBox(width: 8),
      GestureDetector(onTap: () { final list = isPerOrder ? perOrderList : incentiveList; if (list.length > 1) _removeRow(isPerOrder, list.length - 1); },
          child: const Text("- 제거", style: TextStyle(color: _stPromoActionColor, fontSize: _stPromoActionFontSize, fontWeight: FontWeight.w700))),
    ]),
  ]);

  Widget _rangeRow(Map<String, TextEditingController> row, String unit, bool isPerOrder, int i) {
    Widget buildField(TextEditingController c) => isEditingRates
        ? SizedBox(width: 50, child: TextField(
            controller: c, keyboardType: TextInputType.number, textAlign: TextAlign.right,
            style: const TextStyle(color: _stValueColor, fontSize: _stValueFontSize), cursorColor: _teal.withAlpha(60),
            onChanged: (v) { final raw = v.replaceAll(',', ''); final n = int.tryParse(raw); if (n != null) { final f = NumberFormat('#,###').format(n); if (f != v) c.value = TextEditingValue(text: f, selection: TextSelection.collapsed(offset: f.length)); } },
            decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 2),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _teal.withAlpha(60))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _teal))),
          ))
        : Container(
            width: 50,
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _stRowDivider))),
            child: Text(_fmt(c.text), textAlign: TextAlign.right, style: const TextStyle(color: _stValueColor, fontSize: _stValueFontSize)),
          );

    return Padding(
      padding: EdgeInsets.only(bottom: isEditingRates ? 2 : 4),
      child: Row(children: [
        buildField(row['min']!),
        const SizedBox(width: 4),
        const Text("건", style: TextStyle(color: _stUnitColor, fontSize: _stUnitFontSize)),
        const Text("  ~  ", style: TextStyle(color: _stUnitColor, fontSize: _stUnitFontSize)),
        buildField(row['max']!),
        const SizedBox(width: 4),
        const Text("건", style: TextStyle(color: _stUnitColor, fontSize: _stUnitFontSize)),
        const Spacer(),
        SizedBox(width: 80, child: isEditingRates
            ? TextField(
                controller: row['amount']!, keyboardType: TextInputType.number, textAlign: TextAlign.right,
                style: const TextStyle(color: _stValueColor, fontSize: _stValueFontSize), cursorColor: _teal.withAlpha(60),
                onChanged: (v) { final raw = v.replaceAll(',', ''); final n = int.tryParse(raw); if (n != null) { final f = NumberFormat('#,###').format(n); if (f != v) row['amount']!.value = TextEditingValue(text: f, selection: TextSelection.collapsed(offset: f.length)); } },
                decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 2),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _teal.withAlpha(60))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _teal))),
              )
            : Container(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _stRowDivider))),
                child: Text(_fmt(row['amount']!.text), textAlign: TextAlign.right, style: const TextStyle(color: _stValueColor, fontSize: _stValueFontSize)),
              )),
        const SizedBox(width: 4),
        const Text("원", style: TextStyle(color: _stUnitColor, fontSize: _stUnitFontSize)),
      ]),
    );
  }

  // === 공통 위젯 =================================================================================

  Widget _divider() => Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 5));

  Widget _row(String label, String value, {Color lc = _text2, Color vc = _text2, bool bold = false, double fs = 12}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: lc, fontSize: fs, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value, style: TextStyle(color: vc, fontSize: fs, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ]));

  Widget _sub(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: _whSubColor, fontSize: _whSubFontSize)),
        Text(value, style: const TextStyle(color: _whSubColor, fontSize: _whSubFontSize)),
      ]));

  Widget _subC(String label, String value, {Color lc = _whSubColor, Color vc = _whSubColor}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: lc, fontSize: _whSubFontSize)),
          Text(value, style: TextStyle(color: vc, fontSize: _whSubFontSize)),
        ]));

  Widget _toggle(String label, String value, Color vc, bool expanded, VoidCallback onTap, List<Widget> children) =>
      Column(children: [
        GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Text(label, style: const TextStyle(color: _whTogLabelColor, fontSize: _whTogFontSize, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.expand_less : Icons.expand_more, color: _whTogIconColor, size: _whTogIconSize),
              const Spacer(),
              Text(value, style: TextStyle(color: vc, fontSize: _whTogFontSize)),
            ]))),
        if (expanded)
          Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: _whSubBoxBg, borderRadius: BorderRadius.circular(_whSubBoxRadius), border: Border.all(color: _whSubBoxBorder)),
              child: Column(children: children)),
      ]);

  Widget _smallBtn(String label, VoidCallback onTap, {bool filled = false}) => GestureDetector(
    onTap: onTap,
    child: Container(height: _whBtnHeight, padding: const EdgeInsets.symmetric(horizontal: _whBtnPadH),
      decoration: BoxDecoration(color: filled ? _whBtnFilledBg : Colors.transparent, border: Border.all(color: filled ? _whBtnFilledBg : _whBtnLineBorder), borderRadius: BorderRadius.circular(_whBtnRadius)),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: filled ? _whBtnFilledText : _whBtnLineText, fontSize: _whBtnFontSize, fontWeight: FontWeight.w600)),
    ),
  );
}

// === Excel 파서 ==============================================================================

Map<String, Map<String, dynamic>> _parseExcelBytes(List<int> bytes) {
  final excel = Excel.decodeBytes(bytes);
  final sheet = excel.tables[excel.tables.keys.first];
  if (sheet == null) return {};
  final header = sheet.rows[0];
  int uidIdx = -1, nameIdx = -1, feeIdx = -1, dateIdx = -1;
  for (int i = 0; i < header.length; i++) {
    final v = header[i]?.value?.toString().trim() ?? '';
    if (v == 'User ID')    uidIdx  = i;
    if (v == '라이더명')   nameIdx = i;
    if (v == '배달처리비') feeIdx  = i;
    if (v == '운행일')     dateIdx = i;
  }
  if (uidIdx == -1 || feeIdx == -1) return {};
  final Map<String, Map<String, dynamic>> result = {};
  String detectedDate = '';
  for (int r = 1; r < sheet.rows.length; r++) {
    final row = sheet.rows[r]; if (row.isEmpty) continue;
    final userId = row[uidIdx]?.value?.toString().trim() ?? ''; if (userId.isEmpty) continue;
    final name   = nameIdx != -1 ? (row[nameIdx]?.value?.toString().trim() ?? '') : '';
    final feeRaw = row[feeIdx]?.value;
    final fee    = feeRaw == null ? 0.0 : (feeRaw is num) ? (feeRaw as num).toDouble() : double.tryParse(feeRaw.toString()) ?? 0.0;
    if (detectedDate.isEmpty && dateIdx != -1) {
      final dr = row[dateIdx]?.value?.toString().trim() ?? '';
      if (dr.length == 8) detectedDate = '${dr.substring(0,4)}-${dr.substring(4,6)}-${dr.substring(6,8)}';
    }
    result.putIfAbsent(userId, () => {'reportId': userId, 'name': name, 'deliveryFee': 0.0, 'deliveryCount': 0, 'date': detectedDate});
    result[userId]!['deliveryFee']   = (result[userId]!['deliveryFee']   as double) + fee;
    result[userId]!['deliveryCount'] = (result[userId]!['deliveryCount'] as int)    + 1;
    if (detectedDate.isNotEmpty) result[userId]!['date'] = detectedDate;
  }
  return result;
}

// === 누적 지급액 영역 차트 Painter (기사페이지 차트 포팅) =====================
class _AdminAreaChartPainter extends CustomPainter {
  final List<double> data;
  _AdminAreaChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final n = data.length;
    if (n < 2) return;
    final maxV = data.reduce(math.max);
    final minV = data.reduce(math.min);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    const padT = 20.0, padB = 8.0, padX = 5.0;
    final w = size.width, h = size.height;

    canvas.drawLine(
      Offset(0, h * 0.5),
      Offset(w, h * 0.5),
      Paint()
        ..color = _elevated.withValues(alpha: 0.3)
        ..strokeWidth = 1,
    );

    final xs = List<double>.generate(n, (i) => padX + (i / (n - 1)) * (w - 2 * padX));
    final ys = List<double>.generate(n, (i) {
      final norm = (data[i] - minV) / range;
      return h - padB - norm * (h - padT - padB);
    });
    final dx = xs[1] - xs[0];

    final slope = List<double>.generate(n - 1, (i) => (ys[i + 1] - ys[i]) / dx);
    final m = List<double>.filled(n, 0);
    m[0] = slope[0];
    m[n - 1] = slope[n - 2];
    for (int i = 1; i < n - 1; i++) {
      m[i] = (slope[i - 1] * slope[i] <= 0) ? 0 : (slope[i - 1] + slope[i]) / 2;
    }
    for (int i = 0; i < n - 1; i++) {
      if (slope[i] == 0) {
        m[i] = 0;
        m[i + 1] = 0;
        continue;
      }
      final a = m[i] / slope[i];
      final b = m[i + 1] / slope[i];
      final s = a * a + b * b;
      if (s > 9) {
        final t = 3 / math.sqrt(s);
        m[i] = t * a * slope[i];
        m[i + 1] = t * b * slope[i];
      }
    }

    final path = Path()..moveTo(xs[0], ys[0]);
    for (int i = 0; i < n - 1; i++) {
      final c1 = Offset(xs[i] + dx / 3, ys[i] + m[i] * dx / 3);
      final c2 = Offset(xs[i + 1] - dx / 3, ys[i + 1] - m[i + 1] * dx / 3);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, xs[i + 1], ys[i + 1]);
    }

    final fill = Path.from(path)
      ..lineTo(xs[n - 1], h)
      ..lineTo(xs[0], h)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x264AE3ED), Color(0x004AE3ED)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = _chartLineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _chartLineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    int maxIdx = 0;
    for (int i = 1; i < n; i++) {
      if (data[i] > data[maxIdx]) maxIdx = i;
    }
    final peak = Offset(xs[maxIdx], ys[maxIdx]);
    canvas.drawCircle(peak, _chartPeakDotOuter, Paint()..color = _chartPeakDotColor);
    canvas.drawCircle(peak, _chartPeakDotInner, Paint()..color = _panel);

    final tp = TextPainter(
      text: TextSpan(
        text: NumberFormat('#,###').format(data[maxIdx]),
        style: const TextStyle(
            color: _chartPeakLabelColor,
            fontSize: _chartPeakLabelFontSize,
            fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    double lx = (peak.dx - tp.width / 2).clamp(0.0, w - tp.width);
    double ly = peak.dy - tp.height - 6;
    if (ly < 0) ly = peak.dy + 6;
    tp.paint(canvas, Offset(lx, ly));
  }

  @override
  bool shouldRepaint(covariant _AdminAreaChartPainter old) => old.data != data;
}
// === 링 게이지 Painter (기사페이지 포팅) =====================================
class _RingGaugePainter extends CustomPainter {
  final double pct;
  _RingGaugePainter(this.pct);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = _ringStroke;
    final rect = Rect.fromLTWH(
        stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    const start = -math.pi / 2;
    final p = pct.clamp(0.0, 1.0);
    final sweep = 2 * math.pi * p;

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = _elevated.withValues(alpha: _ringTrackAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (p <= 0) return;

    final shader = const SweepGradient(
      colors: [_purple, _purple, _pink, _pink, _teal, _teal],
      stops: [0.0, 0.28, 0.34, 0.58, 0.64, 1.0],
      transform: GradientRotation(start),
    ).createShader(rect);

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _RingGaugePainter old) => old.pct != pct;
}