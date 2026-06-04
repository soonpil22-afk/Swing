import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'main.dart';
import 'glass_shine_button.dart';
// ═══════════════════════════════════════════════════════════════════════
// 공통 색 팔레트 (모든 섹션 공유)
// ═══════════════════════════════════════════════════════════════════════
const _appBg    = Color(0xFF090E1A); // 전체 배경 (패널보다 살짝 밝게)
const _panel    = Color(0xFF070C18); // 메인 배경 (inset 패널)
const _surface  = Color(0xFF0D1427); // 카드
const _elevated = Color(0xFF303854); // 트랙 · 테두리
const _chip     = Color(0xFF18203A); // 칩 · 인풋 · 버튼 배경

const _text  = Color(0xFFFBFBFB);
const _text2 = Color(0xFF787C8D);

const _teal     = Color(0xFF4AE3ED); // 민트 (메인 액센트)
const _purple   = Color(0xFF9F66E6); // 보라
const _pink     = Color(0xFFE672BA); // 핑크
const _amber    = Color(0xFFE6C97F); // 노랑
const _card     = Color(0xFF0E2C3C); // 청록
const _dot      = Color(0xFFFBFBFB); // 차트 꼭짓점 흰 점
const _red      = Color(0xFFE05252);
const _orange   = Color(0xFFE08F2A);  // 테두리 강조

const _cardBorder = Color(0x4D303854);

// ── 보조 테두리(옅은) ──
const _borderDim = Color(0x33303854);

// 카드 그림자: 오른쪽 + 아래 (여러 섹션 공통으로 쓰는 기본 그림자)
const List<BoxShadow> _cardShadow = [
  BoxShadow(color: Color(0xD9000000), blurRadius: 11, offset: Offset(4, 6)),
];

// ═══════════════════════════════════════════════════════════════════════
// 1. 전체 배경 (조정값)
// ═══════════════════════════════════════════════════════════════════════
const Color _bgScaffold = _appBg;   // 모든 화면 Scaffold 배경색

// ═══════════════════════════════════════════════════════════════════════
// 2. 메인 배경 (홈 안쪽 패널) (조정값)
// ═══════════════════════════════════════════════════════════════════════
// ── 색 (팔레트에서 선택) ──
const Color  _panelColor       = _panel;     // 패널 배경색
const Color  _panelBorderColor = _elevated;  // 테두리 색
const double _panelBorderAlpha = 1.0;        // 테두리 투명도(0~1, 1.0=솔리드)
// ── 숫자 (크기·여백) ──
const double _panelOuterPad    = 6;   // 패널 바깥 여백
const double _panelRadius      = 24;  // 패널 모서리 둥글기
const double _panelBorderWidth = 1;   // 테두리 두께
const double _panelPadL = 11;  // 안쪽 여백 왼쪽
const double _panelPadT = 8;  // 안쪽 여백 위
const double _panelPadR = 11;  // 안쪽 여백 오른쪽
const double _panelPadB = 8;  // 안쪽 여백 아래
// ── 그림자 ──
const List<BoxShadow> _panelShadow = [
  BoxShadow(color: Color(0xFF18203A), blurRadius: 11, offset: Offset(4, 6)),
];
// ═══════════════════════════════════════════════════════════════════════
// 3. 안녕하세요 (인사) (조정값)
// ═══════════════════════════════════════════════════════════════════════
// ── 색 (팔레트에서 선택) ──
const Color _greetIconOuterColor  = _teal;    // 바깥 원 색
const Color _greetIconInnerColor  = _purple;  // 안쪽 원 색
const Color _greetHelloColor      = _text;    // "안녕하세요," 글씨 색
const Color _greetNameColor       = _amber;   // 이름 글씨 색
const Color _greetSuffixColor     = _text;    // " 님" 글씨 색
// ── 글씨 크기 (각각 따로) ──
const double _greetHelloFontSize  = 18;  // "안녕하세요," 크기
const double _greetNameFontSize   = 18;  // 이름 크기
const double _greetSuffixFontSize = 18;  // " 님" 크기
// ── 숫자 (아이콘·버튼 크기/여백) ──
const double _gapGreetToChart     = 6;  // 안녕하세요 ↔ 차트카드 간격
const double _greetVPad           = 1;   // 인사줄 위아래 여백
const double _greetIconOuterSize  = 22;  // 바깥 원 지름
const double _greetIconInnerSize  = 12;  // 안쪽 원 지름
const double _greetIconGap        = 12;  // 원과 글씨 사이 간격
const double _greetLogoutBoxSize  = 38;  // 로그아웃 버튼 크기
const double _greetLogoutRadius   = 10;  // 로그아웃 버튼 모서리
const double _greetLogoutIconSize = 19;  // 로그아웃 아이콘 크기
// ── 표시 문구 ──
const String _greetHelloText    = '안녕하세요!! ';
const String _greetSuffixText   = '님.';
const String _greetNameFallback = '라이더';

// ═══════════════════════════════════════════════════════════════════════
// 4. 차트 카드 (조정값)
// ═══════════════════════════════════════════════════════════════════════
// ── 카드 자체 (색·모서리·테두리·그림자) ──
const Color  _chartCardBg          = _surface;     // 카드 배경색
const Color  _chartCardBorder      = _cardBorder;  // 카드 테두리 색
const double _gapChartToNotice = 12;  // 차트카드 ↔ 공지사항 간격
const double _chartCardRadius      = 14;   // 카드 모서리
const double _chartCardBorderWidth = 1;    // 카드 테두리 두께
const double _chartCardPadL = 10;   // 카드 안쪽 여백 왼쪽
const double _chartCardPadT = 14;  // 카드 안쪽 여백 위
const double _chartCardPadR = 10;   // 카드 안쪽 여백 오른쪽
const double _chartCardPadB = 8;   // 카드 안쪽 여백 아래
const List<BoxShadow> _chartCardShadow = [
  BoxShadow(color: Color(0xD9000000), blurRadius: 11, offset: Offset(4, 6)),
];
// ── 기간 토글 (일간/주간/월간) ──
const double _togFontSize    = 12;  // 토글 글씨 크기
const double _togPadH        = 10;  // 토글 좌우 여백
const double _togPadV        = 5;   // 토글 위아래 여백
const double _togGap         = 6;   // 토글 사이 간격
const double _togRadius      = 20;  // 토글 모서리
const double _togSelAlpha    = 0.16; // 선택된 배경 투명도
const double _togSelBorderAlpha = 0.6; // 선택된 테두리 투명도
const Color  _togUnselColor  = _text2;    // 미선택 글씨 색
const Color  _togUnselBorder = _elevated; // 미선택 테두리 색
const double _togUnselBorderAlpha = 0.45;
// ── 목표 버튼 ──
// 색은 일간/주간/월간 토글 색(_periodColor)을 그대로 따라감 (아래 _targetButton 참고)
const double _targetFontSize   = 11;   // 목표 글씨 크기
const double _targetPadH       = 11;   // 좌우 여백
const double _targetPadV       = 5;    // 위아래 여백
const double _targetRadius     = 20;   // 모서리
const double _targetBgAlpha    = 0.12; // 배경 투명도
const double _targetBorderAlpha = 0.5; // 테두리 투명도
// ── 목표 금액 편집 다이얼로그 (목표 버튼 누르면 뜨는 입력창) ──
const Color  _tgtDlgBg            = _surface;  // 다이얼로그 배경색
const Color  _tgtDlgBorderColor   = _elevated;    // 다이얼로그 외곽 테두리 색
const double _tgtDlgBorderWidth   = 1;         // 다이얼로그 외곽 테두리 두께
const double _tgtDlgRadius        = 14;        // 다이얼로그 모서리
const double _tgtDlgPadTop        = 22;        // 다이얼로그 위 여백 (제목 위)
const double _tgtDlgPadBottom     = 6;        // 다이얼로그 아래 여백 (버튼 아래)
const Color  _tgtDlgTitleColor    = _text;    // 제목 글씨 색
const double _tgtDlgTitleFontSize = 15;        // 제목 글씨 크기
const Color  _tgtDlgInputColor    = _text;     // 입력 숫자 글씨 색
const double _tgtDlgInputFontSize = 15;        // 입력 숫자 글씨 크기
const Color  _tgtDlgCursorColor   = _teal;     // 커서 색
const Color  _tgtDlgUnitColor     = _text;     // " 원" 글씨 색
const Color  _tgtDlgHintColor     = _text;     // 힌트 글씨 색
const String _tgtDlgHintText      = '목표 금액 입력'; // 힌트 문구
const Color  _tgtDlgInputLineColor = _elevated; // 입력선(기본) 색
const Color  _tgtDlgFocusColor    = _elevated;     // 입력선(포커스) 색
// ── 메인 금액 (큰 숫자) ──
const Color  _chartTotalColor    = _text;  // 금액 숫자 글씨 색
const double _chartTotalFontSize = 26;     // 금액 숫자 글씨 크기
const double _chartTotalLetterSp = -0.5;   // 자간
const double _chartTotalLeftPad  = 16;     // 금액 왼쪽 들여쓰기(오른쪽 이동량)
const Color  _chartTotalUnitColor    = _text; // 금액의 " 원" 글씨 색
const double _chartTotalUnitFontSize = 14;    // 금액의 " 원" 글씨 크기
// ── 증감률 (+12% 등) ──
const double _chartDeltaIconSize = 16;  // 화살표 아이콘 크기
const double _chartDeltaFontSize = 13;  // 퍼센트 글씨 크기
const double _chartCompareFontSize = 12; // "전일 대비" 글씨 크기
const double _chartDeltaGap      = 4;   // 아이콘-숫자 간격
const double _chartCompareGap    = 6;   // 숫자-비교문구 간격
// ── 링 게이지 ──
const double _ringBoxSize      = 84;  // 링 전체 크기
const double _ringStroke       = 9;   // 링 두께
const double _ringPctFontSize  = 18;  // 가운데 % 글씨 크기
const double _ringLabelFontSize = 10; // "달성" 글씨 크기
const double _ringTrackAlpha   = 0.5; // 배경 트랙 투명도
// ── 영역 차트 ──
const Color  _chartLineColor   = _teal;  // 차트 선 색
const double _chartHeight      = 64;   // 차트 높이
const double _chartLineWidth   = 2.5;  // 선 두께
const double _chartPeakDotOuter = 3.6; // 꼭짓점 바깥 점 크기
const double _chartPeakDotInner = 1.6; // 꼭짓점 안쪽 점 크기
const Color  _chartPeakDotColor = _dot;   // 꼭짓점 점 색
const double _chartPeakLabelFontSize = 10.5; // 꼭짓점 금액 글씨 크기
const Color  _chartPeakLabelColor = _text;   // 꼭짓점 금액 글씨 색
const double _chartLabelFontSize = 11; // 아래 요일/날짜 라벨 크기
const Color  _chartLabelColor  = _text2;  // 아래 라벨 색
const double _chartLabelGap    = 8;    // 차트-라벨 간격
// ── 출금 영역 (그라디언트 프레임: 금액 + 출금신청 버튼) ──
const double _withdrawDividerAlpha  = 0.5;    // 위 구분선 투명도
// 프레임 (빛 흐르는 테두리)
const Color  _wfGold        = Color(0xFFFFD372); // 골드
const Color  _wfGoldText2   = Color(0xFFFFEAB0); // 금액 골드 그라데이션 끝색
const Color  _wfGoldDeep    = Color(0xFFF4B64C); // 진한 골드(버튼 시작)
const Color  _wfPink        = Color(0xFFFF5FC4); // 핑크
const Color  _wfPurple      = Color(0xFF9D7BFF); // 보라
const Color  _wfInnerTop    = Color(0xFF141A30); // 안쪽 배경 위
const Color  _wfInnerBottom = Color(0xFF10142A); // 안쪽 배경 아래
const double _wfRadius      = 18;   // 프레임 모서리
const double _wfBorderWidth = 1.5;  // 테두리(빛) 두께
const int    _wfFlowMs      = 3500; // 빛 한 바퀴 도는 시간(ms, 작을수록 빠름)
// 금액 글씨
const double _wfAmtLeftGap      = 24; // 금액 왼쪽 여백(오른쪽으로 밀기)
const double _wfAmtFontSize     = 22; // 금액 숫자 크기
const double _wfAmtUnitFontSize = 13; // " 원" 크기
// 출금신청 버튼
const double _wfBtnFontSize = 15; // 버튼 글씨 크기
const double _wfBtnPadH     = 20;   // 버튼 좌우 여백
const double _wfBtnPadV     = 12;   // 버튼 위아래 여백
const double _wfBtnRadius   = 12;   // 버튼 모서리
// ── 출금신청 확인 다이얼로그 (출금신청 버튼 누르면 뜨는 확인창) ──
const Color  _wdlgBg            = _surface;   // 배경색
const Color  _wdlgBorderColor   = _elevated;   // 테두리 색
const double _wdlgBorderAlpha   = 0.4;     // 테두리 투명도
const double _wdlgBorderWidth   = 1;       // 테두리 두께
const double _wdlgMaxWidth      = 320;     // 최대 너비
const double _wdlgRadius        = 14;      // 모서리
const double _wdlgPadL = 24;  // 안쪽 여백 왼
const double _wdlgPadT = 24;  // 안쪽 여백 위
const double _wdlgPadR = 24;  // 안쪽 여백 오른
const double _wdlgPadB = 20;  // 안쪽 여백 아래
const String _wdlgTitleText      = '정산내용을 확인하셨습니까?'; // 제목 문구
const Color  _wdlgTitleColor     = _text;  // 제목 글씨 색
const double _wdlgTitleFontSize  = 15;     // 제목 글씨 크기
const double _wdlgTitleGap       = 20;     // 제목-버튼 사이 간격
const double _wdlgBtnGap         = 10;     // 취소-확인 버튼 사이 간격
const double _wdlgBtnRadius      = 22;     // 버튼 모서리
const double _wdlgCancelFontSize = 14;     // 취소 버튼 글씨 크기
const double _wdlgOkFontSize     = 14;     // 확인 버튼 글씨 크기

// ═══════════════════════════════════════════════════════════════════════
// 5. 공지사항 (조정값)
// ═══════════════════════════════════════════════════════════════════════
// ── 헤더 (제목 줄) ──
const double _gapNoticeToMenu  = 6;  // 공지사항 ↔ 정산내역 간격
const Color  _ntcIconColor     = _purple;  // 확성기 아이콘 색
const double _ntcIconSize      = 22;       // 확성기 아이콘 크기
const double _ntcTitleFontSize = 14;       // "공지사항" 글씨 크기
const Color  _ntcTitleColor    = _text;    // "공지사항" 글씨 색
const double _ntcHeaderGap     = 10;       // 아이콘-제목 간격
// ── 더보기 ──
const double _ntcMoreFontSize  = 12;       // "더보기" 글씨 크기
const Color  _ntcMoreColor     = _text2;   // "더보기" 글씨 색
const double _ntcMoreIconSize  = 18;       // 더보기 화살표 크기
// ── 공지 내용 (목록) ──
const double _ntcHeaderBottomGap = 12;     // 헤더-내용 사이 간격
const double _ntcItemGap       = 8;        // 공지 항목 사이 간격
const double _ntcItemFontSize  = 12;       // 공지 글씨 크기
const Color  _ntcItemColor     = _text;    // 공지 글씨 색
const double _ntcDotSize       = 7;        // 마름모 점 크기
const Color  _ntcDotColor      = _purple;  // 마름모 점 색
const double _ntcDotGap        = 12;       // 점-글씨 간격
const int    _ntcPreviewCount  = 2;        // 홈에서 미리보기 줄 수
// ── 빈 공지 안내 ──
const double _ntcEmptyFontSize = 12;       // "등록된 공지가 없습니다" 크기
const Color  _ntcEmptyColor    = _text2;   // 안내 글씨 색
const String _ntcEmptyText     = '등록된 공지가 없습니다.';
// ── 공지 팝업 다이얼로그 ──
const Color  _ntcDlgBg          = _surface;   // 다이얼로그 배경색
const Color  _ntcDlgBorderColor = _elevated;  // 다이얼로그 테두리 색
const double _ntcDlgBorderAlpha = 1;     // 테두리 투명도
const double _ntcDlgMaxWidth    = 360;     // 다이얼로그 최대 너비
const double _ntcDlgRadius      = 14;      // 다이얼로그 모서리
const double _ntcDlgPadL = 20;  // 안쪽 여백 왼
const double _ntcDlgPadT = 18;  // 안쪽 여백 위
const double _ntcDlgPadR = 20;  // 안쪽 여백 오른
const double _ntcDlgPadB = 16;  // 안쪽 여백 아래
const Color  _ntcDlgIconColor    = _purple; // 팝업 확성기 아이콘 색
const double _ntcDlgIconSize     = 20;     // 팝업 아이콘 크기
const double _ntcDlgTitleFontSize = 15;    // 팝업 "공지사항" 글씨 크기
const Color  _ntcDlgTitleColor   = _text;  // 팝업 제목 색
const double _ntcDlgBodyFontSize = 13;     // 팝업 본문 글씨 크기
const Color  _ntcDlgBodyColor    = _text; // 팝업 본문 색
const double _ntcDlgBodyHeight   = 1.8;    // 팝업 본문 줄간격
// ── 팝업 확인 버튼 ──
const double _ntcDlgBtnFontSize  = 14;     // 버튼 글씨 크기

// ═══════════════════════════════════════════════════════════════════════
// 6-1. 정산내역 페이지 - 메인배경 + 탭 (조정값)
// ═══════════════════════════════════════════════════════════════════════
const double _menuStPadV = 12;  // [6] 정산내역 카드 내부 위아래 여백
const Color  _hpPanelColor       = _panel;     // 패널 배경색
const Color  _hpPanelBorderColor = _elevated;  // 패널 테두리 색
const double _hpPanelBorderAlpha = 1.0;        // 테두리 투명도 (1.0=솔리드)
const double _hpOuterPad         = 10;  // 패널 바깥 여백
const double _hpPanelRadius      = 24;  // 패널 모서리
const Color  _hpTabTrackColor    = _surface;   // 탭 전체 배경(트랙)
const Color  _hpTabIndicatorColor = _chip;     // 선택된 탭 배경
const Color  _hpTabIndicatorBorder = _cardBorder; // 선택탭 테두리
const Color  _hpTabSelColor      = _teal;      // 선택된 탭 글씨 색
const Color  _hpTabUnselColor    = _text2;     // 미선택 탭 글씨 색
const double _hpTabFontSize      = 14;         // 탭 글씨 크기
const double _hpTabTrackRadius   = 10;         // 탭 트랙 모서리
const double _hpTabIndicatorRadius = 7;        // 선택탭 모서리
const double _hpTabTrackPad      = 3;          // 탭 트랙 안쪽 여백
const double _hpTabMarginL = 12; // 탭 바깥 여백 왼
const double _hpTabMarginT = 2;  // 탭 바깥 여백 위
const double _hpTabMarginR = 12; // 탭 바깥 여백 오른
const double _hpTabMarginB = 8;  // 탭 바깥 여백 아래
const String _hpTab1Text         = '정산 내역';  // 첫 번째 탭 이름
const String _hpTab2Text         = '출금 내역';  // 두 번째 탭 이름
// ── 헤더 아래 경계선 갭 ──
const double _hpGapHeaderToDiv = 0;  // 뒤로가기 ↔ 경계선 갭
const double _hpGapDivToTab    = 12;  // 경계선 ↔ 정산내역 탭 갭
const double _hpDivMarginH     = 15; // 경계선 좌우 여백(끝까지 안 붙음)

// ═══════════════════════════════════════════════════════════════════════
// 6-2. 정산내역 카드 (리포트 업로드 내용) (조정값)
// ═══════════════════════════════════════════════════════════════════════
const Color  _stEmptyIconColor  = _text2;  // 아이콘 색
const double _stEmptyIconSize   = 48;      // 아이콘 크기
const Color  _stEmptyTitleColor = _text2;  // 안내 제목 색
const double _stEmptyTitleFontSize = 14;   // 안내 제목 크기
const Color  _stEmptySubColor   = _text2;  // 안내 부제 색
const double _stEmptySubFontSize = 12;     // 안내 부제 크기
// ── 메인배경 ↔ 날짜카드 갭 (목록 바깥 여백) ──
const double _stListPadL = 12;  // 좌측 갭
const double _stListPadT = 2;  // 위 갭
const double _stListPadR = 12;  // 우측 갭
const double _stListPadB = 15;  // 아래 갭
const Color  _stCardBg          = _surface;    // 카드 배경색
const Color  _stCardBorderOpen  = _cardBorder; // 펼친 상태 테두리
const Color  _stCardBorderClose = _borderDim;  // 접힌 상태 테두리
const double _stCardRadius      = 12;  // 카드 모서리
const double _stCardGap         = 6;   // 카드 사이 간격
const double _stCardHeadPadH    = 4;   // 카드 머리 좌우 여백
const double _stCardHeadPadV    = 12;  // 카드 머리 위아래 여백
const Color  _stDateChipBg      = _chip;   // 날짜 칩 배경
const Color  _stDateChipBorder  = _cardBorder; // 날짜 칩 테두리
const Color  _stDateChipText    = _teal;   // 날짜 칩 글씨 색
const double _stDateChipFontSize = 12;     // 날짜 칩 글씨 크기
const Color  _stDayCountColor   = _amber;  // "N일" 글씨 색
const double _stDayCountFontSize = 11;     // "N일" 글씨 크기
const Color  _stHeadAmtColor    = _text;   // 머리 금액 색
const double _stHeadAmtFontSize = 16;      // 머리 금액 크기
const double _stBodyPadL = 14;  // 상세 안쪽 여백 왼
const double _stBodyPadT = 10;  // 상세 안쪽 여백 위
const double _stBodyPadR = 14;  // 상세 안쪽 여백 오른
const double _stBodyPadB = 14;  // 상세 안쪽 여백 아래
const Color  _stDayChipBg       = _chip;   // 일자 칩 배경
const Color  _stDayChipBorder   = _borderDim; // 일자 칩 테두리
const Color  _stDayChipText     = _teal;   // 일자 칩 글씨 색
const double _stDayChipFontSize = 11;      // 일자 칩 글씨 크기
const double _stRowFontSize     = 12;      // 행 라벨 글씨 크기
const double _stRowAmtFontSize  = 16;      // 행 금액 글씨 크기
const Color  _stRowLabelColor   = _text;   // 기본 라벨 색
const Color  _stRowPinkColor    = _pink;   // 세금/수수료/공제 라벨 색
const Color  _stToggleIconColor = _text2;  // 토글 화살표 색
const double _stToggleIconSize  = 15;      // 토글 화살표 크기
const Color  _stSubBoxBg        = _appBg;  // 하위 박스 배경
const Color  _stSubBoxBorder    = _borderDim; // 하위 박스 테두리
const double _stSubBoxRadius    = 8;       // 하위 박스 모서리
const Color  _stSubRowColor     = _text2;  // 하위 행 금액 색
const Color  _stSubLabelColor   = _text2;  // 하위 행 라벨 색
const double _stSubRowFontSize  = 12;      // 하위 행 라벨 크기
const double _stSubAmtFontSize  = 15;      // 하위 행 금액 크기
const Color  _stSubAmtUnitColor     = _text2; // 하위 행 " 원" 글씨 색
const double _stSubAmtUnitFontSize  = 13;    // 하위 행 " 원" 글씨 크기
const Color  _stSubtotalColor   = _teal;   // "소계" 글씨/금액 색
const double _stSubtotalFontSize = 14;     // "소계" 라벨 크기
const double _stSubtotalAmtFontSize = 18;  // "소계" 금액 크기
const Color  _stSubtotalUnitColor    = _teal; // "소계" " 원" 글씨 색
const double _stSubtotalUnitFontSize = 15;    // "소계" " 원" 글씨 크기
const Color  _stAmtUnitColor    = _text;   // " 원" 글씨 색(기본·기타 행)
// ── 6-2 추가. 미출금(23시 마감 경과) 상태 표시 ──
const Color  _stUnpaidColor   = _purple;  // "미출금" 배지/글씨 색 (퍼플)
const String _stUnpaidLabel   = '미출금';  // 미출금 상태 표시 문구
const int    _stCutoffHour    = 23;       // 출금 마감 시각(23시)

// ═══════════════════════════════════════════════════════════════════════
// 6-3. 출금내역 탭 (시작일 카드 등) (조정값)
// ═══════════════════════════════════════════════════════════════════════
const Color  _htCardBg          = _surface;    // 카드 배경색
const Color  _htCardBorder      = _cardBorder; // 카드 테두리 색
const double _htCardRadius      = 14;  // 카드 모서리
const double _htCardPadL = 16;  // 카드 안쪽 여백 왼
const double _htCardPadT = 14;  // 카드 안쪽 여백 위
const double _htCardPadR = 16;  // 카드 안쪽 여백 오른
const double _htCardPadB = 16;  // 카드 안쪽 여백 아래
const double _htGapTabToCard = 2; // 출금내역 탭 ↔ 날짜(시작일) 카드 갭
const Color  _htDateActiveColor = _teal;      // 날짜 선택됨 글씨·테두리
const Color  _htDateBorderColor = _elevated; // 미선택 테두리
const Color  _htDateHintColor   = _text;      // 미선택 글씨(힌트) 색
const double _htDateFontSize    = 12;  // 날짜 버튼 글씨 크기
const double _htDatePadH        = 10;  // 날짜 버튼 좌우 여백
const double _htDatePadV        = 5;   // 날짜 버튼 위아래 여백
const double _htDateRadius      = 7;   // 날짜 버튼 모서리
const Color  _htTildeColor      = _text;  // "~" 글씨 색
const double _htTildeFontSize   = 12;     // "~" 글씨 크기
const Color  _htBtnFilledBg     = _teal;     // 조회(채움) 배경색
const Color  _htBtnFilledText   = _appBg;    // 조회(채움) 글씨 색
const Color  _htBtnLineBorder   = _elevated; // 초기화(선) 테두리
const Color  _htBtnLineText     = _text;     // 초기화(선) 글씨 색
const double _htBtnFontSize     = 12;  // 버튼 글씨 크기
const double _htBtnHeight       = 28;  // 버튼 높이
const double _htBtnPadH         = 10;  // 버튼 좌우 여백
const double _htBtnRadius       = 7;   // 버튼 모서리
const String _htBtnSearchText   = '조회';   // 조회 버튼 글씨
const String _htBtnResetText    = '초기화';  // 초기화 버튼 글씨
const double _htRowFontSize     = 12;  // 행 라벨 글씨 크기
const double _htRowAmtFontSize  = 16;  // 행 금액 글씨 크기
const Color  _htRowLabelColor   = _text;  // 기본 라벨 색
const Color  _htRowPinkColor    = _pink;  // 세금/수수료/공제 라벨 색
const Color  _htToggleIconColor = _text2; // 토글 화살표 색
const double _htToggleIconSize  = 15;     // 토글 화살표 크기
const Color  _htSubBoxBg        = _appBg;     // 하위 박스 배경
const Color  _htSubBoxBorder    = _borderDim; // 하위 박스 테두리
const double _htSubBoxRadius    = 8;       // 하위 박스 모서리
const Color  _htSubRowColor     = _text2;  // 하위 행 금액 색
const Color  _htSubLabelColor   = _text2;  // 하위 행 라벨 색
const double _htSubRowFontSize  = 12;      // 하위 행 라벨 크기
const double _htSubAmtFontSize  = 15;      // 하위 행 금액 크기
const Color  _htSubAmtUnitColor     = _text2; // 하위 행 " 원" 글씨 색
const double _htSubAmtUnitFontSize  = 13;    // 하위 행 " 원" 글씨 크기
const Color  _htTotalColor      = _teal;   // "총 출금금액" 글씨/금액 색
const double _htTotalFontSize   = 14;      // 라벨 크기
const double _htTotalAmtFontSize = 18;     // 금액 크기
const Color  _htTotalUnitColor    = _teal; // "총 출금금액" " 원" 글씨 색
const double _htTotalUnitFontSize = 15;    // "총 출금금액" " 원" 글씨 크기
const Color  _htAmtUnitColor    = _text;   // " 원" 글씨 색(기본·기타 행)

// ═══════════════════════════════════════════════════════════════════════
// 7-1. 리스비 페이지 - 메인배경 + 알림/버튼 (조정값)
// ═══════════════════════════════════════════════════════════════════════
const double _menuLsPadV = 12;  // [7] 리스비 카드 내부 위아래 여백
const Color  _lpPanelColor       = _panel;     // 패널 배경색
const Color  _lpPanelBorderColor = _elevated;  // 패널 테두리 색
const double _lpPanelBorderAlpha = 1.0;        // 테두리 투명도 (1.0=솔리드)
const double _lpOuterPad         = 10;  // 패널 바깥 여백
const double _lpPanelRadius      = 24;  // 패널 모서리
// ── 헤더 아래 경계선 갭 ──
const double _lpGapHeaderToDiv = 0;  // 뒤로가기 ↔ 경계선 갭
const double _lpGapDivToCard   = 18;  // 경계선 ↔ 리스비 전체현황 카드 갭
const double _lpDivMarginH     = 15; // 경계선 좌우 여백(끝까지 안 붙음)
const Color  _lpEmptyIconColor  = _text2;  // 아이콘 색
const double _lpEmptyIconSize   = 48;      // 아이콘 크기
const Color  _lpEmptyTitleColor = _text2;  // 제목 색
const double _lpEmptyTitleFontSize = 14;   // 제목 크기
const Color  _lpEmptySubColor   = _text2;  // 부제 색
const double _lpEmptySubFontSize = 12;     // 부제 크기
const Color  _lpDueBoxColor     = _teal; // 박스 강조색
const double _lpDueBoxBgAlpha   = 0.06;    // 배경 투명도
const double _lpDueBoxBorderAlpha = 0.4;   // 테두리 투명도
const double _lpDueBoxRadius    = 12;      // 박스 모서리
const double _lpDueBoxBorderWidth = 1.5;   // 테두리 두께
const double _lpDueIconSize     = 22;      // 아이콘 크기
const double _lpDueTitleFontSize = 13;     // 제목 글씨 크기
const Color  _lpDueAmtColor     = _text2;  // 금액 안내 글씨 색
const double _lpDueAmtFontSize  = 12;      // 금액 안내 글씨 크기
const double _lpPayBtnHeight    = 46;      // 버튼 높이
const double _lpPayBtnRadius    = 22;      // 버튼 모서리
const double _lpPayBtnFontSize  = 14;      // 버튼 글씨 크기
const Color  _lpPaidBoxBg       = _chip;   // 박스 배경색
const Color  _lpPaidBorderColor = _teal;   // 테두리 색
const double _lpPaidBorderAlpha = 0.24;    // 테두리 투명도
const Color  _lpPaidTextColor   = _text2;  // 글씨 색
const double _lpPaidFontSize    = 12;      // 글씨 크기
const double _lpPaidRadius      = 22;      // 박스 모서리
const Color  _lpOverBoxColor    = _red;    // 박스 강조색
const double _lpOverBoxBgAlpha  = 0.06;    // 배경 투명도
const double _lpOverBoxBorderAlpha = 0.4;  // 테두리 투명도
const double _lpOverBoxRadius   = 12;      // 박스 모서리
const double _lpOverBoxBorderWidth = 1.5;  // 테두리 두께
const double _lpOverIconSize    = 22;      // 아이콘 크기
const double _lpOverTitleFontSize = 13;    // 제목 글씨 크기
const Color  _lpOverSubColor    = _text2;  // 부제 글씨 색
const double _lpOverSubFontSize = 12;      // 부제 글씨 크기

// ═══════════════════════════════════════════════════════════════════════
// 7-2. 리스비 전체현황 카드 (조정값)
// ═══════════════════════════════════════════════════════════════════════
const Color  _lsCardBg          = _surface;   // 카드 배경색
const Color  _lsCardBorderNormal = _cardBorder; // 일반 테두리
const Color  _lsCardBorderAlert = _amber;     // 알림 시 테두리 색
const double _lsCardAlertBorderAlpha = 0.40;  // 알림 테두리 투명도
const double _lsCardRadius      = 14;  // 카드 모서리
const double _lsCardPadL = 16;  // 안쪽 여백 왼
const double _lsCardPadT = 14;  // 안쪽 여백 위
const double _lsCardPadR = 16;  // 안쪽 여백 오른
const double _lsCardPadB = 16;  // 안쪽 여백 아래
const Color  _lsHeadIconColor   = _teal;   // 자전거 아이콘 색
const double _lsHeadIconSize    = 16;      // 아이콘 크기
const Color  _lsHeadTitleColor  = _text;   // "리스비 전체 현황" 글씨 색
const double _lsHeadTitleFontSize = 13;    // 제목 글씨 크기
const Color  _lsTypeChipBg      = _chip;   // 타입 칩 배경
const Color  _lsTypeChipBorder  = _cardBorder; // 타입 칩 테두리
const Color  _lsTypeChipText    = _teal;   // 타입 칩 글씨 색
const double _lsTypeChipFontSize = 11;     // 타입 칩 글씨 크기
const Color  _lsInfoLabelColor  = _text;   // 정보 라벨 색
const Color  _lsInfoValueColor  = _text;   // 정보 값 색
const Color  _lsInfoPinkColor   = _amber;  // "출금 시 자동공제" 값 색
const double _lsInfoFontSize    = 12;      // 정보 글씨 크기
const Color  _lsPayMethodLabelColor    = _amber; // "납부 방식" 라벨 글씨 색
const double _lsPayMethodLabelFontSize = 13;     // "납부 방식" 라벨 글씨 크기
const Color  _lsProgressColor   = _amber;  // "진행 현황" 글씨·숫자 색
const double _lsProgressLabelFontSize = 12; // "진행 현황" 라벨 크기
const double _lsProgressNumFontSize = 16;  // 완료 숫자 크기
const double _lsProgressTotalFontSize = 17; // "/ 총" 숫자 크기
const Color  _lsBarFillColor    = _teal;   // 진행바 채움 색
const Color  _lsBarTrackColor   = _chip;   // 진행바 배경 색
const double _lsBarHeight       = 6;       // 진행바 높이
const double _lsBarRadius       = 4;       // 진행바 모서리
const Color  _lsPaidLabelColor  = _amber;  // "납부 완료" 라벨·금액 색
const double _lsPaidFontSize    = 12;      // "납부 완료" 글씨 크기
const Color  _lsRemainColor     = _teal;   // "잔여 금액" 라벨·금액 색
const double _lsRemainFontSize  = 12;      // "잔여 금액" 글씨 크기

// ═══════════════════════════════════════════════════════════════════════
// 8-1. 설정 페이지 - 메인배경 + 내 정보 헤더 (조정값)
// ═══════════════════════════════════════════════════════════════════════
const double _menuSpPadV = 12;  // [8] 설정 카드 내부 위아래 여백
const Color  _spPanelColor       = _panel;     // 패널 배경색
const Color  _spPanelBorderColor = _elevated;  // 패널 테두리 색
const double _spPanelBorderAlpha = 1.0;        // 테두리 투명도 (1.0=솔리드)
const double _spOuterPad         = 10;  // 패널 바깥 여백
const double _spPanelRadius      = 24;  // 패널 모서리
// ── 헤더 아래 경계선 갭 ──
const double _spGapHeaderToDiv = 0;  // 뒤로가기 ↔ 경계선 갭
const double _spGapDivToInfo   = 0;  // 경계선 ↔ 내 정보 갭
const double _spDivMarginH     = 15; // 경계선 좌우 여백(끝까지 안 붙음)
const double _spListPadL = 10;  // 리스트 안쪽 여백 왼
const double _spListPadT = 0;   // 리스트 안쪽 위 여백(경계선↔내정보 갭은 _spGapDivToInfo로 조정)
const double _spListPadR = 10;  // 리스트 안쪽 여백 오른
const double _spListPadB = 10;  // 리스트 안쪽 여백 아래
const Color  _spHeadIconColor   = _teal;   // 사람 아이콘 색
const double _spHeadIconSize    = 20;      // 아이콘 크기
const Color  _spHeadTitleColor  = _text;   // "내 정보" 글씨 색
const double _spHeadTitleFontSize = 15;    // "내 정보" 글씨 크기

// ═══════════════════════════════════════════════════════════════════════
// 8-2. 설정 - 이름 카드 (정보 행) (조정값)
// ═══════════════════════════════════════════════════════════════════════
const Color  _siCardBg          = _surface;    // 카드 배경색
const Color  _siCardBorder      = _cardBorder; // 카드 테두리 색
const double _siCardRadius      = 14;  // 카드 모서리
const double _siCardPadH        = 10;  // 카드 좌우 안쪽 여백
const Color  _siLabelColor      = _text;  // 라벨(왼쪽) 글씨 색
const double _siLabelFontSize   = 13;      // 라벨 글씨 크기
const Color  _siValueColor      = _text2;   // 값(오른쪽) 글씨 색
const double _siValueFontSize   = 13;      // 값 글씨 크기
const double _siRowPadV         = 6;      // 행 위아래 여백
const Color  _siDividerColor    = _borderDim; // 행 구분선 색
const double _siLabelGap        = 12;      // 라벨-값 사이 간격
// ── 값 표시 배경박스 (각 값을 감싸는 칸) ──
const Color  _siBoxBg           = _appBg;     // 값 박스 배경색
const Color  _siBoxBorder       = _borderDim; // 값 박스 테두리 색
const double _siBoxRadius       = 8;          // 값 박스 모서리
const double _siBoxPadH         = 10;         // 값 박스 좌우 여백
const double _siBoxPadV         = 6;          // 값 박스 위아래 여백
const double _siAccountIndent   = 64;         // 계좌번호(둘째 줄) 들여쓰기
const Color  _siSoonColor       = _text2;     // "준비중" 글씨 색
const String _siSoonText        = '준비중';    // 미구현 항목 표시 문구

// ═══════════════════════════════════════════════════════════════════════
// 9. FAB & 1:1 상담 풍선창 (조정값)
// ═══════════════════════════════════════════════════════════════════════
const Color  _fabBg          = _surface;  // FAB 배경색
const Color  _fabIconColor   = _teal;     // FAB 아이콘 색
const double _fabSizeV       = 64;   // FAB 크기
const double _fabIconSize    = 40;   // FAB 아이콘 크기
const double _fabRightV      = 16;   // FAB 오른쪽 여백
const double _fabMarginBottomV = 16; // FAB 아래쪽 여백
const Color  _fabBadgeColor  = _red;      // 안읽음 빨간점 색
const double _fabBadgeSize   = 14;   // 빨간점 크기
const Color  _blBg           = _surface;  // 풍선창 배경색
const Color  _blBorderColor  = _elevated;     // 풍선창 테두리 색
const double _blBorderAlpha  = 2;       // 테두리 투명도
const double _blWidth        = 280;  // 풍선창 너비
const double _blRadius       = 14;   // 풍선창 모서리
const double _blMaxHeight    = 420;  // 풍선창 최대 높이
const Color  _blHeadIconColor = _teal;   // 헤더 아이콘 색
const double _blHeadIconSize  = 20;      // 헤더 아이콘 크기
const Color  _blHeadTitleColor = _text;  // "관리자 1:1 상담" 글씨 색
const double _blHeadTitleFontSize = 13;  // 헤더 글씨 크기
const Color  _blCloseColor   = _pink;    // 닫기(X) 색
const double _blCloseSize    = 17;       // 닫기 크기
const Color  _blDividerColor = _elevated;    // 헤더 아래 구분선 색
const double _blDivMarginH   = 12;       // 헤더 구분선 좌우 여백(끝까지 안 붙음)
const Color  _blEmptyColor   = _text2;   // "상담 내용을 입력해 보세요" 색
const double _blEmptyFontSize = 11;      // 안내 글씨 크기
const Color  _blRiderBubbleBg = _teal;   // 내(라이더) 말풍선 배경(틴트)
const double _blRiderBubbleAlpha = 0.18; // 내 말풍선 배경 투명도
const double _blRiderBorderAlpha = 0.35; // 내 말풍선 테두리 투명도
const Color  _blAdminBubbleBg = _chip;   // 관리자 말풍선 배경
const Color  _blAdminBorderColor = _borderDim; // 관리자 말풍선 테두리
const Color  _blAdminTagColor = _teal;   // "관리자" 표시 색
const double _blAdminTagFontSize = 9;    // "관리자" 글씨 크기
const Color  _blMsgColor     = _text;    // 메시지 글씨 색
const double _blMsgFontSize  = 11;       // 메시지 글씨 크기
const double _blMsgHeight    = 1.4;      // 메시지 줄간격
const Color  _blTimeColor    = _text2;   // 시간 글씨 색
const double _blTimeFontSize = 9;        // 시간 글씨 크기
const double _blBubbleMaxWidth = 200;    // 말풍선 최대 너비
const Color  _blInputBg      = _chip;    // 입력창 배경
const Color  _blInputBorderColor = _teal; // 입력창 테두리 색
const double _blInputBorderAlpha = 0.18;  // 입력창 테두리 투명도
const Color  _blInputTextColor = _text;  // 입력 글씨 색
const double _blInputFontSize = 12;      // 입력 글씨 크기
const Color  _blHintColor    = _text2;   // 힌트 글씨 색
const double _blInputRadius  = 8;        // 입력창 모서리
const Color  _blSendBg       = _teal;    // 전송 버튼 배경(틴트)
const double _blSendBgAlpha  = 0.18;     // 전송 배경 투명도
const Color  _blSendIconColor = _teal;   // 전송 아이콘 색
const double _blSendSize     = 40;       // 전송 버튼 크기
const double _blSendIconSize = 24;       // 전송 아이콘 크기
const String _blHintText     = '메시지 입력...';  // 입력창 힌트

// ═══════════════════════════════════════════════════════════════════════
// 10. 공통 위젯 · 로직
// ═══════════════════════════════════════════════════════════════════════
String _fmt(double v) => NumberFormat('#,###').format(v.abs());

// 콤마 (₩ 없음)
String _comma(num v) {
  final s = v.round().abs().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}
String _won(int v) => '${_comma(v)} 원';

void _showInfoDialog(BuildContext context, String msg) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _teal.withValues(alpha: 0.4), width: 1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(msg,
              style: const TextStyle(
                  color: _teal, fontSize: 15, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GlassShineButton(
              label: "확인",
              onPressed: () => Navigator.pop(ctx),
              accent: _teal,
              pill: true,
              height: 46,
              fontSize: 14,
            ),
          ),
        ]),
      ),
    ),
  );
}

// 서브 페이지 공통 헤더 (뒤로가기 + 제목)
Widget _pageHeader(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 16, 0),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: _text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        Text(title,
            style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w700)),
      ]),
    );

// 상태 배지 (출금가능 · 입금대기 등)
Widget _statusBadge(String label, Color c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
    );

// ═══════════════════════════════════════════════════════════════════════
// 4. 차트 데이터 모델
// ═══════════════════════════════════════════════════════════════════════
class _PeriodData {
  final List<String> labels;
  final List<double> series; // 실제 금액(원)
  final int total;
  final double delta;
  const _PeriodData({
    required this.labels,
    required this.series,
    required this.total,
    required this.delta,
  });
}

// ═══════════════════════════════════════════════════════════════════════
// DriverPage – 메인
// ═══════════════════════════════════════════════════════════════════════
class DriverPage extends StatefulWidget {
  const DriverPage({super.key});
  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  // ── 차트/기간/목표 ──
  int _period = 0; // 0=일간, 1=주간, 2=월간
  static const _periodName = ['일간', '주간', '월간'];
  static const _periodCompare = ['전일 대비', '전주 대비', '전월 대비'];
  static const _periodColor = [_teal, _pink, _purple];
  final List<int> _targets = [150000, 800000, 3000000];

  Map<int, _PeriodData> _data = {
    0: const _PeriodData(labels: [], series: [], total: 0, delta: 0),
    1: const _PeriodData(labels: [], series: [], total: 0, delta: 0),
    2: const _PeriodData(labels: [], series: [], total: 0, delta: 0),
  };

  // ── 출금신청 상태 ──
  bool _adminUploaded    = false;
  bool _withdrawRequested = false;
  List<Map<String, dynamic>> _unpaidItems = [];
  double _unpaidTotal    = 0;
  bool   _hasDailyLease  = false;
  double _leaseDailyAmt  = 0;

  // ── 사용자/공지/상태 ──
  String _riderName  = '';
  String _noticeText = '';
  bool   _isAppOn    = true;
  bool   _appLoaded  = false;

  // ── 1:1 상담 풍선창 ──
  bool _showBalloon    = false;
  bool _balloonSending = false;
  final TextEditingController _balloonCtrl    = TextEditingController();
  final ScrollController      _chatScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkAppStatus();
    _loadUser();
    _loadNotice();
    _loadWithdrawState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLeaseDue());
  }

  @override
  void dispose() {
    _balloonCtrl.dispose();
    _chatScrollCtrl.dispose();
    super.dispose();
  }

  // ── 데이터 로드 ─────────────────────────────────────────────────────
  Future<void> _checkAppStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('system_settings').doc('app_status').get();
      if (mounted) {
        setState(() {
          _isAppOn = doc.data()?['isAppOn'] ?? true;
          _appLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _appLoaded = true);
    }
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) setState(() => _riderName = doc.data()?['name'] ?? '');
    } catch (_) {}
  }

  Future<void> _loadNotice() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('system_settings').doc('notice').get();
      if (!doc.exists) return;
      final content   = doc.data()?['content']  as String? ?? '';
      final isVisible = doc.data()?['isVisible'] as bool?   ?? false;
      if (mounted) setState(() => _noticeText = isVisible ? content : '');
    } catch (_) {}
  }

  Future<void> _loadWithdrawState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).get();
      _riderName = userDoc.data()?['name'] ?? _riderName;

      final leaseType = userDoc.data()?['leaseType']      as String? ?? '';
      final leaseAmt  = userDoc.data()?['leaseAmount']    as int?    ?? 0;
      final startStr  = userDoc.data()?['leaseStartDate'] as String? ?? '';
      final lastStr   = userDoc.data()?['leaseLastDate']  as String? ?? '';
      if (leaseType == 'daily' && leaseAmt > 0) {
        final now   = DateTime.now();
        final start = DateTime.tryParse(startStr);
        final last  = DateTime.tryParse(lastStr);
        if (start != null && last != null &&
            !now.isBefore(DateTime(start.year, start.month, start.day)) &&
            !now.isAfter(DateTime(last.year, last.month, last.day))) {
          _hasDailyLease = true;
          _leaseDailyAmt = leaseAmt.toDouble();
        }
      }

      final pending = await FirebaseFirestore.instance
          .collection('withdrawal_requests')
          .where('uid',    isEqualTo: user.uid)
          .where('status', isEqualTo: '요청대기')
          .limit(1).get();
      final requested = pending.docs.isNotEmpty;

      List<Map<String, dynamic>> items = [];
      double total = 0;
      if (!requested) {
        final doc = await FirebaseFirestore.instance
            .collection('unpaid_balance').doc(user.uid).get();
        if (doc.exists) {
          final raw = doc.data()?['items'] as List<dynamic>? ?? [];
          items = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          total = (doc.data()?['totalAmount'] as num?)?.toDouble() ?? 0;
        }
      }

      if (mounted) {
        setState(() {
          _withdrawRequested = requested;
          _unpaidItems       = items;
          _unpaidTotal       = total;
          _adminUploaded     = items.isNotEmpty;
        });
      }
      _loadChartData();
    } catch (_) {}
  }

  Future<void> _loadChartData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final Map<String, double> byDay = {};

      void addItems(List<dynamic> items, double leaseDeduction) {
        final perDayLease =
            items.isNotEmpty ? leaseDeduction / items.length : 0.0;
        for (final raw in items) {
          final it = Map<String, dynamic>.from(raw as Map);
          final date = it['date'] as String? ?? '';
          if (date.length < 10) continue;
          double n(String k) => (it[k] as num?)?.toDouble() ?? 0;
          final net = n('deliveryFee') +
              n('promoTotal') -
              n('tax') -
              (n('withdrawalFee') + n('commissionAmt')) -
              n('insuranceFee') -
              perDayLease;
          byDay[date] = (byDay[date] ?? 0) + net;
        }
      }

      final logs = await FirebaseFirestore.instance
          .collection('admin_settlement_logs')
          .where('uid', isEqualTo: user.uid)
          .where('status', isEqualTo: '지급완료')
          .get();
      for (final doc in logs.docs) {
        final d = doc.data();
        addItems((d['items'] as List<dynamic>?) ?? [],
            (d['leaseDeduction'] as num?)?.toDouble() ?? 0);
      }
      final leaseDeduct =
          (_hasDailyLease ? _unpaidItems.length : 0) * _leaseDailyAmt;
      addItems(_unpaidItems, leaseDeduct);

      const wd = {1: '월', 2: '화', 3: '수', 4: '목', 5: '금', 6: '토', 7: '일'};

      _PeriodData buildPeriod(List<double> series, List<String> labels) {
        final nonZero = series.where((v) => v != 0).toList();
        final total = nonZero.isNotEmpty
            ? nonZero.last
            : (series.isNotEmpty ? series.last : 0.0);
        final prev = nonZero.length >= 2 ? nonZero[nonZero.length - 2] : 0.0;
        final delta = prev != 0 ? (total - prev) / prev * 100 : 0.0;
        return _PeriodData(
            labels: labels, series: series, total: total.round(), delta: delta);
      }

      String dk(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final Map<String, double> byWeek = {};
      final Map<String, double> byMonth = {};
      for (final d in byDay.keys) {
        final dt = DateTime.tryParse(d);
        if (dt == null) continue;
        final back = (dt.weekday - DateTime.wednesday + 7) % 7;
        final ws = DateTime(dt.year, dt.month, dt.day).subtract(Duration(days: back));
        byWeek[dk(ws)] = (byWeek[dk(ws)] ?? 0) + byDay[d]!;
        byMonth[d.substring(0, 7)] = (byMonth[d.substring(0, 7)] ?? 0) + byDay[d]!;
      }

      final dayKeys = byDay.keys.toList()..sort();
      final lastDay = dayKeys.isNotEmpty
          ? (DateTime.tryParse(dayKeys.last) ?? today)
          : today;
      final dEnd = DateTime(lastDay.year, lastDay.month, lastDay.day);
      final dDays = List.generate(7, (i) => dEnd.subtract(Duration(days: 6 - i)));
      final daily = buildPeriod(
        dDays.map((d) => byDay[dk(d)] ?? 0).toList(),
        dDays.map((d) => wd[d.weekday] ?? '').toList(),
      );

      final back = (today.weekday - DateTime.wednesday + 7) % 7;
      final curWed = today.subtract(Duration(days: back));
      final weeks =
          List.generate(7, (i) => curWed.subtract(Duration(days: (6 - i) * 7)));
      final weekly = buildPeriod(
        weeks.map((w) => byWeek[dk(w)] ?? 0).toList(),
        weeks.map((w) => '${w.month}/${w.day}').toList(),
      );

      final months =
          List.generate(7, (i) => DateTime(today.year, today.month - (6 - i), 1));
      final monthly = buildPeriod(
        months.map((m) => byMonth[DateFormat('yyyy-MM').format(m)] ?? 0).toList(),
        months.map((m) => '${m.month}월').toList(),
      );

      if (mounted) {
        setState(() {
          _data = {0: daily, 1: weekly, 2: monthly};
        });
      }
    } catch (_) {}
  }

  Future<void> _checkLeaseDue() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final snap = await FirebaseFirestore.instance
          .collection('lease_payments')
          .where('uid',     isEqualTo: user.uid)
          .where('dueDate', isEqualTo: today)
          .where('isPaid',  isEqualTo: false).get();
      if (snap.docs.isNotEmpty) {
        final d    = snap.docs.first.data();
        final type = (d['leaseType'] as String?) ?? '';
        if (type == 'daily') return;
        final amt = d['amount'] as int? ?? 0;
        final cyc = d['cycle']  as int? ?? 0;
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _orange.withValues(alpha: 0.5), width: 1)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Row(children: [
                    Icon(Icons.directions_bike, color: _orange, size: 20),
                    SizedBox(width: 8),
                    Text("리스비 납기일 안내",
                        style: TextStyle(color: _orange, fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 4),
                  Divider(color: _orange.withValues(alpha: 0.25), height: 16),
                  Text(
                      "오늘은 $cyc회차 납기일입니다\n${NumberFormat('#,###').format(amt)}원 납부 부탁드립니다.",
                      style: const TextStyle(color: _text2, fontSize: 13, height: 1.7),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: GlassShineButton(
                      label: "확인",
                      onPressed: () => Navigator.pop(ctx),
                      accent: _teal,
                      pill: true,
                      height: 46,
                      fontSize: 14,
                    ),
                  ),
                ]),
              ),
            ),
          );
        });
      }
    } catch (_) {}
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  // ── build: 1.전체배경 · 2.메인배경 · 3.~9. 순서 ──────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_appLoaded) {
      return const Scaffold(
        backgroundColor: _bgScaffold,
        body: Center(child: CircularProgressIndicator(color: _teal)),
      );
    }
    if (!_isAppOn) return _buildMaintenanceScreen();

    final uid         = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final d           = _data[_period]!;

    // ── 1. 전체 배경 ──────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: _bgScaffold,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(children: [
          // ── 2. 메인 배경 ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(_panelOuterPad),
            child: Container(
              decoration: BoxDecoration(
                color: _panelColor,
                borderRadius: BorderRadius.circular(_panelRadius),
                border: Border.all(
                    color: _panelBorderColor.withValues(alpha: _panelBorderAlpha),
                    width: _panelBorderWidth),
                boxShadow: _panelShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_panelRadius),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      _panelPadL, _panelPadT, _panelPadR, _panelPadB),
                  children: [
                    // ── 3. 안녕하세요 ────────────────────────────────
                    _greeting(),
                    const SizedBox(height: _gapGreetToChart),
                    // ── 4. 차트 카드 ─────────────────────────────────
                    _chartCard(d),
                    const SizedBox(height: _gapChartToNotice),
                    // ── 5. 공지사항 ──────────────────────────────────
                    _notice(),
                    const SizedBox(height: _gapNoticeToMenu),
                    // ── 6. 정산내역 카드 ──────────────────────────────
                    _menuCard('정산 내역', Icons.request_quote, _teal, () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => _HistoryPage(uid: uid)));
                    }, padV: _menuStPadV),
                    const SizedBox(height: 10),
                    // ── 7. 리스비 카드 ───────────────────────────────
                    _leaseMenuCard(uid),
                    const SizedBox(height: 10),
                    // ── 8. 설정 카드 ─────────────────────────────────
                    _menuCard('설정', Icons.settings, _purple, () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => _SettingsPage(uid: uid)));
                    }, padV: _menuSpPadV),
                  ],
                ),
              ),
            ),
          ),
          _buildFABArea(uid, bottomInset),
        ]),
      ),
    );
  }

  // ── 3. 인사 ─────────────────────────────────────────────────────────
  Widget _greeting() => Padding(
        padding: const EdgeInsets.symmetric(vertical: _greetVPad),
        child: Row(children: [
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
            child: RichText(
              text: TextSpan(children: [
                const TextSpan(
                    text: _greetHelloText,
                    style: TextStyle(
                        color: _greetHelloColor,
                        fontSize: _greetHelloFontSize,
                        fontWeight: FontWeight.w700)),
                TextSpan(
                    text: _riderName.isNotEmpty ? _riderName : _greetNameFallback,
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
              ]),
            ),
          ),
          GlassShineButton(
            onPressed: _handleLogout,
            icon: Icons.logout_rounded,
            accent: _purple,
            textColor: _purple,
            width: _greetLogoutBoxSize,
            height: _greetLogoutBoxSize,
            radius: _greetLogoutRadius,
            fontSize: _greetLogoutIconSize - 3,
          ),
        ]),
      );


  // 미출금 항목 하루치 소계 (정산내역 카드 맨 아래 "소계"와 동일한 계산식)
  //  소계 = 배달수수료 + 지원금 − 세금 − (출금수수료+협력사수수료) − 시간제보험 − 리스비(일)
  double _itemSubtotal(Map<String, dynamic> it) {
    double n(String k) => (it[k] as num?)?.toDouble() ?? 0;
    final dailyLease = _hasDailyLease ? _leaseDailyAmt : 0.0;
    return n('deliveryFee') +
        n('promoTotal') -
        n('tax') -
        (n('withdrawalFee') + n('commissionAmt')) -
        n('insuranceFee') -
        dailyLease;
  }

  // ── 4. 차트 카드 ────────────────────────────────────────────────────
  Widget _chartCard(_PeriodData d) {
    final accent = _periodColor[_period];
    final up = d.delta >= 0;
    final isDaily = _period == 0;
    final leaseDeduct =
        (_hasDailyLease ? _unpaidItems.length : 0) * _leaseDailyAmt;
    final withdrawable = _unpaidTotal - leaseDeduct;

    // ── 차트 큰 금액: 미출금(업로드분)이 있으면 "가장 마지막 날 소계 하나", 없으면 기존 집계값 ──
    final hasUnpaid = _adminUploaded && _unpaidItems.isNotEmpty;
    final headlineAmount =
        hasUnpaid ? _itemSubtotal(_unpaidItems.last).round() : d.total;
    final pct = (headlineAmount / _targets[_period]).clamp(0.0, 1.0);

    // ── 출금가능금액 줄: 업로드됐고 + 아직 신청 안 했을 때만 (신청하면 줄 전체 사라짐) ──
    final showWithdrawRow = isDaily && _adminUploaded && !_withdrawRequested;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          _chartCardPadL, _chartCardPadT, _chartCardPadR, _chartCardPadB),
      decoration: BoxDecoration(
        color: _chartCardBg,
        borderRadius: BorderRadius.circular(_chartCardRadius),
        border: Border.all(color: _chartCardBorder, width: _chartCardBorderWidth),
        boxShadow: _chartCardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _miniToggle(),
          const Spacer(),
          _targetButton(),
        ]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(left: _chartTotalLeftPad),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: _comma(headlineAmount),
                      style: const TextStyle(
                          color: _chartTotalColor,
                          fontSize: _chartTotalFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: _chartTotalLetterSp),
                    ),
                    const TextSpan(
                      text: ' 원',
                      style: TextStyle(
                          color: _chartTotalUnitColor,
                          fontSize: _chartTotalUnitFontSize,
                          fontWeight: FontWeight.w400),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Icon(up ? Icons.trending_up : Icons.trending_down,
                    size: _chartDeltaIconSize, color: accent),
                const SizedBox(width: _chartDeltaGap),
                Text('${up ? '+' : ''}${d.delta.toStringAsFixed(0)}%',
                    style: TextStyle(
                        color: accent,
                        fontSize: _chartDeltaFontSize,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: _chartCompareGap),
                Text(_periodCompare[_period],
                    style: TextStyle(color: accent, fontSize: _chartCompareFontSize)),
              ]),
            ]),
          ),
          const SizedBox(width: 12),
          SizedBox(
              width: _ringBoxSize,
              height: _ringBoxSize,
              child: _ringGauge(pct)),
        ]),
        const SizedBox(height: 16),
        _chart(d),
        if (showWithdrawRow) ...[
          const SizedBox(height: 14),
          Container(height: 1, color: _elevated.withValues(alpha: _withdrawDividerAlpha)),
          const SizedBox(height: 12),
          _WithdrawFrame(amount: withdrawable.round(), onWithdraw: _onWithdrawTap),
        ],
      ]),
    );
  }

  Widget _miniToggle() => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final sel = _period == i;
          final c = _periodColor[i];
          return GestureDetector(
            onTap: () => setState(() => _period = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: _togGap),
              padding: const EdgeInsets.symmetric(
                  horizontal: _togPadH, vertical: _togPadV),
              decoration: BoxDecoration(
                color: sel ? c.withValues(alpha: _togSelAlpha) : Colors.transparent,
                borderRadius: BorderRadius.circular(_togRadius),
                border: Border.all(
                    color: sel
                        ? c.withValues(alpha: _togSelBorderAlpha)
                        : _togUnselBorder.withValues(alpha: _togUnselBorderAlpha)),
              ),
              child: Text(_periodName[i],
                  style: TextStyle(
                      color: sel ? c : _togUnselColor,
                      fontSize: _togFontSize,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ),
          );
        }),
      );

  Widget _targetButton() {
    final c = _periodColor[_period]; // 일간/주간/월간 토글 색을 그대로 따라감
    return GestureDetector(
      onTap: _editTarget,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: _targetPadH, vertical: _targetPadV),
        decoration: BoxDecoration(
          color: c.withValues(alpha: _targetBgAlpha),
          borderRadius: BorderRadius.circular(_targetRadius),
          border: Border.all(color: c.withValues(alpha: _targetBorderAlpha)),
        ),
        child: Text('목표 ${_won(_targets[_period])}',
            style: TextStyle(
                color: c,
                fontSize: _targetFontSize,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _onWithdrawTap() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: _wdlgMaxWidth),
          padding: const EdgeInsets.fromLTRB(
              _wdlgPadL, _wdlgPadT, _wdlgPadR, _wdlgPadB),
          decoration: BoxDecoration(
            color: _wdlgBg,
            borderRadius: BorderRadius.circular(_wdlgRadius),
            border: Border.all(
                color: _wdlgBorderColor.withValues(alpha: _wdlgBorderAlpha),
                width: _wdlgBorderWidth),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(_wdlgTitleText,
                style: TextStyle(
                    color: _wdlgTitleColor,
                    fontSize: _wdlgTitleFontSize,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: _wdlgTitleGap),
            Row(children: [
              Expanded(
                child: GlassShineButton(
                  label: "취소",
                  onPressed: () => Navigator.pop(ctx),
                  accent: _text2,
                  textColor: _text2,
                  height: 46,
                  radius: _wdlgBtnRadius,
                  fontSize: _wdlgCancelFontSize,
                ),
              ),
              const SizedBox(width: _wdlgBtnGap),
              Expanded(
                child: GlassShineButton(
                  label: "확인",
                  onPressed: () {
                    Navigator.pop(ctx);
                    _confirmWithdraw();
                  },
                  accent: _teal,
                  height: 46,
                  radius: _wdlgBtnRadius,
                  fontSize: _wdlgOkFontSize,
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  double _sumItems(String f) =>
      _unpaidItems.fold(0.0, (s, e) => s + ((e[f] as num?)?.toDouble() ?? 0));

  Future<void> _confirmWithdraw() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_unpaidItems.isEmpty) {
      _showInfoDialog(context, "출금 가능한 내역이 없습니다.");
      return;
    }

    final leaseDays   = _hasDailyLease ? _unpaidItems.length : 0;
    final leaseDeduct = leaseDays * _leaseDailyAmt;
    final finalTotal  = _unpaidTotal - leaseDeduct;
    if (finalTotal < 10000) {
      _showInfoDialog(context, "최종 출금금액이 너무 적습니다.");
      return;
    }

    final tDel  = _sumItems('deliveryFee');
    final tMis  = _sumItems('missionFee');
    final tPOrd = _sumItems('perOrderAmount');
    final tRng  = _sumItems('rangeAmount');
    final tTax  = _sumItems('tax');
    final tEmp  = _sumItems('employmentTax');
    final tAcc  = _sumItems('accidentTax');
    final tInc  = _sumItems('incomeTax');
    final tComm = _sumItems('commissionAmt');
    final tIns  = _sumItems('insuranceFee');
    final tWd   = _sumItems('withdrawalFee');

    final dates     = _unpaidItems.map((e) => e['date'] as String? ?? '').join(', ');
    final datesList = _unpaidItems.map((e) => e['date']).toList();
    final lastDate  = datesList.isNotEmpty ? datesList.last as String : '';

    final msg =
        "출금날짜: $dates\n"
        "배달수수료(세전): ${_fmt(tDel)}원\n"
        "미션금액: ${_fmt(tMis)}원\n"
        "건당프로모션: ${_fmt(tPOrd)}원\n"
        "구간프로모션: ${_fmt(tRng)}원\n"
        "세금: ${_fmt(tTax)}원\n"
        "고용보험: ${_fmt(tEmp)}원\n"
        "산재보험: ${_fmt(tAcc)}원\n"
        "원천세: ${_fmt(tInc)}원\n"
        "협력사수수료(합산): ${_fmt(tComm)}원\n"
        "시간제보험: ${_fmt(tIns)}원\n"
        "출금수수료: ${_fmt(tWd)}원\n"
        "${leaseDeduct > 0 ? '리스비(일): ${_fmt(leaseDeduct)}원\n' : ''}"
        "최종배달수수료: ${_fmt(finalTotal)}원\n"
        "최종출금금액: ${_fmt(finalTotal)}원";

    try {
      await FirebaseFirestore.instance.collection('withdrawal_requests').add({
        'uid':            user.uid,
        'riderName':      _riderName.isNotEmpty ? _riderName : "라이더님",
        'date':           lastDate,
        'dates':          datesList,
        'amount':         finalTotal,
        'totalAmount':    _unpaidTotal,
        'leaseDeduction': leaseDeduct,
        'items':          _unpaidItems,
        'message':        msg,
        'status':         '요청대기',
        'timestamp':      FieldValue.serverTimestamp(),
      });
      // 신청 완료 → 출금신청 줄 사라짐 (별도 확인창 없음)
      if (mounted) setState(() => _withdrawRequested = true);
    } catch (_) {
      if (mounted) _showInfoDialog(context, "출금 신청 실패. 다시 시도해 주세요.");
    }
  }

  Future<void> _editTarget() async {
    final ctrl = TextEditingController(text: _targets[_period].toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _tgtDlgBg,
        titlePadding: const EdgeInsets.fromLTRB(24, _tgtDlgPadTop, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, _tgtDlgPadBottom),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_tgtDlgRadius),
            side: const BorderSide(
                color: _tgtDlgBorderColor, width: _tgtDlgBorderWidth)),
        title: Text('${_periodName[_period]} 목표 금액',
            style: const TextStyle(
                color: _tgtDlgTitleColor,
                fontSize: _tgtDlgTitleFontSize,
                fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.right, // 금액을 " 원" 옆(오른쪽)에 붙임
          style: const TextStyle(
              color: _tgtDlgInputColor, fontSize: _tgtDlgInputFontSize),
          cursorColor: _tgtDlgCursorColor,
          decoration: const InputDecoration(
            suffixText: ' 원',
            suffixStyle: TextStyle(
                color: _tgtDlgUnitColor, fontSize: _tgtDlgInputFontSize),
            hintText: _tgtDlgHintText,
            hintStyle: TextStyle(color: _tgtDlgHintColor),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _tgtDlgInputLineColor)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _tgtDlgFocusColor)),
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
              final v = int.tryParse(ctrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
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
      setState(() => _targets[_period] = result);
    }
  }

  Widget _ringGauge(double pct) {
    final tipColor = _ringColorFor(pct);
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
            size: const Size(_ringBoxSize, _ringBoxSize),
            painter: _RingGaugePainter(pct)),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${(pct * 100).round()}%',
              style: TextStyle(
                  color: tipColor,
                  fontSize: _ringPctFontSize,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 1),
          Text('달성', style: TextStyle(color: tipColor, fontSize: _ringLabelFontSize)),
        ]),
      ],
    );
  }

  Widget _chart(_PeriodData d) => Column(children: [
        SizedBox(
          height: _chartHeight,
          width: double.infinity,
          child: CustomPaint(painter: _AreaChartPainter(d.series)),
        ),
        const SizedBox(height: _chartLabelGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: d.labels
              .map((l) => Text(l,
                  style: const TextStyle(
                      color: _chartLabelColor, fontSize: _chartLabelFontSize)))
              .toList(),
        ),
      ]);

  // ── 5. 공지사항 ──────────────────────────────────────────────────────
  Widget _notice() {
    final lines = _noticeText.trim().isEmpty
        ? <String>[]
        : _noticeText.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.campaign_outlined,
              color: _ntcIconColor, size: _ntcIconSize),
          const SizedBox(width: _ntcHeaderGap),
          const Text('공지사항',
              style: TextStyle(
                  color: _ntcTitleColor,
                  fontSize: _ntcTitleFontSize,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: _showNoticeDialog,
            child: const Row(children: [
              Text('더보기',
                  style: TextStyle(color: _ntcMoreColor, fontSize: _ntcMoreFontSize)),
              Icon(Icons.chevron_right, color: _ntcMoreColor, size: _ntcMoreIconSize),
            ]),
          ),
        ]),
        const SizedBox(height: _ntcHeaderBottomGap),
        if (lines.isEmpty)
          const Text(_ntcEmptyText,
              style: TextStyle(color: _ntcEmptyColor, fontSize: _ntcEmptyFontSize))
        else
          ...lines.take(_ntcPreviewCount).map((t) => Padding(
                padding: const EdgeInsets.only(bottom: _ntcItemGap),
                child: _noticeItem(t),
              )),
      ],
    );
  }

  Widget _noticeItem(String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
                width: _ntcDotSize, height: _ntcDotSize, color: _ntcDotColor),
          ),
          const SizedBox(width: _ntcDotGap),
          Expanded(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: _ntcItemColor, fontSize: _ntcItemFontSize)),
          ),
        ],
      );

  void _showNoticeDialog() {
    if (_noticeText.trim().isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: _ntcDlgMaxWidth),
          padding: const EdgeInsets.fromLTRB(
              _ntcDlgPadL, _ntcDlgPadT, _ntcDlgPadR, _ntcDlgPadB),
          decoration: BoxDecoration(
            color: _ntcDlgBg,
            borderRadius: BorderRadius.circular(_ntcDlgRadius),
            border: Border.all(
                color: _ntcDlgBorderColor.withValues(alpha: _ntcDlgBorderAlpha)),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.campaign_outlined,
                      color: _ntcDlgIconColor, size: _ntcDlgIconSize),
                  SizedBox(width: 8),
                  Text('공지사항',
                      style: TextStyle(
                          color: _ntcDlgTitleColor,
                          fontSize: _ntcDlgTitleFontSize,
                          fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(_noticeText,
                        style: const TextStyle(
                            color: _ntcDlgBodyColor,
                            fontSize: _ntcDlgBodyFontSize,
                            height: _ntcDlgBodyHeight)),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: GlassShineButton(
                    label: '확인',
                    onPressed: () => Navigator.pop(ctx),
                    accent: _teal,
                    pill: true,
                    height: 46,
                    fontSize: _ntcDlgBtnFontSize,
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  // ── 6.8. 정산내역 · 설정 메뉴 카드 ─────────────────────────────────
  Widget _menuCard(String title, IconData icon, Color iconColor, VoidCallback onTap,
          {double padV = 16}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: padV),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder, width: 1),
            boxShadow: _cardShadow,
          ),
          child: Row(children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: _text, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.chevron_right, color: _text2, size: 22),
          ]),
        ),
      );

  // ── 7. 리스비 메뉴 카드 ──────────────────────────────────────────────
  Widget _leaseMenuCard(String uid) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lease_payments')
            .where('uid', isEqualTo: uid)
            .where('isPaid', isEqualTo: false)
            .snapshots(),
        builder: (_, snap) {
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final hasDue = snap.data?.docs.any((dDoc) {
                final dd = (dDoc.data() as Map)['dueDate'] as String? ?? '';
                return dd.isNotEmpty && dd.compareTo(today) <= 0;
              }) ??
              false;
          return GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => _DriverLeasePage(uid: uid))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: _menuLsPadV),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder, width: 1),
                boxShadow: _cardShadow,
              ),
              child: Row(children: [
                const Icon(Icons.moped, color: _pink, size: 24),
                const SizedBox(width: 14),
                Stack(clipBehavior: Clip.none, children: [
                  const Text('리스비',
                      style: TextStyle(
                          color: _text, fontSize: 14, fontWeight: FontWeight.w600)),
                  if (hasDue)
                    Positioned(
                      right: -12,
                      top: -5,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
                        child: const Center(
                            child: Text("N",
                                style: TextStyle(
                                    color: _text, fontSize: 8, fontWeight: FontWeight.w700))),
                      ),
                    ),
                ]),
                const Spacer(),
                const Icon(Icons.chevron_right, color: _text2, size: 22),
              ]),
            ),
          );
        },
      );

  // ── 9. FAB & 1:1 상담 풍선창 ──────────────────────────────────────────
  Widget _buildFABArea(String uid, double bottomInset) {
    final screenH = MediaQuery.of(context).size.height;
    final safeTop = MediaQuery.of(context).padding.top;
    const fabSize = _fabSizeV;
    const fabRight = _fabRightV;
    const fabMarginBottom = _fabMarginBottomV;

    final fabBottom     = fabMarginBottom + bottomInset;
    final balloonBottom = fabBottom + fabSize + 10;
    final maxBalloonH   =
        (screenH - safeTop - 16 - balloonBottom).clamp(160.0, double.infinity);

    return Positioned.fill(
      child: Stack(children: [
        Positioned(
          right: fabRight,
          bottom: fabBottom,
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('chats').doc(uid).snapshots(),
            builder: (_, snap) {
              final unread = (snap.data?.data() as Map<String, dynamic>?)?['unreadByRider']
                      as bool? ??
                  false;
              return Stack(clipBehavior: Clip.none, children: [
                GestureDetector(
                  onTap: () {
                    final open = !_showBalloon;
                    setState(() => _showBalloon = open);
                    if (open) {
                      FirebaseFirestore.instance.collection('chats').doc(uid)
                          .set({'unreadByRider': false}, SetOptions(merge: true));
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_chatScrollCtrl.hasClients) {
                          _chatScrollCtrl.jumpTo(_chatScrollCtrl.position.maxScrollExtent);
                        }
                      });
                    }
                  },
                  child: Container(
                    width: fabSize,
                    height: fabSize,
                    decoration: BoxDecoration(
                      color: _fabBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                        BoxShadow(color: _teal.withValues(alpha: 0.35), blurRadius: 20),
                      ],
                    ),
                    child: const Icon(Icons.support_agent_rounded,
                        color: _fabIconColor, size: _fabIconSize),
                  ),
                ),
                if (unread)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: _fabBadgeSize,
                      height: _fabBadgeSize,
                      decoration: const BoxDecoration(
                          color: _fabBadgeColor, shape: BoxShape.circle),
                    ),
                  ),
              ]);
            },
          ),
        ),
        if (_showBalloon)
          Positioned(
            right: fabRight,
            bottom: balloonBottom,
            child: SizedBox(
              width: _blWidth,
              height: maxBalloonH.clamp(0, _blMaxHeight),
              child: _buildBalloon(uid),
            ),
          ),
      ]),
    );
  }

  Widget _buildBalloon(String uid) {
    return Container(
      decoration: BoxDecoration(
        color: _blBg,
        borderRadius: BorderRadius.circular(_blRadius),
        border: Border.all(
            color: _blBorderColor.withValues(alpha: _blBorderAlpha), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 24,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
          child: Row(children: [
            const Icon(Icons.support_agent_rounded,
                color: _blHeadIconColor, size: _blHeadIconSize),
            const SizedBox(width: 6),
            const Text("관리자 1:1 상담",
                style: TextStyle(
                    color: _blHeadTitleColor,
                    fontSize: _blHeadTitleFontSize,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _showBalloon = false),
              child: const Icon(Icons.close_rounded,
                  color: _blCloseColor, size: _blCloseSize),
            ),
          ]),
        ),
        Container(
            height: 1,
            color: _blDividerColor,
            margin: const EdgeInsets.symmetric(
                horizontal: _blDivMarginH, vertical: 8)),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(uid)
                .collection('messages')
                .orderBy('at', descending: false)
                .limitToLast(50)
                .snapshots(),
            builder: (_, snap) {
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Center(
                  child: Text("상담 내용을 입력해 보세요.",
                      style: TextStyle(color: _blEmptyColor, fontSize: _blEmptyFontSize)),
                );
              }
              final docs = snap.data!.docs;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_chatScrollCtrl.hasClients) {
                  _chatScrollCtrl.animateTo(_chatScrollCtrl.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                }
              });
              return ListView.builder(
                controller: _chatScrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  return _chatBubble(
                      d['text'] as String? ?? '', d['sender'] == 'rider', d['at'] as Timestamp?);
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: _teal.withValues(alpha: 0.18))),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: TextField(
                controller: _balloonCtrl,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(color: _blInputTextColor, fontSize: _blInputFontSize),
                cursorColor: _teal,
                decoration: InputDecoration(
                  hintText: _blHintText,
                  hintStyle: const TextStyle(color: _blHintColor, fontSize: _blInputFontSize),
                  filled: true,
                  fillColor: _blInputBg,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(9),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _blInputBorderColor.withValues(alpha: _blInputBorderAlpha)),
                      borderRadius: BorderRadius.circular(_blInputRadius)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _blInputBorderColor),
                      borderRadius: BorderRadius.circular(_blInputRadius)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _balloonSending ? null : _sendBalloon,
              child: Container(
                width: _blSendSize,
                height: _blSendSize,
                decoration: BoxDecoration(
                  color: _balloonSending ? _chip : _blSendBg.withValues(alpha: _blSendBgAlpha),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _balloonSending ? _borderDim : _teal, width: 0.8),
                ),
                child: _balloonSending
                    ? const Padding(
                        padding: EdgeInsets.all(9),
                        child: CircularProgressIndicator(color: _teal, strokeWidth: 2))
                    : const Icon(Icons.send_rounded,
                        color: _blSendIconColor, size: _blSendIconSize),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _chatBubble(String text, bool isRider, Timestamp? at) {
    return Align(
      alignment: isRider ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: const BoxConstraints(maxWidth: _blBubbleMaxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isRider
              ? _blRiderBubbleBg.withValues(alpha: _blRiderBubbleAlpha)
              : _blAdminBubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: Radius.circular(isRider ? 10 : 2),
            bottomRight: Radius.circular(isRider ? 2 : 10),
          ),
          border: Border.all(
              color: isRider
                  ? _blRiderBubbleBg.withValues(alpha: _blRiderBorderAlpha)
                  : _blAdminBorderColor,
              width: 0.6),
        ),
        child: Column(
            crossAxisAlignment:
                isRider ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isRider)
                const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text("관리자",
                      style: TextStyle(
                          color: _blAdminTagColor,
                          fontSize: _blAdminTagFontSize,
                          fontWeight: FontWeight.w700)),
                ),
              Text(text,
                  style: const TextStyle(
                      color: _blMsgColor,
                      fontSize: _blMsgFontSize,
                      height: _blMsgHeight)),
              if (at != null) ...[
                const SizedBox(height: 2),
                Text(DateFormat('MM/dd HH:mm').format(at.toDate()),
                    style: const TextStyle(
                        color: _blTimeColor, fontSize: _blTimeFontSize)),
              ],
            ]),
      ),
    );
  }

  Future<void> _sendBalloon() async {
    final msg = _balloonCtrl.text.trim();
    if (msg.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _balloonSending = true);
    try {
      final chatRef = FirebaseFirestore.instance.collection('chats').doc(user.uid);
      await chatRef.set({
        'uid': user.uid,
        'riderName': _riderName.isNotEmpty ? _riderName : user.uid,
        'lastMessage': msg,
        'lastAt': FieldValue.serverTimestamp(),
        'unreadByAdmin': true,
        'unreadByRider': false,
      }, SetOptions(merge: true));
      await chatRef.collection('messages').add({
        'sender': 'rider',
        'text': msg,
        'at': FieldValue.serverTimestamp(),
      });
      _balloonCtrl.clear();
      if (mounted) setState(() => _balloonSending = false);
    } catch (e) {
      if (mounted) {
        setState(() => _balloonSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("전송 실패: $e", style: const TextStyle(fontSize: 12)),
            backgroundColor: _surface,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 100),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildMaintenanceScreen() {
    return Scaffold(
      backgroundColor: _bgScaffold,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cardBorder, width: 1)),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.power_settings_new_rounded, color: _red, size: 48),
            const SizedBox(height: 16),
            const Text("서비스 점검 중",
                style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text("현재 서비스가 일시 중단되었습니다.\n잠시 후 다시 시도해 주세요.",
                style: TextStyle(color: _text2, fontSize: 13, height: 1.6),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: GlassShineButton(
                label: "새로고침",
                onPressed: _checkAppStatus,
                accent: _text2,
                textColor: _text2,
                height: 44,
                radius: 10,
                fontSize: 13,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 4-추가. 출금 그라디언트 프레임 (빛 흐르는 테두리 + 금액 + 출금신청)
// ═══════════════════════════════════════════════════════════════════════
class _WithdrawFrame extends StatefulWidget {
  final int amount;
  final VoidCallback onWithdraw;
  const _WithdrawFrame({required this.amount, required this.onWithdraw});
  @override
  State<_WithdrawFrame> createState() => _WithdrawFrameState();
}

class _WithdrawFrameState extends State<_WithdrawFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flow = AnimationController(
      vsync: this, duration: const Duration(milliseconds: _wfFlowMs))
    ..repeat();
  bool _pressed = false;

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amtStr = NumberFormat('#,###').format(widget.amount);
    return AnimatedBuilder(
      animation: _flow,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_wfRadius),
          // 빛이 흐르는 테두리: 골드→핑크→퍼플 sweep을 천천히 회전
          gradient: SweepGradient(
            transform: GradientRotation(_flow.value * 2 * math.pi),
            colors: const [_wfGold, _wfPink, _wfPurple, _wfGold],
          ),
          boxShadow: const [
            BoxShadow(
                color: Color(0x55FF5FC4),
                blurRadius: 16,
                spreadRadius: -6,
                offset: Offset(0, 8)),
          ],
        ),
        padding: const EdgeInsets.all(_wfBorderWidth),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_wfRadius - _wfBorderWidth),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_wfInnerTop, _wfInnerBottom],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 13, 13, 13),
          child: Row(children: [
            const SizedBox(width: _wfAmtLeftGap),
            // 금액 (골드 그라데이션 글씨)
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                      colors: [_wfGold, _wfGoldText2])
                  .createShader(r),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: amtStr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: _wfAmtFontSize,
                          fontWeight: FontWeight.w700)),
                  const TextSpan(
                      text: ' 원',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: _wfAmtUnitFontSize,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            const Spacer(),
            // 출금신청 버튼 (골드→핑크 그라데이션)
            GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: widget.onWithdraw,
              child: AnimatedScale(
                scale: _pressed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: _wfBtnPadH, vertical: _wfBtnPadV),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_wfBtnRadius),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [_wfGoldDeep, _wfPink],
                    ),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x8CFF5FC4),
                          blurRadius: 16,
                          spreadRadius: -6,
                          offset: Offset(0, 6)),
                    ],
                  ),
                  child: const Text('출금신청',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: _wfBtnFontSize,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 10. 차트 영역 / 링 게이지 Painter
// ═══════════════════════════════════════════════════════════════════════
// 링 색: 0~30% 퍼플 → 31~60% 핑크 → 61%+ 민트 (경계만 블렌드)
Color _ringColorFor(double pct) {
  if (pct < 0.30) return _purple;
  if (pct < 0.32) return Color.lerp(_purple, _pink, (pct - 0.30) / 0.02)!;
  if (pct < 0.60) return _pink;
  if (pct < 0.62) return Color.lerp(_pink, _teal, (pct - 0.60) / 0.02)!;
  return _teal;
}

class _AreaChartPainter extends CustomPainter {
  final List<double> data;
  _AreaChartPainter(this.data);

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
        text: _comma(data[maxIdx]),
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
  bool shouldRepaint(covariant _AreaChartPainter old) => old.data != data;
}

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

    final shader = SweepGradient(
      colors: const [_purple, _purple, _pink, _pink, _teal, _teal],
      stops: const [0.0, 0.28, 0.34, 0.58, 0.64, 1.0],
      transform: const GradientRotation(start),
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

// ═══════════════════════════════════════════════════════════════════════
// 6. 정산 내역 페이지 (탭 2개: 정산 내역 / 출금 내역)
// ═══════════════════════════════════════════════════════════════════════
class _HistoryPage extends StatefulWidget {
  final String uid;
  const _HistoryPage({required this.uid});
  @override
  State<_HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<_HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // 정산 내역 탭
  List<Map<String, dynamic>> _settlements = [];
  bool _settleLoaded = false;
  final Map<String, bool> _settleExp = {};
  final Map<String, bool> _itemToggles = {};

  // 업로드된 현재 미출금(정산 대기)
  List<Map<String, dynamic>> _pendingItems = [];
  double _pendingTotal     = 0;
  bool   _pendingRequested = false;
  bool   _pHasDailyLease   = false;
  double _pLeaseDailyAmt   = 0;
  bool   _pendingLoaded    = false;

  // 출금 내역 탭
  DateTime? _start, _end, _startApplied, _endApplied;
  bool _histLoaded = false;
  bool _histLoading = false;
  double _hGross = 0, _hPromo = 0, _hPOrd = 0, _hRng = 0;
  double _hTax = 0, _hEmp = 0, _hAcc = 0, _hInc = 0;
  double _hWd = 0, _hComm = 0, _hIns = 0, _hLease = 0, _hTotal = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadPending();
    _loadSettlements();
    _loadHistData();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadSettlements() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('admin_settlement_logs')
          .where('uid', isEqualTo: widget.uid)
          .where('status', isEqualTo: '지급완료')
          .orderBy('approvedAt', descending: true)
          .get();
      final list = snap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data());
        m['_docId'] = d.id;
        return m;
      }).toList();
      if (mounted) setState(() {
        _settlements = list;
        _settleLoaded = true;
      });
    } catch (e) {
      debugPrint('정산내역 로드 실패: $e');
      if (mounted) setState(() => _settleLoaded = true);
    }
  }

  Future<void> _loadPending() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _pendingLoaded = true);
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).get();
      final leaseType = userDoc.data()?['leaseType']      as String? ?? '';
      final leaseAmt  = userDoc.data()?['leaseAmount']    as int?    ?? 0;
      final startStr  = userDoc.data()?['leaseStartDate'] as String? ?? '';
      final lastStr   = userDoc.data()?['leaseLastDate']  as String? ?? '';
      if (leaseType == 'daily' && leaseAmt > 0) {
        final now   = DateTime.now();
        final start = DateTime.tryParse(startStr);
        final last  = DateTime.tryParse(lastStr);
        if (start != null && last != null &&
            !now.isBefore(DateTime(start.year, start.month, start.day)) &&
            !now.isAfter(DateTime(last.year, last.month, last.day))) {
          _pHasDailyLease = true;
          _pLeaseDailyAmt = leaseAmt.toDouble();
        }
      }

      final pending = await FirebaseFirestore.instance
          .collection('withdrawal_requests')
          .where('uid',    isEqualTo: user.uid)
          .where('status', isEqualTo: '요청대기')
          .limit(1).get();
      final requested = pending.docs.isNotEmpty;

      List<Map<String, dynamic>> items = [];
      double total = 0;
      final doc = await FirebaseFirestore.instance
          .collection('unpaid_balance').doc(user.uid).get();
      if (doc.exists) {
        final raw = doc.data()?['items'] as List<dynamic>? ?? [];
        items = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        total = (doc.data()?['totalAmount'] as num?)?.toDouble() ?? 0;
      }

      if (mounted) setState(() {
        _pendingItems     = items;
        _pendingTotal     = total;
        _pendingRequested = requested;
        _pendingLoaded    = true;
      });
    } catch (e) {
      debugPrint('정산 대기 로드 실패: $e');
      if (mounted) setState(() => _pendingLoaded = true);
    }
  }

  Future<void> _loadHistData() async {
    if (_histLoading) return;
    if (mounted) setState(() {
      _histLoading = true;
      _histLoaded = false;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('admin_settlement_logs')
          .where('uid', isEqualTo: widget.uid)
          .where('status', isEqualTo: '지급완료')
          .get();

      double gross = 0, promo = 0, pOrd = 0, rng = 0;
      double tax = 0, emp = 0, acc = 0, inc = 0;
      double wd = 0, comm = 0, ins = 0, lease = 0, total = 0;

      final hasFilter = _startApplied != null || _endApplied != null;
      final endDay = _endApplied != null
          ? DateTime(_endApplied!.year, _endApplied!.month, _endApplied!.day, 23, 59, 59)
          : null;

      for (final doc in snap.docs) {
        final data = doc.data();
        final items = (data['items'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];

        if (!hasFilter) {
          total += (data['amount'] as num?)?.toDouble() ?? 0;
          lease += (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
          for (final it in items) {
            gross += (it['deliveryFee'] as num?)?.toDouble() ?? 0;
            promo += (it['promoTotal'] as num?)?.toDouble() ?? 0;
            pOrd += (it['perOrderAmount'] as num?)?.toDouble() ?? 0;
            rng += (it['rangeAmount'] as num?)?.toDouble() ?? 0;
            tax += (it['tax'] as num?)?.toDouble() ?? 0;
            emp += (it['employmentTax'] as num?)?.toDouble() ?? 0;
            acc += (it['accidentTax'] as num?)?.toDouble() ?? 0;
            inc += (it['incomeTax'] as num?)?.toDouble() ?? 0;
            wd += (it['withdrawalFee'] as num?)?.toDouble() ?? 0;
            comm += (it['commissionAmt'] as num?)?.toDouble() ?? 0;
            ins += (it['insuranceFee'] as num?)?.toDouble() ?? 0;
          }
        } else {
          int matchedCount = 0;
          for (final it in items) {
            final itemDate = DateTime.tryParse(it['date'] as String? ?? '');
            if (itemDate == null) continue;
            if (_startApplied != null && itemDate.isBefore(_startApplied!)) continue;
            if (endDay != null && itemDate.isAfter(endDay)) continue;
            matchedCount++;
            gross += (it['deliveryFee'] as num?)?.toDouble() ?? 0;
            promo += (it['promoTotal'] as num?)?.toDouble() ?? 0;
            pOrd += (it['perOrderAmount'] as num?)?.toDouble() ?? 0;
            rng += (it['rangeAmount'] as num?)?.toDouble() ?? 0;
            tax += (it['tax'] as num?)?.toDouble() ?? 0;
            emp += (it['employmentTax'] as num?)?.toDouble() ?? 0;
            acc += (it['accidentTax'] as num?)?.toDouble() ?? 0;
            inc += (it['incomeTax'] as num?)?.toDouble() ?? 0;
            wd += (it['withdrawalFee'] as num?)?.toDouble() ?? 0;
            comm += (it['commissionAmt'] as num?)?.toDouble() ?? 0;
            ins += (it['insuranceFee'] as num?)?.toDouble() ?? 0;
          }
          if (matchedCount > 0 && items.isNotEmpty) {
            final fullLease = (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
            lease += fullLease * matchedCount / items.length;
          }
        }
      }

      if (hasFilter) {
        total = gross + promo - tax - (wd + comm) - ins - lease;
      }

      if (mounted) setState(() {
        _hGross = gross; _hPromo = promo; _hPOrd = pOrd; _hRng = rng;
        _hTax = tax; _hEmp = emp; _hAcc = acc; _hInc = inc;
        _hWd = wd; _hComm = comm; _hIns = ins; _hLease = lease;
        _hTotal = total; _histLoaded = true; _histLoading = false;
      });
    } catch (e) {
      debugPrint('총출금내역 로드 실패: $e');
      if (mounted) setState(() {
        _histLoaded = true;
        _histLoading = false;
      });
    }
  }

  // ── 6-1. 메인배경 + 탭 ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_hpOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _hpPanelColor,
              borderRadius: BorderRadius.circular(_hpPanelRadius),
              border: Border.all(
                  color: _hpPanelBorderColor.withValues(alpha: _hpPanelBorderAlpha)),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_hpPanelRadius),
              child: Column(children: [
                const SizedBox(height: 8),
                _pageHeader(context, "정산 내역"),
                const SizedBox(height: _hpGapHeaderToDiv),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: _hpDivMarginH),
                  color: _elevated.withValues(alpha: 0.6),
                ),
                const SizedBox(height: _hpGapDivToTab),
                Container(
                  margin: const EdgeInsets.fromLTRB(
                      _hpTabMarginL, _hpTabMarginT, _hpTabMarginR, _hpTabMarginB),
                  padding: const EdgeInsets.all(_hpTabTrackPad),
                  decoration: BoxDecoration(
                      color: _hpTabTrackColor,
                      borderRadius: BorderRadius.circular(_hpTabTrackRadius)),
                  child: TabBar(
                    controller: _tab,
                    indicator: BoxDecoration(
                        color: _hpTabIndicatorColor,
                        borderRadius: BorderRadius.circular(_hpTabIndicatorRadius),
                        border: Border.all(color: _hpTabIndicatorBorder, width: 1)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: _hpTabSelColor,
                    unselectedLabelColor: _hpTabUnselColor,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: _hpTabFontSize),
                    unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: _hpTabFontSize),
                    tabs: const [Tab(text: _hpTab1Text), Tab(text: _hpTab2Text)],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [_buildWithdrawTab(), _buildTotalTab()],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── 6-2. 정산탭 전용 공통 함수 ──
  Widget _stAmt(double v, Color numColor,
      {double fs = 13, bool bold = false, Color? unitColor, double? unitFs}) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: _fmt(v),
          style: TextStyle(
              color: numColor,
              fontSize: fs,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
        ),
        TextSpan(
          text: ' 원',
          style: TextStyle(
              color: unitColor ?? _stAmtUnitColor,
              fontSize: unitFs ?? fs,
              fontWeight: FontWeight.w400),
        ),
      ]),
    );
  }

  Widget _stDetailRow(String label, double v, Color vc, {Color labelColor = _stRowLabelColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(
                  color: labelColor,
                  fontSize: _stRowFontSize,
                  fontWeight: FontWeight.w500)),
          _stAmt(v, vc, fs: _stRowAmtFontSize),
        ]),
      );

  Widget _stToggleRow(String key, String label, double v, Color vc) {
    final exp = _itemToggles[key] ?? false;
    return GestureDetector(
      onTap: () => setState(() => _itemToggles[key] = !exp),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Text(label,
              style: const TextStyle(
                  color: _stRowLabelColor,
                  fontSize: _stRowFontSize,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Icon(exp ? Icons.expand_less : Icons.expand_more,
              color: _stToggleIconColor, size: _stToggleIconSize),
          const Spacer(),
          _stAmt(v, vc, fs: _stRowAmtFontSize),
        ]),
      ),
    );
  }

  Widget _stSubGroup(List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
            color: _stSubBoxBg,
            borderRadius: BorderRadius.circular(_stSubBoxRadius),
            border: Border.all(color: _stSubBoxBorder)),
        child: Column(children: children),
      );

  Widget _stSubRow(String label, double v, Color vc) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: const TextStyle(
                  color: _stSubLabelColor, fontSize: _stSubRowFontSize)),
          _stAmt(v, vc,
              fs: _stSubAmtFontSize,
              unitColor: _stSubAmtUnitColor,
              unitFs: _stSubAmtUnitFontSize),
        ]),
      );

  // 6-2 추가. 미출금 항목이 23시 마감을 지났는지 판별
  //  · items의 가장 최근 날짜가 '오늘'이 아니면  → 마감 지남(미출금)
  //  · '오늘'인데 현재 시각이 23시를 넘었으면     → 마감 지남(미출금)
  //  · 그 외(오늘 + 23시 전)                      → 아직 신청 가능(신청대기)
  bool _isPendingOverdue(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return false;
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final lastDate = items.last['date'] as String? ?? '';
    if (lastDate.isEmpty) return false;
    if (lastDate != todayStr) return true;          // 어제 이전 = 이미 마감
    return now.hour >= _stCutoffHour;               // 오늘인데 23시 넘음
  }

  Widget _buildWithdrawTab() {
    if (!_settleLoaded || !_pendingLoaded) {
      return const Center(child: CircularProgressIndicator(color: _teal));
    }
    final hasPending = _pendingItems.isNotEmpty;
    if (!hasPending && _settlements.isEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Icon(Icons.receipt_long_rounded,
            color: _stEmptyIconColor, size: _stEmptyIconSize),
        SizedBox(height: 12),
        Text("정산 내역이 없습니다.",
            style: TextStyle(
                color: _stEmptyTitleColor,
                fontSize: _stEmptyTitleFontSize,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Text("관리자가 정산 데이터를 업로드하면 표시됩니다.",
            style: TextStyle(color: _stEmptySubColor, fontSize: _stEmptySubFontSize)),
      ]));
    }

    final cards = <Map<String, dynamic>>[];
    if (hasPending) {
      final leaseDays = _pHasDailyLease ? _pendingItems.length : 0;
      final tLease = leaseDays * _pLeaseDailyAmt;
      // 상태 결정: 신청완료 → 입금대기 / 23시 마감 지남 → 미출금 / 그 외 → 신청대기
      final String pendingStatus;
      if (_pendingRequested) {
        pendingStatus = '입금대기';
      } else if (_isPendingOverdue(_pendingItems)) {
        pendingStatus = _stUnpaidLabel;            // 미출금(퍼플)
      } else {
        pendingStatus = '신청대기';
      }
      cards.add({
        '_docId': 'pending',
        'items': _pendingItems,
        'amount': _pendingTotal - tLease,
        'leaseDeduction': tLease,
        '_status': pendingStatus,
      });
    }
    for (final s in _settlements) {
      cards.add({...s, '_status': '입금완료'});
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          _stListPadL, _stListPadT, _stListPadR, _stListPadB),
      children: cards.map(_settlementCard).toList(),
    );
  }

  Widget _settlementCard(Map<String, dynamic> data) {
    final docId = data['_docId'] as String? ?? '';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final items = (data['items'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    final leaseDedu = (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
    final exp = _settleExp[docId] ?? false;
    final status = data['_status'] as String? ?? '입금완료';
    final stColor = status == '신청대기'
        ? _amber
        : status == '입금대기'
            ? _pink
            : status == _stUnpaidLabel
                ? _stUnpaidColor      // 미출금 = 퍼플
                : _teal;

    String dateLabel;
    if (items.isNotEmpty) {
      final first = items.first['date'] as String? ?? '';
      final last = items.last['date'] as String? ?? '';
      final fs = first.length >= 10 ? first.substring(5) : first;
      final ls = last.length >= 10 ? last.substring(5) : last;
      dateLabel = items.length == 1 ? fs : "$fs ~ $ls";
    } else {
      final approvedAt = (data['approvedAt'] as Timestamp?)?.toDate();
      dateLabel = approvedAt != null
          ? DateFormat('MM/dd').format(approvedAt)
          : (data['date'] as String? ?? '');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: _stCardGap),
      decoration: BoxDecoration(
        color: _stCardBg,
        borderRadius: BorderRadius.circular(_stCardRadius),
        border: Border.all(
            color: exp ? _stCardBorderOpen : _stCardBorderClose, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _settleExp[docId] = !exp),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: _stCardHeadPadH, vertical: _stCardHeadPadV),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                    color: _stDateChipBg,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: _stDateChipBorder, width: 1)),
                child: Text(dateLabel,
                    style: const TextStyle(
                        color: _stDateChipText,
                        fontSize: _stDateChipFontSize,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text("${items.length}일",
                  style: const TextStyle(
                      color: _stDayCountColor, fontSize: _stDayCountFontSize)),
              const Spacer(),
              _stAmt(amount, _stHeadAmtColor, fs: _stHeadAmtFontSize, bold: true),
              const SizedBox(width: 8),
              _statusBadge(status, stColor),
            ]),
          ),
        ),
        if (exp) ...[
          Container(height: 1, color: _borderDim),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                _stBodyPadL, _stBodyPadT, _stBodyPadR, _stBodyPadB),
            child: Column(children: [
              ...List.generate(items.length, (i) {
                final item = items[i];
                final dateStr = item['date'] as String? ?? '';
                final dateShort = dateStr.length >= 10 ? dateStr.substring(5) : dateStr;
                final del = (item['deliveryFee'] as num?)?.toDouble() ?? 0;
                final prm = (item['promoTotal'] as num?)?.toDouble() ?? 0;
                final pOrd = (item['perOrderAmount'] as num?)?.toDouble() ?? 0;
                final rng = (item['rangeAmount'] as num?)?.toDouble() ?? 0;
                final tax = (item['tax'] as num?)?.toDouble() ?? 0;
                final emp = (item['employmentTax'] as num?)?.toDouble() ?? 0;
                final acc = (item['accidentTax'] as num?)?.toDouble() ?? 0;
                final inc = (item['incomeTax'] as num?)?.toDouble() ?? 0;
                final wd = (item['withdrawalFee'] as num?)?.toDouble() ?? 0;
                final comm = (item['commissionAmt'] as num?)?.toDouble() ?? 0;
                final ins = (item['insuranceFee'] as num?)?.toDouble() ?? 0;
                final fee = wd + comm;
                final dailyLease = items.isNotEmpty ? leaseDedu / items.length : 0.0;
                final iDedu = ins + dailyLease;

                final promoK = '${docId}_${i}_promo';
                final taxK = '${docId}_${i}_tax';
                final commK = '${docId}_${i}_comm';
                final deduK = '${docId}_${i}_dedu';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (i > 0)
                      Container(
                        height: 1,
                        color: _borderDim,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _stDayChipBg,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: _stDayChipBorder),
                      ),
                      child: Text(dateShort,
                          style: const TextStyle(
                              color: _stDayChipText,
                              fontSize: _stDayChipFontSize,
                              fontWeight: FontWeight.w600)),
                    ),
                    _stDetailRow("배달수수료 (세전)", del, _stRowLabelColor,
                        labelColor: _stRowLabelColor),
                    const SizedBox(height: 2),
                    _stToggleRow(promoK, "지원금합계", prm, _stRowLabelColor),
                    if (_itemToggles[promoK] == true)
                      _stSubGroup([
                        _stSubRow("건당프로모션", pOrd, _stSubRowColor),
                        _stSubRow("구간프로모션", rng, _stSubRowColor),
                      ]),
                    _stToggleRow(taxK, "세금합계", tax, _stRowPinkColor),
                    if (_itemToggles[taxK] == true)
                      _stSubGroup([
                        _stSubRow("고용보험", emp, _stSubRowColor),
                        _stSubRow("산재보험", acc, _stSubRowColor),
                        _stSubRow("원천세", inc, _stSubRowColor),
                      ]),
                    _stToggleRow(commK, "수수료합계", fee, _stRowPinkColor),
                    if (_itemToggles[commK] == true)
                      _stSubGroup([
                        _stSubRow("출금수수료", wd, _stSubRowColor),
                        _stSubRow("협력사수수료", comm, _stSubRowColor),
                      ]),
                    if (iDedu > 0) ...[
                      _stToggleRow(deduK, "공제합계", iDedu, _stRowPinkColor),
                      if (_itemToggles[deduK] == true)
                        _stSubGroup([
                          if (ins > 0) _stSubRow("시간제보험", ins, _stSubRowColor),
                          if (dailyLease > 0) _stSubRow("리스비", dailyLease, _stSubRowColor),
                        ]),
                    ],
                    const SizedBox(height: 6),
                    Container(height: 1, color: _chip),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("소계",
                          style: TextStyle(
                              color: _stSubtotalColor,
                              fontSize: _stSubtotalFontSize,
                              fontWeight: FontWeight.w600)),
                      _stAmt(del + prm - tax - fee - iDedu, _stSubtotalColor,
                          fs: _stSubtotalAmtFontSize,
                          unitColor: _stSubtotalUnitColor,
                          unitFs: _stSubtotalUnitFontSize),
                    ]),
                  ],
                );
              }),
            ]),
          ),
        ],
      ]),
    );
  }

  // ── 6-3. 출금탭 전용 공통 함수 ──
  Widget _htAmt(double v, Color numColor,
      {double fs = 13, bool bold = false, Color? unitColor, double? unitFs}) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: _fmt(v),
          style: TextStyle(
              color: numColor,
              fontSize: fs,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
        ),
        TextSpan(
          text: ' 원',
          style: TextStyle(
              color: unitColor ?? _htAmtUnitColor,
              fontSize: unitFs ?? fs,
              fontWeight: FontWeight.w400),
        ),
      ]),
    );
  }

  Widget _htDetailRow(String label, double v, Color vc, {Color labelColor = _htRowLabelColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(
                  color: labelColor,
                  fontSize: _htRowFontSize,
                  fontWeight: FontWeight.w500)),
          _htAmt(v, vc, fs: _htRowAmtFontSize),
        ]),
      );

  Widget _htToggleRow(String key, String label, double v, Color vc) {
    final exp = _itemToggles[key] ?? false;
    return GestureDetector(
      onTap: () => setState(() => _itemToggles[key] = !exp),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Text(label,
              style: const TextStyle(
                  color: _htRowLabelColor,
                  fontSize: _htRowFontSize,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Icon(exp ? Icons.expand_less : Icons.expand_more,
              color: _htToggleIconColor, size: _htToggleIconSize),
          const Spacer(),
          _htAmt(v, vc, fs: _htRowAmtFontSize),
        ]),
      ),
    );
  }

  Widget _htSubGroup(List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
            color: _htSubBoxBg,
            borderRadius: BorderRadius.circular(_htSubBoxRadius),
            border: Border.all(color: _htSubBoxBorder)),
        child: Column(children: children),
      );

  Widget _htSubRow(String label, double v, Color vc) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: const TextStyle(
                  color: _htSubLabelColor, fontSize: _htSubRowFontSize)),
          _htAmt(v, vc,
              fs: _htSubAmtFontSize,
              unitColor: _htSubAmtUnitColor,
              unitFs: _htSubAmtUnitFontSize),
        ]),
      );

  Widget _buildTotalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, _htGapTabToCard, 15, 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            _htCardPadL, _htCardPadT, _htCardPadR, _htCardPadB),
        decoration: BoxDecoration(
          color: _htCardBg,
          borderRadius: BorderRadius.circular(_htCardRadius),
          border: Border.all(color: _htCardBorder, width: 1),
          boxShadow: _cardShadow,
        ),
        child: Column(children: [
          Row(children: [
            _dateBtn(_start, "시작일", (d) => setState(() => _start = d)),
            const Text("  ~  ",
                style: TextStyle(color: _htTildeColor, fontSize: _htTildeFontSize)),
            _dateBtn(_end, "종료일", (d) => setState(() => _end = d)),
            const SizedBox(width: 8),
            _smallBtn(_htBtnSearchText, () {
              setState(() {
                _startApplied = _start;
                _endApplied = _end;
              });
              _loadHistData();
            }, filled: true),
            const SizedBox(width: 6),
            _smallBtn(_htBtnResetText, () {
              setState(() {
                _start = _end = _startApplied = _endApplied = null;
              });
              _loadHistData();
            }),
          ]),
          Container(
              height: 1,
              color: _elevated.withValues(alpha: 0.6),
              margin: const EdgeInsets.symmetric(vertical: 12)),
          if (!_histLoaded)
            const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: _teal))
          else ...[
            _htDetailRow("배달수수료 (세전)", _hGross, _htRowLabelColor,
                labelColor: _htRowLabelColor),
            const SizedBox(height: 2),
            _htToggleRow('h_promo', "지원금합계", _hPromo, _htRowLabelColor),
            if (_itemToggles['h_promo'] == true)
              _htSubGroup([
                _htSubRow("건당프로모션", _hPOrd, _htSubRowColor),
                _htSubRow("구간프로모션", _hRng, _htSubRowColor),
              ]),
            _htToggleRow('h_tax', "세금합계", _hTax, _htRowPinkColor),
            if (_itemToggles['h_tax'] == true)
              _htSubGroup([
                _htSubRow("고용보험", _hEmp, _htSubRowColor),
                _htSubRow("산재보험", _hAcc, _htSubRowColor),
                _htSubRow("원천세", _hInc, _htSubRowColor),
              ]),
            _htToggleRow('h_comm', "수수료합계", _hWd + _hComm, _htRowPinkColor),
            if (_itemToggles['h_comm'] == true)
              _htSubGroup([
                _htSubRow("출금수수료", _hWd, _htSubRowColor),
                _htSubRow("협력사수수료", _hComm, _htSubRowColor),
              ]),
            _htToggleRow('h_dedu', "공제합계", _hIns + _hLease, _htRowPinkColor),
            if (_itemToggles['h_dedu'] == true)
              _htSubGroup([
                if (_hIns > 0) _htSubRow("시간제보험", _hIns, _htSubRowColor),
                if (_hLease > 0) _htSubRow("리스비", _hLease, _htSubRowColor),
              ]),
            Container(
                height: 1,
                color: _elevated.withValues(alpha: 0.6),
                margin: const EdgeInsets.symmetric(vertical: 12)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("총 출금금액",
                  style: TextStyle(
                      color: _htTotalColor,
                      fontSize: _htTotalFontSize,
                      fontWeight: FontWeight.w700)),
              _htAmt(_hTotal, _htTotalColor,
                  fs: _htTotalAmtFontSize,
                  bold: true,
                  unitColor: _htTotalUnitColor,
                  unitFs: _htTotalUnitFontSize),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _dateBtn(DateTime? date, String hint, Function(DateTime) onPick) {
    return GestureDetector(
      onTap: () async {
        final p = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2026),
          lastDate: DateTime(2030),
          builder: (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(primary: _teal)),
            child: child!,
          ),
        );
        if (p != null) onPick(p);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: _htDatePadH, vertical: _htDatePadV),
        decoration: BoxDecoration(
            border: Border.all(
                color: date != null ? _htDateActiveColor : _htDateBorderColor),
            borderRadius: BorderRadius.circular(_htDateRadius)),
        child: Text(date != null ? DateFormat('MM-dd').format(date) : hint,
            style: TextStyle(
                color: date != null ? _htDateActiveColor : _htDateHintColor,
                fontSize: _htDateFontSize)),
      ),
    );
  }

  Widget _smallBtn(String label, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: _htBtnHeight,
        padding: const EdgeInsets.symmetric(horizontal: _htBtnPadH),
        decoration: BoxDecoration(
          color: filled ? _htBtnFilledBg : Colors.transparent,
          border: Border.all(color: filled ? _htBtnFilledBg : _htBtnLineBorder),
          borderRadius: BorderRadius.circular(_htBtnRadius),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
                color: filled ? _htBtnFilledText : _htBtnLineText,
                fontSize: _htBtnFontSize,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 7. 리스비 페이지
// ═══════════════════════════════════════════════════════════════════════
class _DriverLeasePage extends StatefulWidget {
  final String uid;
  const _DriverLeasePage({required this.uid});
  @override
  State<_DriverLeasePage> createState() => _DriverLeasePageState();
}

class _DriverLeasePageState extends State<_DriverLeasePage> {
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _markAsSeen();
  }

  Future<void> _markAsSeen() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('lease_payments')
          .where('uid', isEqualTo: widget.uid)
          .where('isPaid', isEqualTo: true)
          .where('seenByRider', isEqualTo: false)
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'seenByRider': true});
      }
      if (snap.docs.isNotEmpty) await batch.commit();
    } catch (_) {}
  }

  Future<void> _submitPaid() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final snap = await FirebaseFirestore.instance
          .collection('lease_payments')
          .where('uid', isEqualTo: widget.uid)
          .where('dueDate', isEqualTo: today)
          .where('isPaid', isEqualTo: false)
          .get();
      if (snap.docs.isEmpty) {
        if (mounted) _showInfoDialog(context, "오늘 납기 회차를 찾을 수 없습니다.");
        return;
      }
      await snap.docs.first.reference.update({'riderPaid': true});
      if (mounted) _showInfoDialog(context, "입금완료 처리되었습니다!\n관리자가 확인 후 납부 처리합니다.");
    } catch (_) {
      if (mounted) _showInfoDialog(context, "처리 실패. 다시 시도해주세요.");
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── 7-1. 메인배경 ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_lpOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _lpPanelColor,
              borderRadius: BorderRadius.circular(_lpPanelRadius),
              border: Border.all(
                  color: _lpPanelBorderColor.withValues(alpha: _lpPanelBorderAlpha)),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_lpPanelRadius),
              child: Column(children: [
                const SizedBox(height: 8),
                _pageHeader(context, "리스비 납부 현황"),
                const SizedBox(height: _lpGapHeaderToDiv),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: _lpDivMarginH),
                  color: _elevated.withValues(alpha: 0.6),
                ),
                const SizedBox(height: _lpGapDivToCard),
                Expanded(child: _buildBody()),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots(),
      builder: (_, userSnap) {
        final userData = userSnap.data?.data() as Map<String, dynamic>?;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('lease_payments')
              .where('uid', isEqualTo: widget.uid)
              .orderBy('dueDate')
              .snapshots(),
          builder: (ctx, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator(color: _teal));
            }
            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.moped,
                    color: _lpEmptyIconColor, size: _lpEmptyIconSize),
                SizedBox(height: 12),
                Text("리스비 납부 내역이 없습니다.",
                    style: TextStyle(
                        color: _lpEmptyTitleColor,
                        fontSize: _lpEmptyTitleFontSize,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 6),
                Text("관리자에게 문의해 주세요.",
                    style: TextStyle(color: _lpEmptySubColor, fontSize: _lpEmptySubFontSize)),
              ]));
            }
            final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
            final isDaily = (userData?['leaseType'] as String?) == 'daily';
            final paid = docs.where((d) => (d.data() as Map)['isPaid'] == true).toList();
            final unpaid = docs.where((d) => (d.data() as Map)['isPaid'] != true).toList();
            final todayDue =
                unpaid.where((d) => (d.data() as Map)['dueDate'] == today).toList();
            final overdue = unpaid.where((d) =>
                ((d.data() as Map)['dueDate'] as String? ?? '').compareTo(today) < 0).toList();
            final riderAlreadyPaid =
                todayDue.any((d) => (d.data() as Map)['riderPaid'] == true);
            final hasAlert = unpaid.any((d) {
              final dd = (d.data() as Map)['dueDate'] as String? ?? '';
              return dd.isNotEmpty && dd.compareTo(today) <= 0;
            });

            return ListView(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              children: [
                if (userData != null)
                  _leaseSummaryCard(userData, paid.length, docs.length,
                      hasAlert: hasAlert,
                      hasTodayDue: todayDue.isNotEmpty,
                      riderAlreadyPaid: riderAlreadyPaid),
                if (!isDaily && overdue.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: _lpOverBoxColor.withValues(alpha: _lpOverBoxBgAlpha),
                        borderRadius: BorderRadius.circular(_lpOverBoxRadius),
                        border: Border.all(
                            color: _lpOverBoxColor.withValues(alpha: _lpOverBoxBorderAlpha),
                            width: _lpOverBoxBorderWidth)),
                    child: Row(children: [
                      const Icon(Icons.warning_rounded,
                          color: _lpOverBoxColor, size: _lpOverIconSize),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("납기 초과 ${overdue.length}건이 있습니다!",
                            style: const TextStyle(
                                color: _lpOverBoxColor,
                                fontSize: _lpOverTitleFontSize,
                                fontWeight: FontWeight.w700)),
                        const Text("관리자에게 문의해 주세요.",
                            style: TextStyle(
                                color: _lpOverSubColor, fontSize: _lpOverSubFontSize)),
                      ])),
                    ]),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ── 7-2. 리스비 전체현황 카드 ──
  Widget _leaseSummaryCard(Map<String, dynamic> u, int paidCount, int totalCount,
      {bool hasAlert = false,
      bool hasTodayDue = false,
      bool riderAlreadyPaid = false}) {
    final leaseType = u['leaseType'] as String? ?? '';
    final leaseAmt = u['leaseAmount'] as int? ?? 0;
    final leaseCycle = u['leaseCycle'] as int? ?? 0;
    final startStr = u['leaseStartDate'] as String? ?? '';
    final endStr = u['leaseLastDate'] as String? ?? '';
    final isDaily = leaseType == 'daily';
    final typeLabel = isDaily ? '매일' : (leaseType == 'weekly' ? '주1회' : '매월');
    final cycleLabel = isDaily ? '일' : '회차';
    final totalAmt = leaseAmt * leaseCycle;
    final paidAmt = leaseAmt * paidCount;
    final progress = totalCount > 0 ? paidCount / totalCount : 0.0;
    final startShort = startStr.length >= 10 ? startStr.substring(5) : startStr;
    final endShort = endStr.length >= 10 ? endStr.substring(5) : endStr;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(
          _lsCardPadL, _lsCardPadT, _lsCardPadR, _lsCardPadB),
      decoration: BoxDecoration(
          color: _lsCardBg,
          borderRadius: BorderRadius.circular(_lsCardRadius),
          border: Border.all(
              color: hasAlert
                  ? _lsCardBorderAlert.withValues(alpha: _lsCardAlertBorderAlpha)
                  : _lsCardBorderNormal,
              width: hasAlert ? 1.5 : 1),
          boxShadow: _cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.moped,
              color: _lsHeadIconColor, size: _lsHeadIconSize),
          const SizedBox(width: 6),
          const Text("리스비 전체 현황",
              style: TextStyle(
                  color: _lsHeadTitleColor,
                  fontSize: _lsHeadTitleFontSize,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: _lsTypeChipBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _lsTypeChipBorder, width: 1)),
            child: Text(typeLabel,
                style: const TextStyle(
                    color: _lsTypeChipText,
                    fontSize: _lsTypeChipFontSize,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
        Container(
            height: 1,
            color: _elevated.withValues(alpha: 0.6),
            margin: const EdgeInsets.symmetric(vertical: 10)),
        _infoRow2("1$cycleLabel 금액", "${NumberFormat('#,###').format(leaseAmt)} 원"),
        const SizedBox(height: 5),
        _infoRow2("총 $cycleLabel", "$leaseCycle $cycleLabel"),
        const SizedBox(height: 5),
        _infoRow2("총 리스비", "${NumberFormat('#,###').format(totalAmt)} 원"),
        const SizedBox(height: 5),
        _infoRow2("기간", "$startShort  ~  $endShort"),
        if (isDaily) ...[
          const SizedBox(height: 5),
          _infoRow2("납부 방식", "출금 시 자동 공제",
              vc: _lsInfoPinkColor,
              labelColor: _lsPayMethodLabelColor,
              labelFs: _lsPayMethodLabelFontSize),
        ],
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("진행 현황",
              style: TextStyle(
                  color: _lsProgressColor, fontSize: _lsProgressLabelFontSize)),
          RichText(
              text: TextSpan(children: [
            TextSpan(text: "$paidCount",
                style: const TextStyle(
                    color: _lsProgressColor,
                    fontSize: _lsProgressNumFontSize,
                    fontWeight: FontWeight.w700)),
            TextSpan(text: " / $totalCount $cycleLabel",
                style: const TextStyle(
                    color: _lsProgressColor, fontSize: _lsProgressTotalFontSize)),
          ])),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(_lsBarRadius),
          child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _lsBarTrackColor,
              valueColor: const AlwaysStoppedAnimation<Color>(_lsBarFillColor),
              minHeight: _lsBarHeight),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("납부 완료",
              style: TextStyle(color: _lsPaidLabelColor, fontSize: _lsPaidFontSize)),
          Text("${NumberFormat('#,###').format(paidAmt)} 원",
              style: const TextStyle(
                  color: _lsPaidLabelColor,
                  fontSize: _lsPaidFontSize,
                  fontWeight: FontWeight.w600)),
        ]),
        if (totalAmt > paidAmt) ...[
          const SizedBox(height: 3),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("잔여 금액",
                style: TextStyle(color: _lsRemainColor, fontSize: _lsRemainFontSize)),
            Text("${NumberFormat('#,###').format(totalAmt - paidAmt)} 원",
                style: const TextStyle(
                    color: _lsRemainColor, fontSize: _lsRemainFontSize)),
          ]),
        ],
        // 주1회/매월 납기일: 안내 + 입금완료 버튼 / 관리자 확인 대기중 (카드 안에 표시)
        if (!isDaily && hasTodayDue) ...[
          const SizedBox(height: 14),
          if (!riderAlreadyPaid) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: _lpDueBoxColor.withValues(alpha: _lpDueBoxBgAlpha),
                  borderRadius: BorderRadius.circular(_lpDueBoxRadius),
                  border: Border.all(
                      color: _lpDueBoxColor.withValues(alpha: _lpDueBoxBorderAlpha),
                      width: _lpDueBoxBorderWidth)),
              child: Row(children: [
                const Icon(Icons.notifications_active_rounded,
                    color: _lpDueBoxColor, size: _lpDueIconSize),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("오늘 리스비 납기일입니다!",
                      style: TextStyle(
                          color: _lpDueBoxColor,
                          fontSize: _lpDueTitleFontSize,
                          fontWeight: FontWeight.w700)),
                  Text(
                      "${NumberFormat('#,###').format(leaseAmt)}원 납부 부탁드립니다.",
                      style: const TextStyle(
                          color: _lpDueAmtColor, fontSize: _lpDueAmtFontSize)),
                ])),
              ]),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: _lpPayBtnHeight,
              child: GlassShineButton(
                label: "입금완료",
                onPressed: _submitting ? null : _submitPaid,
                loading: _submitting,
                accent: _teal,
                height: _lpPayBtnHeight,
                radius: _lpPayBtnRadius,
                fontSize: _lpPayBtnFontSize,
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _lpPaidBoxBg,
                borderRadius: BorderRadius.circular(_lpPaidRadius),
                border: Border.all(
                    color: _lpPaidBorderColor.withValues(alpha: _lpPaidBorderAlpha)),
              ),
              child: const Center(
                  child: Text("입금완료 처리됨 · 관리자 확인 대기중",
                      style: TextStyle(
                          color: _lpPaidTextColor,
                          fontSize: _lpPaidFontSize,
                          fontWeight: FontWeight.w600))),
            ),
        ],
      ]),
    );
  }

  Widget _infoRow2(String label, String value,
          {Color vc = _lsInfoValueColor,
          Color labelColor = _lsInfoLabelColor,
          double labelFs = _lsInfoFontSize}) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(color: labelColor, fontSize: labelFs)),
        Text(value,
            style: TextStyle(
                color: vc, fontSize: _lsInfoFontSize, fontWeight: FontWeight.w600)),
      ]);
}

// ═══════════════════════════════════════════════════════════════════════
// 8. 설정 페이지
// ═══════════════════════════════════════════════════════════════════════
class _SettingsPage extends StatefulWidget {
  final String uid;
  const _SettingsPage({required this.uid});
  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  Map<String, dynamic>? _data;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      if (mounted) setState(() {
        _data = doc.data();
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  // ── 8-2. 라벨 ──
  Widget _siLabel(String t) => Text(t,
      style: const TextStyle(color: _siLabelColor, fontSize: _siLabelFontSize));

  // 값 표시 배경박스(_appBg) — 표시되는 부분만 감쌈
  Widget _siValueBox(String value, {Color? valueColor}) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: _siBoxPadH, vertical: _siBoxPadV),
        decoration: BoxDecoration(
          color: _siBoxBg,
          borderRadius: BorderRadius.circular(_siBoxRadius),
          border: Border.all(color: _siBoxBorder, width: 1),
        ),
        child: Text(value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: valueColor ?? _siValueColor,
                fontSize: _siValueFontSize,
                fontWeight: FontWeight.w600)),
      );

  // 라벨 + 값박스 (전체폭: 값박스가 남는 폭만큼 늘어남)
  Widget _siField(String label, String value, {Color? valueColor}) => Row(
        children: [
          _siLabel(label),
          const SizedBox(width: _siLabelGap),
          Flexible(child: _siValueBox(value, valueColor: valueColor)),
        ],
      );

  // 행 위아래 여백 래퍼
  Widget _siRow(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: _siRowPadV),
        child: child,
      );

  Widget _siDivider() => Container(height: 1, color: _siDividerColor);

  // 불러온 정보 표시 (값마다 _appBg 배경박스)
  Widget _siInfoBox() {
    final name    = (_data?['name']          as String?)?.trim();
    final id      = (_data?['reportId']       as String?)?.trim();
    final email   = (_data?['email']          as String?)?.trim();
    final phone   = (_data?['phone']          as String?)?.trim();
    final bank    = (_data?['bankName']       as String?)?.trim();
    final account = (_data?['accountNumber']  as String?)?.trim();
    final vehicle   = (_data?['vehicleType']   as String?)?.trim();
    final insurance = (_data?['paidInsurance'] as String?)?.trim();
    String orDash(String? v) => (v == null || v.isEmpty) ? '-' : v;
    // 값이 있으면 실제 값, 없으면(구 계정) "준비중" 회색 표시
    Widget infoOrSoon(String label, String? v) =>
        (v == null || v.isEmpty)
            ? _siField(label, _siSoonText, valueColor: _siSoonColor)
            : _siField(label, v);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // 이름
      _siRow(_siField("이름", orDash(name))),
      _siDivider(),
      // ID (이름 밑 줄)
      _siRow(_siField("ID", orDash(id))),
      _siDivider(),
      _siRow(_siField("E.MAIL", orDash(email))),
      _siDivider(),
      _siRow(_siField("전화번호", orDash(phone))),
      _siDivider(),
      // 계좌번호: 은행명 박스 + 아래 줄에 계좌번호 박스
      _siRow(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _siField("계좌번호", orDash(bank)),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: _siAccountIndent),
          child: _siValueBox(orDash(account)),
        ),
      ])),
      _siDivider(),
      _siRow(infoOrSoon("운송수단", vehicle)),
      _siDivider(),
      _siRow(infoOrSoon("유상운송보험 가입유무", insurance)),
    ]);
  }

  // ── 8-1. 메인배경 + 내 정보 ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_spOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _spPanelColor,
              borderRadius: BorderRadius.circular(_spPanelRadius),
              border: Border.all(
                  color: _spPanelBorderColor.withValues(alpha: _spPanelBorderAlpha)),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_spPanelRadius),
              child: Column(children: [
                const SizedBox(height: 8),
                _pageHeader(context, "설정"),
                const SizedBox(height: _spGapHeaderToDiv),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: _spDivMarginH),
                  color: _elevated.withValues(alpha: 0.6),
                ),
                const SizedBox(height: _spGapDivToInfo),
                Expanded(
                    child: !_loaded
                        ? const Center(child: CircularProgressIndicator(color: _teal))
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(
                                _spListPadL, _spListPadT, _spListPadR, _spListPadB),
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Row(children: [
                                  Icon(Icons.person_outline_rounded,
                                      color: _spHeadIconColor, size: _spHeadIconSize),
                                  SizedBox(width: 8),
                                  Text("내 정보",
                                      style: TextStyle(
                                          color: _spHeadTitleColor,
                                          fontSize: _spHeadTitleFontSize,
                                          fontWeight: FontWeight.w700)),
                                ]),
                              ),
                              Container(
                                padding: const EdgeInsets.all(_siCardPadH),
                                decoration: BoxDecoration(
                                  color: _siCardBg,
                                  borderRadius: BorderRadius.circular(_siCardRadius),
                                  border: Border.all(color: _siCardBorder, width: 1),
                                  boxShadow: _cardShadow,
                                ),
                                child: _siInfoBox(),
                              ),
                            ],
                          ),
                  ),
                ]),
              ),
            ),
          ),
      ),
    );
  }
}