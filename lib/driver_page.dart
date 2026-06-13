import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'main.dart';
import 'glass_shine_button.dart';
import 'tokens.dart';
import 'app_dialogs.dart';
import 'driver_common.dart';
import 'settlement.dart';
import 'driver_settings_page.dart';
import 'driver_partners_page.dart';
import 'block_puzzle_game.dart';
import 'driver_timeline_page.dart';
import 'driver_lease_page.dart';
import 'driver_history_page.dart';
// ═══════════════════════════════════════════════════════════════════════
// 공통 색 팔레트 (tokens.dart 단일 출처를 가리키는 별칭)
// ═══════════════════════════════════════════════════════════════════════
const _appBg    = kAppBg;    // 전체 배경 (패널보다 살짝 밝게)
const _panel    = kPanel;    // 메인 배경 (inset 패널)
const _surface  = kSurface;  // 카드
const _elevated = kElevated; // 트랙 · 테두리
const _chip     = kChip;     // 칩 · 인풋 · 버튼 배경

const _text  = kText;
const _text2 = kText2;

const _teal     = kTeal;     // 민트 (메인 액센트)
const _purple   = kPurple;   // 보라
const _pink     = kPink;     // 핑크
const _amber    = kAmber;    // 노랑
const _dot      = Color(0xFFFBFBFB); // 차트 꼭짓점 흰 점(파일 고유)
const _red      = kRed;


// ── 보조 테두리(옅은) ──

// 카드 그림자: 오른쪽 + 아래 (여러 섹션 공통으로 쓰는 기본 그림자)
const List<BoxShadow> _cardShadow = kCardShadow;

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
const double _panelOuterPad    = 10;   // 패널 바깥 여백
const double _panelRadius      = 24;  // 패널 모서리 둥글기
const double _panelBorderWidth = 1;   // 테두리 두께
const double _panelPadL = 11;  // 안쪽 여백 왼쪽
const double _panelPadT = 12;  // 안쪽 여백 위 (관리자 페이지와 통일)
const double _panelPadR = 11;  // 안쪽 여백 오른쪽
const double _panelPadB = 8;  // 안쪽 여백 아래
// ── 그림자 ──
const List<BoxShadow> _panelShadow = kPanelShadow;
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
const double _gapGreetToChart     = 6;  // 안녕하세요 ↔ 차트카드 간격 (관리자 페이지와 통일)
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
const Color  _chartCardBorder      = _elevated;  // 카드 테두리 색
const double _gapChartToNotice = 12;  // 차트카드 ↔ 공지사항 간격
const double _chartCardRadius      = 14;   // 카드 모서리
const double _chartCardBorderWidth = 1;    // 카드 테두리 두께
const double _chartCardPadL = 10;   // 카드 안쪽 여백 왼쪽
const double _chartCardPadT = 12;  // 카드 안쪽 여백 위
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
const Color  _togUnselColor  = _text2;    // 미선택 글씨 색
const Color  _togUnselBorder = _elevated; // 미선택 테두리 색
// ── 목표 버튼 ──
// 색은 일간/주간/월간 토글 색(_periodColor)을 그대로 따라감 (아래 _targetButton 참고)
const double _targetFontSize   = 11;   // 목표 글씨 크기
const double _targetPadH       = 11;   // 좌우 여백
const double _targetPadV       = 5;    // 위아래 여백
const double _targetRadius     = 20;   // 모서리
const double _targetBgAlpha    = 0.12; // 배경 투명도
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
// 프레임 (빛 흐르는 테두리)
const Color  _wfGold        = Color(0xFFFFD372); // 골드
const Color  _wfGoldText2   = Color(0xFFFFEAB0); // 금액 골드 그라데이션 끝색
const Color  _wfGoldDeep    = Color(0xFFF4B64C); // 진한 골드(버튼 시작)
const Color  _wfPink        = Color(0xFFFF5FC4); // 핑크
const Color  _wfPurple      = Color(0xFF9D7BFF); // 보라
const Color  _wfInnerTop    = Color(0xFF141A30); // 안쪽 배경 위
const Color  _wfInnerBottom = Color(0xFF10142A); // 안쪽 배경 아래
const double _wfRadius      = 14;   // 프레임 모서리
const double _wfBorderWidth = 1.5;  // 테두리(빛) 두께
const int    _wfFlowMs      = 3500; // 빛 한 바퀴 도는 시간(ms, 작을수록 빠름)
// 금액 글씨
const double _wfAmtLeftGap      = 34; // 금액 왼쪽 여백(오른쪽으로 밀기)
const double _wfAmtFontSize     = 26; // 금액 숫자 크기
const double _wfAmtUnitFontSize = 13; // " 원" 크기
// 출금신청 버튼
const double _wfBtnFontSize = 14; // 버튼 글씨 크기
const double _wfBtnPadH     = 20;   // 버튼 좌우 여백
const double _wfBtnPadV     = 6;   // 버튼 위아래 여백
const double _wfBtnRadius   = 12;   // 버튼 모서리
// ── 출금신청 확인 다이얼로그 (출금신청 버튼 누르면 뜨는 확인창) ──
const Color  _wdlgBg            = _surface;   // 배경색
const Color  _wdlgBorderColor   = _elevated;   // 테두리 색
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
const double _gapNoticeToMenu  = 1;  // 공지사항 ↔ 정산내역 간격
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
const double _ntcHeaderBottomGap = 6;     // 헤더-내용 사이 간격
const double _ntcItemGap       = 6;        // 공지 항목 사이 간격
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

// ═══════════════════════════════════════════════════════════════════════
// 7-1. 리스비 페이지 - 메인배경 + 알림/버튼 (조정값)
// ═══════════════════════════════════════════════════════════════════════
const double _menuLsPadV = 12;  // [7] 리스비 카드 내부 위아래 여백


// ═══════════════════════════════════════════════════════════════════════
// 8-1. 설정 페이지 - 메인배경 + 내 정보 헤더 (조정값)
// ═══════════════════════════════════════════════════════════════════════


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
const Color  _blAdminBubbleBg = _chip;   // 관리자 말풍선 배경
const Color  _blAdminBorderColor = _elevated; // 관리자 말풍선 테두리
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
String _fmt(double v) => fmtAbs(v); // 공용 위임 (driver_common.dart)

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

// 공용 위임 (driver_common.dart)
void _showInfoDialog(BuildContext context, String msg) => showInfoDialog(context, msg);

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
  bool _withdrawSubmitting = false; // 출금신청 저장 중 잠금 (중복 신청 방지)
  List<Map<String, dynamic>> _unpaidItems = [];
  double _unpaidTotal    = 0;
  double _leaseDailyAmt  = 0;        // 일일 리스비 (0이면 미적용)
  DateTime? _leaseStart, _leaseLast; // 리스비 적용기간 (리포트 날짜 기준)
  double _etcDailyAmt    = 0;        // 일일 기타
  DateTime? _etcStart, _etcLast;     // 기타 적용기간
  DateTime? _unpaidUpdatedAt; // 미출금(unpaid_balance) 마지막 업로드 시각

  // ── 실시간 구독 (관리자 입금완료/미출금 업로드 → 차트·금액 즉시 반영) ──
  StreamSubscription<QuerySnapshot>?    _settlementSub;
  StreamSubscription<DocumentSnapshot>? _unpaidSub;
  // ── 실시간 구독 (앱 점검 on/off·공지 → 세션 중 즉시 반영) ──
  StreamSubscription<DocumentSnapshot>? _appStatusSub;
  StreamSubscription<DocumentSnapshot>? _noticeSub;

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
    _listenAppStatus();
    _loadUser();
    _listenNotice();
    _attachWithdrawListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeductDue(
          collection: 'lease_payments', typeField: 'leaseType', title: '리스비');
      _checkDeductDue(
          collection: 'etc_payments', typeField: 'etcType', title: '기타', delayMs: 900);
    });
  }

  // 관리자 입금완료(정산로그)·미출금 업로드 변경을 실시간 감지 → 차트/금액 자동 갱신
  void _attachWithdrawListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _loadWithdrawState();
      return;
    }
    _settlementSub = FirebaseFirestore.instance
        .collection('admin_settlement_logs')
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .listen((_) => _loadWithdrawState());
    _unpaidSub = FirebaseFirestore.instance
        .collection('unpaid_balance')
        .doc(user.uid)
        .snapshots()
        .listen((_) => _loadWithdrawState());
  }

  @override
  void dispose() {
    _settlementSub?.cancel();
    _unpaidSub?.cancel();
    _appStatusSub?.cancel();
    _noticeSub?.cancel();
    _balloonCtrl.dispose();
    _chatScrollCtrl.dispose();
    super.dispose();
  }

  // ── 데이터 로드 ─────────────────────────────────────────────────────
  // 앱 점검 on/off 실시간 구독 (운영자가 끄면 점검화면으로 즉시 전환)
  void _listenAppStatus() {
    _appStatusSub = FirebaseFirestore.instance
        .collection('system_settings').doc('app_status').snapshots()
        .listen((doc) {
      if (mounted) {
        setState(() {
          _isAppOn = doc.data()?['isAppOn'] ?? true;
          _appLoaded = true;
        });
      }
    }, onError: (_) {
      if (mounted) setState(() => _appLoaded = true);
    });
  }

  // 점검화면 "새로고침" 버튼용 1회성 재조회 (평소엔 위 실시간 리스너가 자동 갱신)
  Future<void> _refreshAppStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('system_settings').doc('app_status').get();
      if (mounted) setState(() => _isAppOn = doc.data()?['isAppOn'] ?? true);
    } catch (_) {}
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) setState(() => _riderName = doc.data()?['name'] ?? '');
    } catch (_) {}
  }

  // 공지 실시간 구독 (운영자가 공지 올리면 세션 중 즉시 반영)
  void _listenNotice() {
    _noticeSub = FirebaseFirestore.instance
        .collection('system_settings').doc('notice').snapshots()
        .listen((doc) {
      if (!doc.exists) return;
      final content   = doc.data()?['content']  as String? ?? '';
      final isVisible = doc.data()?['isVisible'] as bool?   ?? false;
      if (mounted) setState(() => _noticeText = isVisible ? content : '');
    });
  }

  Future<void> _loadWithdrawState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).get();
      _riderName = userDoc.data()?['name'] ?? _riderName;

      // 리스비·기타 공제 = 일일액 + 적용기간(리포트 날짜로 가름). "오늘" 게이트 제거.
      final leaseType = userDoc.data()?['leaseType']   as String? ?? '';
      final leaseAmt  = userDoc.data()?['leaseAmount'] as int?    ?? 0;
      if (leaseType == 'daily' && leaseAmt > 0) {
        _leaseDailyAmt = leaseAmt.toDouble();
        _leaseStart = DateTime.tryParse(userDoc.data()?['leaseStartDate'] as String? ?? '');
        _leaseLast  = DateTime.tryParse(userDoc.data()?['leaseLastDate']  as String? ?? '');
      }

      final etcType = userDoc.data()?['etcType']   as String? ?? '';
      final etcAmt  = userDoc.data()?['etcAmount'] as int?    ?? 0;
      if (etcType == 'daily' && etcAmt > 0) {
        _etcDailyAmt = etcAmt.toDouble();
        _etcStart = DateTime.tryParse(userDoc.data()?['etcStartDate'] as String? ?? '');
        _etcLast  = DateTime.tryParse(userDoc.data()?['etcLastDate']  as String? ?? '');
      }

      final pending = await FirebaseFirestore.instance
          .collection('withdrawal_requests')
          .where('uid',    isEqualTo: user.uid)
          .where('status', isEqualTo: '요청대기')
          .limit(1).get();
      final requested = pending.docs.isNotEmpty;

      List<Map<String, dynamic>> items = [];
      double total = 0;
      DateTime? updatedAt;
      if (!requested) {
        final doc = await FirebaseFirestore.instance
            .collection('unpaid_balance').doc(user.uid).get();
        if (doc.exists) {
          final raw = doc.data()?['items'] as List<dynamic>? ?? [];
          items = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          total = (doc.data()?['totalAmount'] as num?)?.toDouble() ?? 0;
          updatedAt = (doc.data()?['updatedAt'] as Timestamp?)?.toDate();
        }
      }

      if (mounted) {
        setState(() {
          _withdrawRequested = requested;
          _unpaidItems       = items;
          _unpaidTotal       = total;
          _adminUploaded     = items.isNotEmpty;
          _unpaidUpdatedAt   = updatedAt;
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

      void addItems(List<dynamic> items, double leaseDeduction, double etcDeduction) {
        final perDayLease =
            items.isNotEmpty ? leaseDeduction / items.length : 0.0;
        final perDayEtc =
            items.isNotEmpty ? etcDeduction / items.length : 0.0;
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
              perDayLease -
              perDayEtc;
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
            (d['leaseDeduction'] as num?)?.toDouble() ?? 0,
            (d['etcDeduction'] as num?)?.toDouble() ?? 0);
      }
      // 차트는 입금완료(지급완료) 분만 표시 — 미출금 업로드분(_unpaidItems)은 제외

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

  Future<void> _checkDeductDue(
      {required String collection,
      required String typeField,
      required String title,
      int delayMs = 500}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final snap = await FirebaseFirestore.instance
          .collection(collection)
          .where('uid',     isEqualTo: user.uid)
          .where('dueDate', isEqualTo: today)
          .where('isPaid',  isEqualTo: false).get();
      if (snap.docs.isNotEmpty) {
        final d    = snap.docs.first.data();
        final type = (d[typeField] as String?) ?? '';
        if (type == 'daily') return;
        final amt = d['amount'] as int? ?? 0;
        final cyc = d['cycle']  as int? ?? 0;
        if (!mounted) return;
        Future.delayed(Duration(milliseconds: delayMs), () {
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
                    color: _surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _elevated, width: 1)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    const Icon(Icons.moped, color: _pink, size: 20),
                    const SizedBox(width: 8),
                    Text("$title 납부일 안내",
                        style: const TextStyle(color: _pink, fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 4),
                  const Divider(color: _elevated, height: 16),
                  Text(
                      "오늘은 $cyc회차 납부일입니다\n${NumberFormat('#,###').format(amt)}원 납부 부탁드립니다.",
                      style: const TextStyle(color: _text, fontSize: 13, height: 1.7),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // 상담 말풍선이 열려 있으면 먼저 닫기
        if (_showBalloon) {
          setState(() => _showBalloon = false);
          return;
        }
        // 메인 페이지 → 종료 확인 (서브 페이지는 기본 동작으로 메인 복귀)
        if (await showExitConfirmDialog(context)) {
          await minimizeApp(); // 종료 대신 백그라운드 → 위치 추적 계속
        }
      },
      child: Scaffold(
      backgroundColor: _bgScaffold,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(children: [
          Expanded(
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
                          MaterialPageRoute(builder: (_) => HistoryPage(uid: uid)));
                    }, padV: _menuStPadV),
                    const SizedBox(height: kGapCard),
                    // ── 7. 리스비 카드 (리스비+기타 현황 모두 표시) ──
                    _deductMenuCard(uid),
                    // (하단 4버튼은 화면 하단에 고정 — Column 아래 _bottomMenuCard)
                  ],
                ),
              ),
            ),
          ),
          _buildFABArea(uid, bottomInset),
            ]),
          ),
          // ── 하단 고정 4버튼 바 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                _panelOuterPad, 0, _panelOuterPad, _panelOuterPad),
            child: _bottomMenuCard(uid),
          ),
        ]),
      ),
      ),
    );
  }

  // ── 3. 인사 ─────────────────────────────────────────────────────────
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
            child: Text.rich(
              TextSpan(children: [
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
        ]);


  // 미출금 항목 하루치 소계 (정산내역 카드 맨 아래 "소계"와 동일한 계산식)
  //  소계 = 배달수수료 + 지원금 − 세금 − (출금수수료+협력사수수료) − 시간제보험 − 리스비(일)
  // ── 4. 차트 카드 ────────────────────────────────────────────────────
  // 정산 계산 단일 출처(settlement.dart) — 기사 프레임·출금신청이 같은 함수를 쓴다
  SettlementResult _settle() => computeSettlement(
        _unpaidItems,
        DeductionConfig(_leaseDailyAmt, _leaseStart, _leaseLast),
        DeductionConfig(_etcDailyAmt, _etcStart, _etcLast),
        grossOverride: _unpaidTotal,
      );

  Widget _chartCard(_PeriodData d) {
    final accent = _periodColor[_period];
    final up = d.delta >= 0;
    // 출금 가능액 = 미출금(누적) − 리스비 − 기타 (정산내역 '미출금'과 동일 계산)
    final withdrawable = _settle().net;

    // ── 차트 큰 금액 = 해당 기간(일/주/월) 입금완료 합계 (미출금분 제외) ──
    final headlineAmount = d.total;
    final pct = (headlineAmount / _targets[_period]).clamp(0.0, 1.0);

    // ── 출금 프레임: 업로드됐고 + 아직 신청 안 했을 때 (일간·주간·월간 모두 표시) ──
    final showWithdrawRow = _adminUploaded && !_withdrawRequested;
    // 출금신청 마감: 업로드된 날의 23:00이 지나면 비활성 (밤새·새벽 포함, 누적금액은 계속 표시)
    // 다음 리포트가 올라오면 updatedAt이 새 날짜로 바뀌어 그날 23:00까지 다시 활성
    final upAt = _unpaidUpdatedAt;
    final timeOpen = upAt == null
        ? DateTime.now().hour < 23
        : DateTime.now().isBefore(DateTime(upAt.year, upAt.month, upAt.day, 23));
    // 출금 가능액이 1만원 미만(마이너스 포함)이면 출금 불가 — _confirmWithdraw의 최소금액과 동일
    final belowMin = withdrawable < 10000;
    final canWithdraw = timeOpen && !belowMin;
    final disabledLabel = belowMin ? '출금 불가' : '23시 마감';

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
          Container(height: 1, color: _elevated),
          const SizedBox(height: 12),
          _WithdrawFrame(amount: withdrawable.round(), onWithdraw: _onWithdrawTap, enabled: canWithdraw, disabledLabel: disabledLabel),
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
                        ? c
                        : _togUnselBorder),
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
          border: Border.all(color: c),
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
                color: _wdlgBorderColor,
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
    if (_withdrawSubmitting) return; // 이미 저장 중이면 중복 실행 차단
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_unpaidItems.isEmpty) {
      _showInfoDialog(context, "출금 가능한 내역이 없습니다.");
      return;
    }

    final s = _settle();
    final leaseDeduct = s.leaseTotal;
    final etcDeduct   = s.etcTotal;
    final finalTotal  = s.net;
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
        "${etcDeduct > 0 ? '기타(일): ${_fmt(etcDeduct)}원\n' : ''}"
        "최종배달수수료: ${_fmt(finalTotal)}원\n"
        "최종출금금액: ${_fmt(finalTotal)}원";

    _withdrawSubmitting = true; // 저장 시작 → 잠금
    try {
      await FirebaseFirestore.instance.collection('withdrawal_requests').add({
        'uid':            user.uid,
        'riderName':      _riderName.isNotEmpty ? _riderName : "라이더님",
        'date':           lastDate,
        'dates':          datesList,
        'amount':         finalTotal,
        'totalAmount':    _unpaidTotal,
        'leaseDeduction': leaseDeduct,
        'etcDeduction':   etcDeduct,
        'items':          _unpaidItems,
        'message':        msg,
        'status':         '요청대기',
        'timestamp':      FieldValue.serverTimestamp(),
      });
      // 신청 완료 → 출금신청 줄 사라짐 (별도 확인창 없음)
      if (mounted) setState(() => _withdrawRequested = true);
    } catch (_) {
      if (mounted) _showInfoDialog(context, "출금 신청 실패. 다시 시도해 주세요.");
    } finally {
      _withdrawSubmitting = false; // 성공·실패 무관하게 잠금 해제
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

  // ── 공지사항 ──────────────────────────────────────────────────────
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

  // ── 정산내역 · 설정 메뉴 카드 ─────────────────────────────────
  Widget _menuCard(String title, IconData icon, Color iconColor, VoidCallback onTap,
          {double padV = 16}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: padV),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _elevated, width: 1),
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

  // ── 하단 4버튼 카드 (관리자 페이지 하단 메뉴와 동일 스타일) ──
  //  설정 | 미니게임 | 타임라인 | 준비중
  Widget _bottomMenuCard(String uid) {
    Widget divider() => Container(width: 1, height: 36, color: _elevated);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _elevated, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Row(children: [
        Expanded(
            child: _bottomMenuItem(Icons.settings, _purple, "설정",
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SettingsPage(uid: uid))))),
        divider(),
        Expanded(
            child: _bottomMenuItem(Icons.handshake_rounded, _pink, "협력업체",
                () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const DriverPartnersPage())))),
        divider(),
        Expanded(
            child: _bottomMenuItem(Icons.sports_esports_rounded, _teal, "미니게임",
                () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => BlockPuzzleGame(uid: uid))))),
        divider(),
        Expanded(
            child: _bottomMenuItem(Icons.timeline_rounded, _amber, "타임라인",
                () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => DriverTimelinePage(uid: uid))))),
      ]),
    );
  }

  Widget _bottomMenuItem(IconData icon, Color color, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: _text, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );

  // ── 리스비 메뉴 카드 (리스비+기타 현황 페이지로 이동, 배지는 각각 표시) ──
  // 회차별 판정: 매일=리포트 최신 날짜(anchor) / 주1회·매월=실제 오늘 날짜 (리스비 페이지와 동일)
  bool _anyDue(QuerySnapshot? snap, String typeField) {
    final anchor = _reportAnchor();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return snap?.docs.any((dDoc) {
          final m = dDoc.data() as Map;
          final dd = m['dueDate'] as String? ?? '';
          if (dd.isEmpty) return false;
          final base = (m[typeField] as String?) == 'daily' ? anchor : today;
          return base.isNotEmpty && dd.compareTo(base) <= 0;
        }) ??
        false;
  }

  // 매일 타입 배지 기준일 = 업로드된 리포트 중 최신 날짜(미출금 항목 기준).
  // (오늘 기준이면 익일 업로드 전에 하루 먼저 떠서, 리포트 날짜 기준으로 맞춤)
  String _reportAnchor() => _unpaidItems.isEmpty
      ? ''
      : _unpaidItems
          .map((e) => (e['date'] as String?) ?? '')
          .reduce((a, b) => b.compareTo(a) > 0 ? b : a);

  // 라벨 + 우상단 N 배지
  Widget _lblBadge(String text, bool due) =>
      Stack(clipBehavior: Clip.none, children: [
        Text(text,
            style: const TextStyle(
                color: _text, fontSize: 14, fontWeight: FontWeight.w600)),
        if (due)
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
      ]);

  Widget _deductMenuCard(String uid) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lease_payments')
            .where('uid', isEqualTo: uid)
            .where('isPaid', isEqualTo: false)
            .snapshots(),
        builder: (_, leaseSnap) => StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('etc_payments')
              .where('uid', isEqualTo: uid)
              .where('isPaid', isEqualTo: false)
              .snapshots(),
          builder: (_, etcSnap) {
            final leaseDue = _anyDue(leaseSnap.data, 'leaseType');
            final etcDue   = _anyDue(etcSnap.data, 'etcType');
            return GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => DriverLeasePage(uid: uid))),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: _menuLsPadV),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _elevated, width: 1),
                  boxShadow: _cardShadow,
                ),
                child: Row(children: [
                  const Icon(Icons.moped, color: _pink, size: 24),
                  const SizedBox(width: 14),
                  _lblBadge('리스비', leaseDue),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text('/',
                        style: TextStyle(
                            color: _text2, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  _lblBadge('기타', etcDue),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: _text2, size: 22),
                ]),
              ),
            );
          },
        ),
      );

  // ── FAB & 1:1 상담 풍선창 ──────────────────────────────────────────
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
            border: Border(top: BorderSide(color: _teal)),
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
                          color: _blInputBorderColor),
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
                      color: _balloonSending ? _elevated : _teal, width: 0.8),
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
                  ? _blRiderBubbleBg
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
              border: Border.all(color: _elevated, width: 1)),
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
                onPressed: _refreshAppStatus,
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
// 추가. 출금 그라디언트 프레임 (빛 흐르는 테두리 + 금액 + 출금신청)
// ═══════════════════════════════════════════════════════════════════════
class _WithdrawFrame extends StatefulWidget {
  final int amount;
  final VoidCallback onWithdraw;
  final bool enabled; // false → 버튼 비활성(금액은 계속 표시)
  final String disabledLabel; // 비활성 사유 글자 (23시 마감 / 출금 불가)
  const _WithdrawFrame({required this.amount, required this.onWithdraw, this.enabled = true, this.disabledLabel = '23시 마감'});
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
    // 비활성(23시 이후): 발광 애니메이션 없이 정적 프레임
    if (!widget.enabled) return _frame(0, false);
    return AnimatedBuilder(
      animation: _flow,
      builder: (context, _) => _frame(_flow.value, true),
    );
  }

  Widget _frame(double rotation, bool enabled) {
    final amtStr = NumberFormat('#,###').format(widget.amount);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_wfRadius),
        // 활성: 빛이 흐르는 골드→핑크→퍼플 테두리 / 비활성: 정적 회색 테두리
        gradient: enabled
            ? SweepGradient(
                transform: GradientRotation(rotation * 2 * math.pi),
                colors: const [_wfGold, _wfPink, _wfPurple, _wfGold],
              )
            : null,
        color: enabled ? null : _elevated,
        boxShadow: enabled
            ? const [
                BoxShadow(
                    color: Color(0x55FF5FC4),
                    blurRadius: 16,
                    spreadRadius: -6,
                    offset: Offset(0, 8)),
              ]
            : null,
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
        padding: const EdgeInsets.fromLTRB(16, 11, 13, 11),
        child: Row(children: [
          const SizedBox(width: _wfAmtLeftGap),
          // 금액 (골드 그라데이션 글씨) — 비활성이어도 누적금액은 계속 표시
          ShaderMask(
            shaderCallback: (r) =>
                const LinearGradient(colors: [_wfGold, _wfGoldText2]).createShader(r),
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
          if (enabled)
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
            )
          else
            // 비활성: 23시 마감 / 출금 불가 (회색, 누를 수 없음)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: _wfBtnPadH, vertical: _wfBtnPadV),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_wfBtnRadius),
                color: _chip,
                border: Border.all(color: _elevated),
              ),
              child: Text(widget.disabledLabel,
                  style: const TextStyle(
                      color: _text2,
                      fontSize: _wfBtnFontSize,
                      fontWeight: FontWeight.w700)),
            ),
        ]),
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

