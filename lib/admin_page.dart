import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border, BorderStyle, TextSpan;
import 'main.dart';
import 'glass_shine_button.dart';

// ═══════════════════════════════════════════════════════════════════════
// 공통 색 팔레트 (모든 섹션 공유)
// ═══════════════════════════════════════════════════════════════════════
const _surface  = Color(0xFF0D1427); // 카드
const _elevated = Color(0xFF303854); // 트랙 · 테두리
const _text  = Color(0xFFFBFBFB);
const _text2 = Color(0xFF787C8D);
const _teal     = Color(0xFF4AE3ED); // 민트 (메인 액센트)
const _purple   = Color(0xFF9F66E6); // 보라
const _pink     = Color(0xFFE672BA); // 핑크
const _amber    = Color(0xFFE6C97F); // 노랑
const _orange   = Color(0xFFE08F2A);  // 테두리 강조
const _borderDim = Color(0x33303854); // 보조 테두리(옅은)
// 카드 그림자 (모든 카드 공통)
const List<BoxShadow> _cardShadow = [
  BoxShadow(color: Color(0xD9000000), blurRadius: 11, offset: Offset(4, 6)),
];

// ═══════════════════════════════════════════════════════════════════════
// 1. 전체배경
// ═══════════════════════════════════════════════════════════════════════
const _appBg    = Color(0xFF090E1A); // 전체 화면 Scaffold 배경색

// ═══════════════════════════════════════════════════════════════════════
// 2. 메인배경 (inset 패널) — 모든 페이지 공통
// ═══════════════════════════════════════════════════════════════════════
const _panel    = Color(0xFF070C18); // 메인 배경(패널) 배경색
// 메인 패널 그림자
const List<BoxShadow> _panelShadow = [
  BoxShadow(color: Color(0xFF18203A), blurRadius: 11, offset: Offset(4, 6)),
];
// 메인 패널 테두리·여백
const Color  _panelBorderColor = _elevated; // 패널 테두리 색
const double _panelBorderAlpha = 1.0;        // 패널 테두리 투명도 (1.0=솔리드)
const double _panelBorderWidth = 1;          // 패널 테두리 두께
const double _panelOuterPad    = 10;
const double _panelRadius      = 24;
// 서브페이지 헤더 아래 경계선 (더보기·출금신청·라이더관리·공제설정·공지사항 공통)
const Color  _subDivColor       = _elevated; // 경계선 색
const double _subDivMarginH     = 15;        // 경계선 좌우 여백(끝까지 안 붙음)
const double _subGapHeaderToDiv = 6;         // (더보기 전용) 뒤로가기 ↔ 경계선 갭
const double _subGapDivToBody   = 0;         // (더보기 전용) 경계선 ↔ 내용 갭
// 페이지별 헤더↔경계선 / 경계선↔카드 갭 (각자 따로 조정)
const double _wrPageGapHeaderDiv = 0; const double _wrPageGapDivCard = 4; // 출금신청
const double _rmPageGapHeaderDiv = 0; const double _rmPageGapDivCard = 4; // 라이더관리
const double _stPageGapHeaderDiv = 0; const double _stPageGapDivCard = 0; // 공제설정
const double _ntPageGapHeaderDiv = 0; const double _ntPageGapDivCard = 4; // 공지사항
// 탭 ↔ 첫 카드 갭 (페이지별)
const double _wrTabToCardGap    = 2; // 출금신청 탭 ↔ 카드 갭
const double _rmTabToCardGap    = 2; // 라이더 탭 ↔ 이름목록 카드 갭
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
const _tabIndicatorBorder = _elevated;   // 선택탭 테두리
const _tabSelColor        = _teal;   // 선택 탭 글씨(민트)
const _tabUnselColor      = _text2;    // 미선택 탭 글씨
const double _tabFontSize        = 14; // 탭 글씨 크기
const double _tabTrackRadius     = 10; // 트랙 모서리
const double _tabIndicatorRadius = 7;  // 선택탭 모서리
const double _tabTrackPad        = 3;  // 트랙 안쪽 여백
// ── [7-1] 출금신청 카드 ──
const _wrCardBg     = _surface;
const _wrCardBorder = _elevated;
const double _wrCardRadius = 14;   // 카드 모서리
const double _wrCardGap    = 10;   // 카드 사이 간격
const double _wrHeadPadH   = 16;   // 헤더 좌우 여백
const double _wrHeadPadV   = 13;   // 헤더 위아래 여백
const _wrNameColor  = _teal;     // 이름 글씨 색
const double _wrNameFontSize  = 17;// 이름 글씨 크기
const _wrTitleColor = _text;      // "님의 출금 신청" 글씨 색
const double _wrTitleFontSize = 15;// "님의 출금 신청" 글씨 크기
const _wrDateColor  = _text2;      // 날짜 글씨 색
const double _wrDateFontSize  = 11;// 날짜 글씨 크기
const _wrAmtColor   = _teal;     // 헤더 금액 숫자 색
const double _wrAmtFontSize    = 14;// 헤더 금액 숫자 크기
const _wrDaysColor  = _text2;      // "N일 합산" 글씨 색
const double _wrDaysFontSize   = 10;// "N일 합산" 글씨 크기
// 펼침: 계좌·최종출금금액 행
const _wrBankColor      = _amber;     // 은행명 글씨 색(박스 없음)
const double _wrBankFontSize     = 12; // 은행명 글씨 크기
const _wrAcctNumColor   = _text;       // 계좌번호 글씨 색(박스 안)
const double _wrAcctNumFontSize  = 13; // 계좌번호 글씨 크기
const _wrFinalLabelColor = _amber;    // "최종출금금액" 라벨 색
const double _wrFinalLabelFontSize = 12;// "최종출금금액" 라벨 크기
const _wrFinalAmtColor  = _text;       // 최종출금금액 숫자 색
const double _wrFinalAmtFontSize = 12; // 최종출금금액 숫자 크기
const _wrValBoxBg       = _surface;      // 값 박스 배경(블랙)
const _wrValBoxBorder   = _elevated;   // 값 박스 테두리
const double _wrValBoxRadius = 6;      // 값 박스 모서리
const double _wrValBoxPadH   = 8;      // 값 박스 좌우 여백
const double _wrValBoxPadV   = 4;      // 값 박스 위아래 여백
const _wrCopyBorder     = _elevated;   // 복사 버튼 테두리 색
const double _wrCopyBorderWidth = 1;   // 복사 버튼 테두리 두께
// 카드 테두리·헤더 줄 간격
const double _wrCardBorderWidth = 1;   // 카드 테두리 두께
const double _wrGapNameDate    = 2;    // 이름줄 ↔ 날짜 갭
const double _wrGapAmtChevron  = 8;    // 금액 ↔ 펼침아이콘 갭
const double _wrChevronSize    = 18;   // 펼침 아이콘 크기
const _wrChevronColor          = _text2; // 펼침 아이콘 색
const _wrDividerColor          = _borderDim; // 헤더 ↔ 내용 구분선 색
const double _wrGapAcctFinal   = 8;    // 계좌행 ↔ 최종금액 갭
const double _wrGapFinalItems  = 10;   // 최종금액 ↔ 날짜상세 갭
// 날짜별 상세 내역 행
const double _wrItemGap        = 6;    // 날짜 카드 사이 갭
const _wrItemChipColor         = _teal; // 날짜칩 글씨 색
const double _wrItemChipFontSize = 11; // 날짜칩 글씨 크기
const double _wrItemChevronSize  = 15; // 날짜 펼침 아이콘 크기
const _wrItemAmtColor          = _text; // 날짜 합계 색
const double _wrItemAmtFontSize  = 12; // 날짜 합계 크기
const _wrDtMainColor           = _text; // "배달수수료(세전)" 색
const double _wrDtMainFontSize   = 12; // "배달수수료(세전)" 크기
const _wrDtTogLabelColor       = _text; // 토글 라벨 색
const double _wrDtTogFontSize    = 12; // 토글 글씨 크기
const double _wrDtTogIconSize    = 14; // 토글 아이콘 크기
const _wrDtSubColor            = _text2; // 하위행(subRow) 색
const double _wrDtSubFontSize    = 11; // 하위행 글씨 크기
const _wrDtSubtotalColor       = _teal; // 소계 색
const double _wrDtSubtotalLabelFontSize = 12; // 소계 라벨 크기
const double _wrDtSubtotalValueFontSize = 13; // 소계 값 크기
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
// ── [8-1] 라이더탭 — 목록 카드 + 행 헤더 ──
const _rmCardBg     = _surface;    // 목록 카드 배경색
const _rmCardBorder = _elevated;     // 목록 카드 테두리 색
const double _rmCardBorderWidth = 1; // 목록 카드 테두리 두께
const double _rmCardRadius = 14;   // 목록 카드 모서리
const _rmSearchBg    = _surface;     // 검색창 배경
const _rmSearchHint  = _text2;     // 검색 힌트 색
const double _rmSearchFontSize = 13; // 검색 글씨 크기
const _rmDividerColor = _borderDim; // 라이더 행 구분선 색
const _rmAvatarBg     = _surface; // 아바타 배경
const _rmAvatarBorder = _elevated;   // 아바타 테두리
const _rmAvatarText   = _teal;   // 아바타 글씨(이니셜) 색
const double _rmAvatarSize     = 34; // 아바타 크기
const double _rmAvatarFontSize = 14; // 아바타 글씨 크기
const _rmNameColor    = _text;    // 라이더 이름 색
const double _rmNameFontSize = 13; // 라이더 이름 크기
const _rmHistBtnColor = _teal;   // "출금내역" 버튼 글씨·아이콘 색
const _rmHistBtnBorder = _elevated;  // "출금내역" 버튼 테두리
const double _rmHistBtnFontSize = 13; // "출금내역" 버튼 글씨 크기
const _rmCallColor    = _pink;    // 전화 아이콘 색
const _rmSmsColor     = _amber;    // 문자 아이콘 색
// 라이더 카드 펼침 내용 (계좌·ID·리스비 폼)
const _rmFieldTextColor   = _text2; // 은행·계좌·ID 입력 글씨 색
const double _rmFieldFontSize = 13; // 은행·계좌·ID 입력 글씨 크기
const double _rmEditBtnFontSize = 12; // 수정/저장 버튼 글씨 크기
const double _rmGapRow      = 8;    // 폼 행 사이 갭(기본)
const double _rmGapRowSmall = 6;    // 폼 행 사이 갭(좁게)
const double _rmGapToLease  = 10;   // ID행 ↔ 리스비 섹션 갭
const _rmLeaseTitleColor    = _teal; // "리스비" 라벨 색
const double _rmLeaseTitleFontSize = 11; // "리스비" 라벨 크기
const _rmLeaseSmallBtnColor = _text2; // 초기화 등 작은 버튼 글씨 색
const double _rmLeaseBtnFontSize = 10;  // 리스비 작은 버튼·칩 글씨 크기
const double _rmLeaseInputFontSize = 11;// 리스비 입력칸 글씨 크기
const double _rmLeaseHintFontSize  = 10;// 리스비 입력 힌트 크기
const _rmLeaseUnitColor     = _text2; // 단위(일/회차/원) 색
const double _rmLeaseUnitFontSize = 10; // 단위 글씨 크기
const double _rmLeasePaidFontSize = 11; // 납부이력 글씨 크기
// ── [8-2] 리스비탭 — 납기 현황 카드 ──
const double _laListPadL = 15;  // 목록 바깥 여백 왼
const double _laListPadT = 4;  // 위
const double _laListPadR = 15;  // 오른
const double _laListPadB = 15;  // 아래
const _laInfoLabelColor = _text;  // 정보 행 라벨 색
const _laInfoValueColor = _text;  // 정보 행 값 색(기본)
const double _laInfoFontSize = 12;// 정보 행 글씨 크기
const double _laBtnHeight = 38;   // 버튼 높이
const double _laBtnRadius = 22;   // 버튼 모서리
const double _laBtnFontSize = 12; // 버튼 글씨 크기
// 리스비 카드 내용 (글씨·테두리)
const double _laRiderNameFontSize = 14; // 라이더 이름 칩 글씨 크기
const double _laBadgeFontSize  = 10;    // 상태·타입 뱃지 글씨 크기
const _laCardBorder            = Color(0x4D303854); // 전체현황 카드 테두리 색
const double _laCardBorderWidth = 1;    // 전체현황 카드 테두리 두께
const _laCardTitleColor        = _text; // "리스비 전체 현황" 색
const double _laCardTitleFontSize = 13; // "리스비 전체 현황" 크기
const double _laRowFontSize    = 12;    // 정보행(기간·진행·납부·잔여) 글씨 크기
const double _laRowValueFontSize = 16;  // 진행현황 강조 숫자 크기
const double _laChevronSize    = 18;    // 펼침 아이콘 크기

// ── [8-3] 라이더 출금내역 (정산내역·누적정산 카드) ──
const double _rhCardBorderWidth = 1;   // 카드 테두리 두께
const _rhDateChipColor   = _teal;      // 날짜칩 글씨 색
const double _rhDateChipFontSize = 12; // 날짜칩 글씨 크기
const _rhDaysColor       = _amber;     // "N일" 색
const double _rhDaysFontSize = 11;     // "N일" 크기
const _rhHeadAmtColor    = _text;      // 헤더 금액 색
const double _rhHeadAmtFontSize = 13;  // 헤더 금액 크기
const _rhPaidBadgeColor  = _teal;      // "입금완료" 박스 색
const double _rhPaidFontSize = 10;     // "입금완료" 박스 글씨 크기
const _rhDividerColor    = _borderDim; // 헤더 ↔ 내용 구분선 색
// 상세 내역 행 (정산내역·누적정산 공통 헬퍼)
const _rhMainColor       = _text;      // "배달수수료(세전)" 등 메인 행 색
const double _rhMainFontSize = 12;     // 메인 행 글씨 크기
const _rhTogLabelColor   = _text;     // 토글 라벨 색
const double _rhTogFontSize  = 12;     // 토글 글씨 크기
const double _rhTogIconSize  = 14;     // 토글 아이콘 크기
const _rhSubColor        = _text2;     // 하위행 색
const double _rhSubFontSize  = 11;     // 하위행 글씨 크기
const _rhSubtotalColor   = _teal;      // 소계·총출금 색
const double _rhSubtotalLabelFontSize = 12; // 소계 라벨 크기
const double _rhSubtotalValueFontSize = 13; // 소계 값 크기
// 날짜별 상세 카드
const double _rhItemGap  = 6;          // 날짜 카드 사이 갭
const _rhItemChipColor   = _teal;      // 날짜칩 글씨 색
const double _rhItemChipFontSize = 11; // 날짜칩 글씨 크기
// 누적정산 시작일·마지막일 날짜 버튼
const _rhDateHintColor   = _text;     // 기본(미선택) 글씨 색
const _rhDateSelColor    = _teal;     // 선택 시 글씨 색
const double _rhDateFontSize = 11;    // 날짜 버튼 글씨 크기
const _rhDateBorderColor = _elevated; // 날짜 버튼 테두리 색
// 누적정산 카드 여백
const double _rhCumOuterL = 15; // 카드 바깥 여백 왼
const double _rhCumOuterT = 2; // 위 (탭 ↔ 카드)
const double _rhCumOuterR = 15; // 오른
const double _rhCumOuterB = 15; // 아래
const double _rhCumPadL = 16;   // 카드 안쪽 여백 왼
const double _rhCumPadT = 14;   // 위
const double _rhCumPadR = 10;   // 오른
const double _rhCumPadB = 16;   // 아래
// 정산내역 목록 여백·카드 갭
const double _rhSettleOuterL = 15; // 목록 바깥 여백 왼
const double _rhSettleOuterT = 2; // 위 (탭 ↔ 카드)
const double _rhSettleOuterR = 15; // 오른
const double _rhSettleOuterB = 15; // 아래
const double _rhLogCardGap   = 8;  // 정산내역 카드 사이 갭
// 정산내역 카드 안쪽 여백
const double _rhLogHeadPadH = 16; // 헤더 좌우 여백
const double _rhLogHeadPadV = 13; // 헤더 위아래 여백
const double _rhLogBodyPadL = 14; // 본문 여백 왼
const double _rhLogBodyPadT = 10; // 위
const double _rhLogBodyPadR = 14; // 오른
const double _rhLogBodyPadB = 14; // 아래
// 날짜카드(속) 안쪽 여백
const double _rhItemHeadPadH = 12; // 헤더 좌우 여백
const double _rhItemHeadPadV = 9;  // 헤더 위아래 여백
const double _rhItemBodyPadL = 12; // 본문 여백 왼
const double _rhItemBodyPadT = 8;  // 위
const double _rhItemBodyPadR = 12; // 오른
const double _rhItemBodyPadB = 10; // 아래

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
const _stSectionDivider = _teal; // 큰 구분선 색
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
const _ntStatDivider = _borderDim;  // 통계 항목 구분선
const _ntStatLabelColor = _text2;   // 통계 라벨 색
const double _ntStatLabelFontSize = 10; // 통계 라벨 크기
const _ntStatValueColor = _teal;  // 통계 숫자 색
const double _ntStatValueFontSize = 16; // 통계 숫자 크기
const _ntBoxBg     = _surface; // 공지 박스 배경
const _ntBoxBorder = _elevated;  // 공지 박스 테두리
const double _ntBoxRadius = 16;// 공지 박스 모서리
const _ntTitleIconColor = _teal; // 공지 헤더 아이콘 색
const _ntTitleColor = _text2;      // "공지사항" 글씨 색
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
// ── [10-2] 1:1 상담 — 목록 카드 ──
const double _csListPadH = 14; // 목록 좌우 여백
const double _csListPadV = 12; // 목록 상하 여백
const _csCardBg = _surface;    // 상담 카드 배경
const double _csCardRadius = 12;// 상담 카드 모서리
const _csCardBorder       = _elevated; // 읽음 카드 테두리
const _csCardBorderUnread = _teal;    // 안읽음 카드 테두리
const _csAvatarBg         = _surface;  // 아바타 배경
const _csAvatarIconColor  = _text2;     // 아바타 아이콘(읽음)
const _csAvatarIconUnread = _teal;    // 아바타 아이콘(안읽음)
const _csNameColor  = _text2;  // 이름(읽음) 색
const _csNameUnread = _text2;   // 이름(안읽음) 색
const double _csNameFontSize = 13; // 이름 글씨 크기
const _csNewBg   = _pink;   // NEW 뱃지 배경
const _csNewText = _text;  // NEW 뱃지 글씨
const _csTimeColor = _text2;       // 시간 색
const double _csTimeFontSize = 10; // 시간 크기
const _csLastColor = _text2;       // 마지막 메시지 색
const double _csLastFontSize = 11; // 마지막 메시지 크기
const _csChevronColor = _text2;    // 화살표 색
const _csEmptyColor = _text2;      // "접수된 상담이 없습니다" 색
const double _csEmptyFontSize = 13;// 빈 안내 글씨 크기
const double _csAvatarSize     = 38; // 아바타 크기
const double _csAvatarIconSize = 20; // 아바타 아이콘 크기
const double _csNewFontSize    = 8;  // NEW 뱃지 글씨 크기
const double _csChevronSize    = 16; // 화살표 크기
const double _csRowGap         = 8;  // 카드 사이 갭
const double _csTabToCardGap   = 2; // 1:1상담 탭 ↔ 첫 카드 갭


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
  int _chGrandTotal = 0;
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
      DateTime weekStart(DateTime d) =>
          DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
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
      double grand = 0;
      for (final d in snap.docs) {
        final data = d.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        grand += amount;
        String? key;
        final ts = data['approvedAt'] as Timestamp?;
        if (ts != null) {
          key = dk(ts.toDate());
        } else if ((data['date'] as String?)?.isNotEmpty == true) {
          key = data['date'] as String;
        }
        if (key == null) continue;
        byDay[key] = (byDay[key] ?? 0) + amount;
        // 랭킹: 기사별 이번주/이번달 지급 합계
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

      // 주간: 최근 7주(월요일 시작)
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
          _chGrandTotal = grand.round();
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
            [const _WithdrawalRequestPage(embedded: true), _withdrawalTab()]);
        gapHeaderDiv = _wrPageGapHeaderDiv; gapDivCard = _wrPageGapDivCard;
        break;
      case 'rider':
        title = '라이더 관리';
        body = _hubTabs(const ['라이더', '리스비'], const [
          _RiderManagePage(embedded: true),
          _LeaseAlertsPage(embedded: true),
        ]);
        gapHeaderDiv = _rmPageGapHeaderDiv; gapDivCard = _rmPageGapDivCard;
        break;
      case 'notice':
        title = '공지 / 상담';
        body = _hubTabs(const ['공지사항', '1:1상담'],
            [_noticeTab(), const _ChatListPage(embedded: true)]);
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
            onPressed: () => setState(() => _homeView = null),
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
                      text: NumberFormat('#,###').format(_chGrandTotal),
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
            builder: (_) => _FullRankingPage(title: title, ranking: list)));
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
                badgeColor: _orange)),
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
          _divider(),
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
          _divider(),
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
              if (lPerOrder > 0) _subC("건당프로모션", "${_fmtC(lPerOrder)} 원"),
              if (lRange    > 0) _sub("구간프로모션",  "${_fmtC(lRange)} 원"),
            ]),
            _toggle("세금합계", "${_fmtC(totalTaxSum)} 원", _pink, lTaxExp,
                () => setState(() => lTaxExp = !lTaxExp), [
              _subC("고용보험", "${_fmtC(lEmp)} 원", vc: _text2),
              _subC("산재보험", "${_fmtC(lAcc)} 원", vc: _text2),
              _subC("원천세",   "${_fmtC(lTax)} 원", vc: _text2),
            ]),
            if (totalFeeSum > 0) _toggle("수수료합계", "${_fmtC(totalFeeSum)} 원", _pink, lCommExp,
                () => setState(() => lCommExp = !lCommExp), [
              if (lWd   > 0) _subC("출금수수료",   "${_fmtC(lWd)} 원",   vc: _text2),
              if (lComm > 0) _subC("협력사수수료", "${_fmtC(lComm)} 원", vc: _text2),
            ]),
            if (totalDeduSum > 0) _toggle("공제합계", "${_fmtC(totalDeduSum)} 원", _pink, lDedu,
                () => setState(() => lDedu = !lDedu), [
              if (lIns   > 0) _subC("시간제보험", "${_fmtC(lIns)} 원",   vc: _text2),
              if (lLease > 0) _subC("리스비",     "${_fmtC(lLease)} 원", vc: _text2),
            ]),
            Container(height: 1, color: _teal, margin: const EdgeInsets.symmetric(vertical: 10)),
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
                border: Border.all(color: _settingsLocked ? _borderDim : _elevated, width: 1),
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

  Widget _divider() => Container(height: 1, color: _borderDim, margin: const EdgeInsets.symmetric(vertical: 5));

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

// === [공통] 서브페이지 패널 래퍼 (전체배경 → 메인배경 패널 → 뒤로가기 헤더 + 내용) ===
Widget _adminPanelScaffold(BuildContext context, String title, Widget child) {
  return Scaffold(
    backgroundColor: _appBg,
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(_panelOuterPad),
        child: Container(
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(_panelRadius),
            border: Border.all(
                color: _elevated.withValues(alpha: _panelBorderAlpha), width: 1),
            boxShadow: _panelShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_panelRadius),
            child: Column(children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: _text, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(title,
                      style: const TextStyle(
                          color: _text, fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
              ),
              Container(height: 1, color: _teal.withValues(alpha: 0.6)),
              Expanded(child: child),
            ]),
          ),
        ),
      ),
    ),
  );
}

// === 출금신청 페이지 ==============================================================================

// ═══════════════════════ 7. 출금신청 페이지 (로직) ═══════════════════════
class _WithdrawalRequestPage extends StatefulWidget {
  final bool embedded; // 허브 탭 안에 들어갈 때 true (패널 생략)
  const _WithdrawalRequestPage({this.embedded = false});
  @override
  State<_WithdrawalRequestPage> createState() => _WithdrawalRequestPageState();
}

class _WithdrawalRequestPageState extends State<_WithdrawalRequestPage> {

  final Map<String, Map<String, dynamic>> _cache       = {};
  final Map<String, bool>                 _cardExp     = {};
  // 3단계: 날짜별 펼치기
  final Map<String, Map<String, bool>>    _dateItemExp = {};
  bool _cacheReady = false;

  Future<void> _prefetch(List<QueryDocumentSnapshot> docs) async {
    final uids = docs
        .map((d) => (d.data() as Map<String, dynamic>)['uid'] as String?)
        .whereType<String>().toSet()
        .where((uid) => !_cache.containsKey(uid)).toList();
    if (uids.isEmpty) { if (mounted) setState(() => _cacheReady = true); return; }
    await Future.wait(uids.map((uid) async {
      try {
        final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (snap.exists) _cache[uid] = snap.data()!;
      } catch (_) {}
    }));
    if (mounted) setState(() => _cacheReady = true);
  }

  double _rx(String msg, String key) {
    final m = RegExp('$key[^:：]*[：:][\\s]*([-\\d,]+)').firstMatch(msg);
    if (m == null) return 0;
    return double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
  }

  double _rxComm(String msg) {
    final m = RegExp(r'(?<![가-힣])협력사수수료\([^)]+\)\s*[：:]\s*([\d,]+)').firstMatch(msg);
    if (m == null) return 0;
    return double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
  }

  String _fmtC(double v) => NumberFormat('#,###').format(v);

  void _showDone(String msg) {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _teal, width: 1)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(msg, style: const TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
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

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdrawal_requests')
            .where('status', isEqualTo: '요청대기')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: _teal));
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("출금 요청이 없습니다.", style: TextStyle(color: _text2, fontSize: 14)));
          if (!_cacheReady) { _prefetch(docs); return const Center(child: CircularProgressIndicator(color: _teal)); }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(15, _wrTabToCardGap, 15, 15),
            itemCount: docs.length,
            itemBuilder: (_, i) => _card(docs[i]),
          );
        },
      );
    return widget.embedded ? body : _adminPanelScaffold(context, "출금 신청", body);
  }

  // 3단계: items 배열 기반 카드 (하위 호환 유지)
  Widget _card(QueryDocumentSnapshot doc) {
    final data      = doc.data() as Map<String, dynamic>;
    final docId     = doc.id;
    final fixedData = Map<String, dynamic>.from(data);
    final fixedUid  = data['uid'] as String?;
    final cardExp   = _cardExp[docId] ?? false;

    // 신규: items 배열
    final items = (data['items'] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    final hasItems        = items.isNotEmpty;
    final totalAmount     = (data['amount'] as num?)?.toDouble() ?? 0;
    final leaseDeduction  = (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
    final riderName       = data['riderName'] as String? ?? '';

    // 날짜 범위 라벨
    String dateLabel;
    if (hasItems) {
      final first = (items.first['date'] as String? ?? '');
      final last  = (items.last['date']  as String? ?? '');
      final fs = first.length >= 10 ? first.substring(5) : first;
      final ls = last.length  >= 10 ? last.substring(5)  : last;
      dateLabel = items.length == 1 ? fs : "$fs ~ $ls";
    } else {
      final d = data['date'] as String? ?? '';
      dateLabel = d.length >= 10 ? d.substring(5) : d;
    }

    final cached  = fixedUid != null ? _cache[fixedUid] : null;
    final bank    = cached?['bankName']      as String? ?? '';
    final account = cached?['accountNumber'] as String? ?? '';

    _dateItemExp.putIfAbsent(docId, () => {});

    return Container(
      margin: const EdgeInsets.only(bottom: _wrCardGap),
      decoration: BoxDecoration(
          color: _wrCardBg,
          borderRadius: BorderRadius.circular(_wrCardRadius),
          border: Border.all(color: _wrCardBorder, width: _wrCardBorderWidth),
          boxShadow: _cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── 카드 헤더 ──
        GestureDetector(
          onTap: () => setState(() => _cardExp[docId] = !cardExp),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: _wrHeadPadH, vertical: _wrHeadPadV),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(style: const TextStyle(fontWeight: FontWeight.w700), children: [
                  TextSpan(text: riderName, style: const TextStyle(color: _wrNameColor, fontSize: _wrNameFontSize)),
                  const TextSpan(text: " 님의 출금 신청!!", style: TextStyle(color: _wrTitleColor, fontSize: _wrTitleFontSize)),
                ])),
                const SizedBox(height: _wrGapNameDate),
                Text(dateLabel, style: const TextStyle(color: _wrDateColor, fontSize: _wrDateFontSize)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text("${NumberFormat('#,###').format(totalAmount)} 원",
                    style: const TextStyle(color: _wrAmtColor, fontWeight: FontWeight.w700, fontSize: _wrAmtFontSize)),
                if (hasItems)
                  Text("${items.length}일 합산", style: const TextStyle(color: _wrDaysColor, fontSize: _wrDaysFontSize)),
              ]),
              const SizedBox(width: _wrGapAmtChevron),
              Icon(cardExp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: _wrChevronColor, size: _wrChevronSize),
            ]),
          ),
        ),

        // ── 펼침 내용 ──
        if (cardExp) ...[
          Container(height: 1, color: _wrDividerColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // 계좌 정보 (은행명=텍스트 / 계좌번호=블랙 박스)
              if (bank.isNotEmpty || account.isNotEmpty) ...[
                Row(children: [
                  Text(bank, style: const TextStyle(color: _wrBankColor, fontSize: _wrBankFontSize)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: _wrValBoxPadH, vertical: _wrValBoxPadV),
                    decoration: BoxDecoration(
                        color: _wrValBoxBg,
                        borderRadius: BorderRadius.circular(_wrValBoxRadius),
                        border: Border.all(color: _wrValBoxBorder)),
                    child: Text(account,
                        style: const TextStyle(
                            color: _wrAcctNumColor, fontSize: _wrAcctNumFontSize)),
                  ),
                  const SizedBox(width: 6),
                  _copyBtn(() => Clipboard.setData(ClipboardData(
                      text: account.replaceAll('-', '').replaceAll(' ', '')))),
                ]),
                const SizedBox(height: _wrGapAcctFinal),
              ],

              // 최종출금금액 (숫자=블랙 박스) + 복사
              Row(children: [
                const Text("최종출금금액", style: TextStyle(color: _wrFinalLabelColor, fontSize: _wrFinalLabelFontSize)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: _wrValBoxPadH, vertical: _wrValBoxPadV),
                  decoration: BoxDecoration(
                      color: _wrValBoxBg,
                      borderRadius: BorderRadius.circular(_wrValBoxRadius),
                      border: Border.all(color: _wrValBoxBorder)),
                  child: Text("${_fmtC(totalAmount)} 원",
                      style: const TextStyle(
                          color: _wrFinalAmtColor,
                          fontWeight: FontWeight.w700,
                          fontSize: _wrFinalAmtFontSize)),
                ),
                const SizedBox(width: 8),
                _copyBtn(() => Clipboard.setData(ClipboardData(
                    text: totalAmount.toInt().toString()))),
              ]),

              // 날짜별 상세 (items 있을 때)
              if (hasItems) ...[
                const SizedBox(height: _wrGapFinalItems),
                ...List.generate(items.length, (i) {
                  final item    = items[i];
                  final iDate   = item['date'] as String? ?? '';
                  final iShort  = iDate.length >= 10 ? iDate.substring(5) : iDate;
                  final iFinal  = (item['finalAmount']    as num?)?.toDouble() ?? 0;
                  final iDel    = (item['deliveryFee']    as num?)?.toDouble() ?? 0;
                  final iPromo  = (item['promoTotal']     as num?)?.toDouble() ?? 0;
                  final iTax    = (item['tax']            as num?)?.toDouble() ?? 0;
                  final iComm   = (item['commissionAmt']  as num?)?.toDouble() ?? 0;
                  final iWd     = (item['withdrawalFee']  as num?)?.toDouble() ?? 0;
                  final iPOrder = (item['perOrderAmount'] as num?)?.toDouble() ?? 0;
                  final iRange  = (item['rangeAmount']    as num?)?.toDouble() ?? 0;
                  final iETax   = (item['employmentTax']  as num?)?.toDouble() ?? 0;
                  final iATax   = (item['accidentTax']    as num?)?.toDouble() ?? 0;
                  final iITax   = (item['incomeTax']      as num?)?.toDouble() ?? 0;
                  final iIns    = (item['insuranceFee']   as num?)?.toDouble() ?? 0;
                  final iLease  = items.isNotEmpty ? leaseDeduction / items.length : 0.0;
                  final iFee    = iWd + iComm;
                  final iDedu   = iIns + iLease;
                  final iExp    = _dateItemExp[docId]?[iDate] ?? false;

                  bool tog(String k) => _dateItemExp[docId]?[k] ?? false;
                  void togSet(String k) => setState(() =>
                      _dateItemExp[docId]![k] = !(_dateItemExp[docId]![k] ?? false));

                  Widget subGroup(List<Widget> ch) => Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                    decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: _elevated)),
                    child: Column(children: ch),
                  );

                  Widget subRow(String label, String val, {Color lc = _wrDtSubColor, Color vc = _wrDtSubColor}) =>
                      Padding(padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(label, style: TextStyle(color: lc, fontSize: _wrDtSubFontSize)),
                          Text(val,   style: TextStyle(color: vc, fontSize: _wrDtSubFontSize)),
                        ]));

                  Widget togRow(String label, double v, Color vc, String k) =>
                      GestureDetector(
                        onTap: () => togSet(k),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Text(label, style: const TextStyle(color: _wrDtTogLabelColor, fontSize: _wrDtTogFontSize, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 4),
                            Icon(tog(k) ? Icons.expand_less : Icons.expand_more, color: _wrDtTogLabelColor, size: _wrDtTogIconSize),
                            const Spacer(),
                            Text("${_fmtC(v)} 원", style: TextStyle(color: vc, fontSize: _wrDtTogFontSize)),
                          ]),
                        ),
                      );

                  return Container(
                    margin: const EdgeInsets.only(bottom: _wrItemGap),
                    decoration: BoxDecoration(
                      color: _surface, borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: iExp ? _teal.withAlpha(60) : _elevated),
                    ),
                    child: Column(children: [
                      GestureDetector(
                        onTap: () => setState(() => _dateItemExp[docId]![iDate] = !iExp),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(5), border: Border.all(color: _elevated)),
                              child: Text(iShort, style: const TextStyle(color: _wrItemChipColor, fontSize: _wrItemChipFontSize, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 4),
                            Icon(iExp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: _text2, size: _wrItemChevronSize),
                            const Spacer(),
                            Text("${_fmtC(iFinal)} 원", style: const TextStyle(color: _wrItemAmtColor, fontSize: _wrItemAmtFontSize, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                      if (iExp) ...[
                        Container(height: 1, color: _borderDim),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text("배달수수료 (세전)", style: TextStyle(color: _wrDtMainColor, fontSize: _wrDtMainFontSize, fontWeight: FontWeight.w500)),
                                Text("${_fmtC(iDel)} 원", style: const TextStyle(color: _wrDtMainColor, fontSize: _wrDtMainFontSize)),
                              ]),
                            ),
                            togRow("지원금합계", iPromo, _text, '${iDate}_promo'),
                            if (tog('${iDate}_promo')) subGroup([
                              if (iPOrder > 0) subRow("건당프로모션", "${_fmtC(iPOrder)} 원"),
                              if (iRange  > 0) subRow("구간프로모션", "${_fmtC(iRange)} 원"),
                            ]),
                            togRow("세금합계", iTax, _pink, '${iDate}_tax'),
                            if (tog('${iDate}_tax')) subGroup([
                              subRow("고용보험", "${_fmtC(iETax)} 원", vc: _text2),
                              subRow("산재보험", "${_fmtC(iATax)} 원", vc: _text2),
                              subRow("원천세",   "${_fmtC(iITax)} 원", vc: _text2),
                            ]),
                            if (iFee > 0) togRow("수수료합계", iFee, _pink, '${iDate}_comm'),
                            if (iFee > 0 && tog('${iDate}_comm')) subGroup([
                              if (iWd   > 0) subRow("출금수수료",   "${_fmtC(iWd)} 원",   vc: _text2),
                              if (iComm > 0) subRow("협력사수수료", "${_fmtC(iComm)} 원", vc: _text2),
                            ]),
                            if (iDedu > 0) togRow("공제합계", iDedu, _pink, '${iDate}_dedu'),
                            if (iDedu > 0 && tog('${iDate}_dedu')) subGroup([
                              if (iIns   > 0) subRow("시간제보험", "${_fmtC(iIns)} 원",   vc: _text2),
                              if (iLease > 0) subRow("리스비",     "${_fmtC(iLease)} 원", vc: _text2),
                            ]),
                            Container(height: 1, color: _teal, margin: const EdgeInsets.symmetric(vertical: 5)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text("소계", style: TextStyle(color: _wrDtSubtotalColor, fontSize: _wrDtSubtotalLabelFontSize, fontWeight: FontWeight.w700)),
                                Text("${_fmtC(iFinal)} 원", style: const TextStyle(color: _wrDtSubtotalColor, fontSize: _wrDtSubtotalValueFontSize, fontWeight: FontWeight.w700)),
                              ]),
                            ),
                          ]),
                        ),
                      ],
                    ]),
                  );
                }),
              ]

              // 구형 호환: items 없으면 message 파싱
              else ...[
                _divider(),
                () {
                  final msg        = data['message']?.toString() ?? '';
                  final deliveryFee  = _rx(msg, '배달수수료\\(세전\\)').abs();
                  final tTax         = _rx(msg, '세금').abs();
                  final eTax         = _rx(msg, '고용보험').abs();
                  final aTax         = _rx(msg, '산재보험').abs();
                  final iTax         = _rx(msg, '원천세').abs();
                  final missionFee   = _rx(msg, '미션금액').abs();
                  final perOrderAmt  = _rx(msg, '건당프로모션').abs();
                  final rangeAmt     = _rx(msg, '구간프로모션').abs();
                  final promoTotal   = missionFee + perOrderAmt + rangeAmt;
                  final insuranceFee = _rx(msg, '시간제보험').abs();
                  final withdrawFee  = _rx(msg, '출금수수료').abs();
                  final leaseDailyAmt = _rx(msg, '리스비\\(일\\)').abs();
                  final commAmt      = _rxComm(msg);
                  final deductTotal  = insuranceFee + withdrawFee + leaseDailyAmt;
                  final finalWd      = _rx(msg, '최종출금금액').abs();
                  final oldTaxExp    = _dateItemExp[docId]?['_tax']   ?? false;
                  final oldPromoExp  = _dateItemExp[docId]?['_promo'] ?? false;
                  final oldDeduExp   = _dateItemExp[docId]?['_dedu']  ?? false;
                  return Column(children: [
                    _row("배달수수료 (세전)", "${_fmtC(deliveryFee)} 원"),
                    _divider(),
                    _toggle("지원금", "${_fmtC(promoTotal)} 원", _text, oldPromoExp,
                        () => setState(() => _dateItemExp[docId]!['_promo'] = !oldPromoExp), [
                      _sub("미션금", "${_fmtC(missionFee)} 원"),
                      _sub("건당프로모션", "${_fmtC(perOrderAmt)} 원"),
                      _sub("구간프로모션", "${_fmtC(rangeAmt)} 원"),
                    ]),
                    _divider(),
                    _toggle("세금", "${_fmtC(tTax)} 원", _pink, oldTaxExp,
                        () => setState(() => _dateItemExp[docId]!['_tax'] = !oldTaxExp), [
                      _sub("고용보험", "${_fmtC(eTax)} 원"),
                      _sub("산재보험", "${_fmtC(aTax)} 원"),
                      _sub("원천세",   "${_fmtC(iTax)} 원"),
                    ]),
                    _divider(),
                    _row("협력사수수료", "${_fmtC(commAmt)} 원", vc: _pink),
                    _divider(),
                    _toggle("공제", "${_fmtC(deductTotal)} 원", _pink, oldDeduExp,
                        () => setState(() => _dateItemExp[docId]!['_dedu'] = !oldDeduExp), [
                      _sub("시간제보험", "${_fmtC(insuranceFee)} 원"),
                      _sub("출금수수료", "${_fmtC(withdrawFee)} 원"),
                      if (leaseDailyAmt > 0) _sub("리스비(일)", "${_fmtC(leaseDailyAmt)} 원"),
                    ]),
                    Container(height: 1, color: _teal.withAlpha(80), margin: const EdgeInsets.symmetric(vertical: 8)),
                    _row("최종출금금액", "${_fmtC(finalWd)} 원", lc: _teal, vc: _teal, bold: true, fs: 14),
                  ]);
                }(),
              ],

              const SizedBox(height: 14),

              // ── 4단계: 입금완료 버튼 (unpaid_balance 삭제 포함) ──
              Center(child: SizedBox(width: 180, height: 44, child: GlassShineButton(
                label: "입 금 완 료",
                accent: _teal,
                height: 44,
                fontSize: 14,
                onPressed: () async {
                  final batch = FirebaseFirestore.instance.batch();
                  batch.update(
                      FirebaseFirestore.instance.collection('withdrawal_requests').doc(docId),
                      {'status': '지급완료'});
                  batch.set(
                      FirebaseFirestore.instance.collection('admin_settlement_logs').doc(), {
                    ...fixedData,
                    'uid':        fixedUid,
                    'status':     '지급완료',
                    'approvedAt': FieldValue.serverTimestamp(),
                  });
                  await batch.commit();

                  // 4단계: unpaid_balance 초기화
                  if (fixedUid != null) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('unpaid_balance').doc(fixedUid).delete();
                    } catch (e) { debugPrint('unpaid_balance 삭제 실패: $e'); }
                  }

                  // 매일 타입 리스비: 이번 출금한 일수(누적 회수)만큼 앞 회차부터 자동 완납
                  if (fixedUid != null) {
                    try {
                      final settlementDates = (fixedData['dates'] as List?)
                              ?.map((d) => d.toString())
                              .where((d) => d.isNotEmpty)
                              .toList() ??
                          [if ((fixedData['date'] ?? '').toString().isNotEmpty)
                              fixedData['date'].toString()];
                      // 리스비 시작일 이전·종료일 이후 출금일은 일일 리스비 회차에서 제외
                      final uLease = await FirebaseFirestore.instance
                          .collection('users').doc(fixedUid).get();
                      final lStart = uLease.data()?['leaseStartDate'] as String?;
                      final lLast = uLease.data()?['leaseLastDate'] as String?;
                      final validDates = settlementDates.where((d) {
                        if (lStart != null && d.compareTo(lStart) < 0) return false;
                        if (lLast != null && d.compareTo(lLast) > 0) return false;
                        return true;
                      }).toList();
                      final int payDays = validDates.length; // 리스비 기간 내 출금 일수
                      if (payDays > 0) {
                        final leaseSnap = await FirebaseFirestore.instance
                            .collection('lease_payments')
                            .where('uid',       isEqualTo: fixedUid)
                            .where('leaseType', isEqualTo: 'daily')
                            .where('isPaid',    isEqualTo: false)
                            .get();
                        if (leaseSnap.docs.isNotEmpty) {
                          // 회차(cycle) 오름차순으로 앞에서부터 payDays개 완납 처리
                          final docs = leaseSnap.docs.toList()
                            ..sort((a, b) =>
                                ((a.data()['cycle'] as num?) ?? 0)
                                    .compareTo((b.data()['cycle'] as num?) ?? 0));
                          final lBatch = FirebaseFirestore.instance.batch();
                          for (final ld in docs.take(payDays)) {
                            lBatch.update(ld.reference, {
                              'isPaid': true,
                              'paidAt': FieldValue.serverTimestamp(),
                              'seenByRider': false,
                            });
                          }
                          await lBatch.commit();
                          // 기사 하단바 리스비 배지 자동 활성화
                          await FirebaseFirestore.instance
                              .collection('users').doc(fixedUid)
                              .update({'leaseNewAlert': true});
                        }
                      }
                    } catch (e) { debugPrint('매일 리스비 완납 처리 실패: $e'); }
                  }

                  if (mounted) _showDone("입금 처리 완료");
                },
              ))),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _copyBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: _wrCopyBorder, width: _wrCopyBorderWidth), borderRadius: BorderRadius.circular(6)),
      child: const Text("복사", style: TextStyle(color: _teal, fontSize: 11)),
    ),
  );

  Widget _divider() => Container(height: 1, color: _borderDim, margin: const EdgeInsets.symmetric(vertical: 5));

  Widget _row(String label, String value, {Color lc = _text2, Color vc = _text2, bool bold = false, double fs = 12}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: lc, fontSize: fs, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value, style: TextStyle(color: vc, fontSize: fs, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ]));

  Widget _sub(String label, String value) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: _text2, fontSize: 11)),
          Text(value, style: const TextStyle(color: _text2, fontSize: 11)),
        ]));

  Widget _toggle(String label, String value, Color vc, bool expanded, VoidCallback onTap, List<Widget> children) =>
      Column(children: [
        GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Text(label, style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: _text2, size: 16),
              const Spacer(),
              Text(value, style: TextStyle(color: vc, fontSize: 12, fontWeight: FontWeight.w600)),
            ]))),
        if (expanded)
          Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _elevated, width: 1)),
              child: Column(children: children)),
      ]);
}

// === _RiderManagePage ========================================================================

// ═══════════════════════ 8. 라이더관리 페이지 (로직) ═══════════════════════
class _RiderManagePage extends StatefulWidget {
  final bool embedded;
  const _RiderManagePage({this.embedded = false});
  @override
  State<_RiderManagePage> createState() => _RiderManagePageState();
}

class _RiderManagePageState extends State<_RiderManagePage> {

  Map<String, bool> riderIdEditMode      = {};
  Map<String, bool> riderAccountEditMode = {};
  Map<String, bool> riderLeaseEditMode   = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final Map<String, TextEditingController> _bankCtrlCache        = {};
  final Map<String, TextEditingController> _accountCtrlCache     = {};
  final Map<String, TextEditingController> _leaseCycleCtrlCache  = {};
  final Map<String, TextEditingController> _leaseAmountCtrlCache = {};
  final Map<String, String>                _leaseTypeCache       = {};
  final Map<String, DateTime?>             _leaseStartCache      = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    for (final c in _bankCtrlCache.values)        { c.dispose(); }
    for (final c in _accountCtrlCache.values)     { c.dispose(); }
    for (final c in _leaseCycleCtrlCache.values)  { c.dispose(); }
    for (final c in _leaseAmountCtrlCache.values) { c.dispose(); }
    super.dispose();
  }

  DateTime _calcMonthlyDate(DateTime from, int monthsToAdd, int day) {
    final totalMonths = (from.year * 12 + from.month - 1) + monthsToAdd;
    final year  = totalMonths ~/ 12;
    final month = (totalMonths % 12) + 1;
    final maxDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day.clamp(1, maxDay));
  }

  Future<void> _saveReportId(String uid, String id) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'reportId': id});
    setState(() => riderIdEditMode[uid] = false);
    _showDialog("ID 저장완료!!");
  }

  Future<void> _saveAccountInfo(String uid, String bank, String account) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'bankName': bank.trim(), 'accountNumber': account.trim(),
    });
    setState(() => riderAccountEditMode[uid] = false);
    _showDialog("계좌정보 저장완료!!");
  }

  Future<void> _saveLease(String uid) async {
    final type      = _leaseTypeCache[uid] ?? 'weekly';
    final cycle     = int.tryParse((_leaseCycleCtrlCache[uid]?.text ?? '').replaceAll(',', '')) ?? 0;
    final amount    = double.tryParse((_leaseAmountCtrlCache[uid]?.text ?? '').replaceAll(',', ''))?.truncateToDouble() ?? 0;
    final startDate = _leaseStartCache[uid];
    final leaseDay  = startDate?.day ?? 1;

    if (startDate == null || amount <= 0) { _showDialog("시작일과 금액을 입력해주세요."); return; }
    if (cycle <= 0) { _showDialog(type == 'daily' ? "총 일수를 입력해주세요." : "회차를 입력해주세요."); return; }

    DateTime lastDate;
    if (type == 'daily') {
      lastDate = startDate.add(Duration(days: cycle));
    } else if (type == 'weekly') {
      lastDate = startDate.add(Duration(days: 7 * (cycle - 1)));
    } else {
      lastDate = _calcMonthlyDate(startDate, cycle - 1, leaseDay);
    }

    final updateData = <String, dynamic>{
      'leaseType':      type,
      'leaseCycle':     cycle,
      'leaseStartDate': DateFormat('yyyy-MM-dd').format(startDate),
      'leaseLastDate':  DateFormat('yyyy-MM-dd').format(lastDate),
      'leaseAmount':    amount.toInt(),
      'leaseNewAlert':  false,
    };
    await FirebaseFirestore.instance.collection('users').doc(uid).update(updateData);

    String riderName = '';
    try { final u = await FirebaseFirestore.instance.collection('users').doc(uid).get(); riderName = u.data()?['name'] as String? ?? ''; } catch (_) {}

    final oldSnap = await FirebaseFirestore.instance.collection('lease_payments').where('uid', isEqualTo: uid).get();
    final delBatch = FirebaseFirestore.instance.batch();
    for (final doc in oldSnap.docs) { delBatch.delete(doc.reference); }
    await delBatch.commit();

    // 매일 타입도 일별 납기일 생성 (미출금 추적용)
    final createBatch = FirebaseFirestore.instance.batch();
    for (int n = 0; n < cycle; n++) {
      final DateTime dueDate;
      if (type == 'daily') {
        dueDate = startDate.add(Duration(days: n));
      } else if (type == 'weekly') {
        dueDate = startDate.add(Duration(days: 7 * n));
      } else {
        dueDate = _calcMonthlyDate(startDate, n, leaseDay);
      }
      createBatch.set(FirebaseFirestore.instance.collection('lease_payments').doc(), {
        'uid': uid, 'riderName': riderName, 'cycle': n + 1, 'totalCycle': cycle,
        'dueDate': DateFormat('yyyy-MM-dd').format(dueDate),
        'amount': amount.toInt(), 'isPaid': false, 'paidAt': null,
        'leaseType': type, // 타입 저장
      });
    }
    await createBatch.commit();

    _leaseAmountCtrlCache[uid]?.text = NumberFormat('#,###').format(amount.toInt());
    setState(() => riderLeaseEditMode[uid] = false);
    _showDialog("리스비 저장완료!!\n총 $cycle회차 납기일이 생성되었습니다.");
  }

  Future<void> _resetLease(String uid) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _elevated, width: 1)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("초기화 확인", style: TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text("리스비 설정을 초기화하면\n모든 납기일이 삭제됩니다.", style: TextStyle(color: _text2, fontSize: 13, height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: GlassShineButton(
              label: "취소",
              onPressed: () => Navigator.pop(ctx, false),
              accent: _text2,
              textColor: _text2,
              pill: true,
              height: 46,
              fontSize: 14,
            )),
            const SizedBox(width: 10),
            Expanded(child: GlassShineButton(
              label: "초기화",
              onPressed: () => Navigator.pop(ctx, true),
              accent: _pink,
              textColor: _pink,
              pill: true,
              height: 46,
              fontSize: 14,
            )),
          ]),
        ]),
      ),
    ));
    if (confirm != true) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'leaseType': FieldValue.delete(), 'leaseCycle': FieldValue.delete(),
        'leaseStartDate': FieldValue.delete(), 'leaseLastDate': FieldValue.delete(),
        'leaseAmount': FieldValue.delete(), 'leaseNewAlert': FieldValue.delete(),
      });
      final snap = await FirebaseFirestore.instance.collection('lease_payments').where('uid', isEqualTo: uid).get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) { batch.delete(doc.reference); }
      await batch.commit();
      _leaseCycleCtrlCache[uid]?.text  = '';
      _leaseAmountCtrlCache[uid]?.text = '';
      _leaseTypeCache[uid]             = 'weekly';
      _leaseStartCache[uid]            = null;
      setState(() => riderLeaseEditMode[uid] = false);
      _showDialog("리스비 초기화 완료!");
    } catch (_) { _showDialog("초기화 실패. 다시 시도해주세요."); }
  }

  Future<void> _call(String phone) async { final u = Uri.parse('tel:$phone'); if (await canLaunchUrl(u)) await launchUrl(u); }
  Future<void> _sms(String phone)  async { final u = Uri.parse('sms:$phone'); if (await canLaunchUrl(u)) await launchUrl(u); }

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

  void _showBankPicker(String uid, TextEditingController bankCtrl) {
    const bankList = ['신한은행','국민은행','하나은행','우리은행','농협은행','기업은행','카카오뱅크','토스뱅크','케이뱅크','새마을금고','신협','우체국','씨티은행','SC제일은행','부산은행','대구은행','광주은행','전북은행','경남은행','제주은행'];
    showModalBottomSheet(context: context, backgroundColor: _surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 36, height: 4, decoration: BoxDecoration(color: _text2, borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text("은행 선택", style: TextStyle(color: _teal, fontSize: 14, fontWeight: FontWeight.w700))),
        Container(height: 1, color: _borderDim),
        Flexible(child: ListView.builder(shrinkWrap: true, itemCount: bankList.length,
          itemBuilder: (ctx, i) => ListTile(dense: true,
            title: Text(bankList[i], style: const TextStyle(color: _text, fontSize: 13)),
            trailing: bankCtrl.text == bankList[i] ? const Icon(Icons.check_rounded, color: _teal, size: 16) : null,
            onTap: () { setState(() => bankCtrl.text = bankList[i]); Navigator.pop(ctx); }),
        )),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.embedded
        ? _riderList()
        : _adminPanelScaffold(context, "라이더 관리", _riderList());
  }

  Widget _riderList() => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'driver').where('isApproved', isEqualTo: true).orderBy('name').snapshots(),
    builder: (_, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: _teal));
      final allDocs = snap.data!.docs;
      if (allDocs.isEmpty) return const Center(child: Text("등록된 라이더가 없습니다.", style: TextStyle(color: _text2)));
      final filtered = _searchQuery.isEmpty ? allDocs : allDocs.where((d) {
        final name = (d.data() as Map<String, dynamic>)['name']?.toString() ?? '';
        return name.contains(_searchQuery);
      }).toList();
      return Container(
        margin: const EdgeInsets.fromLTRB(15, _rmTabToCardGap, 15, 15),
        decoration: BoxDecoration(
            color: _rmCardBg,
            borderRadius: BorderRadius.circular(_rmCardRadius),
            border: Border.all(color: _rmCardBorder, width: _rmCardBorderWidth),
            boxShadow: _cardShadow),
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 8), child: TextField(
            controller: _searchCtrl, onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: _text, fontSize: _rmSearchFontSize), cursorColor: _teal,
            decoration: InputDecoration(
              hintText: "이름 검색...", hintStyle: const TextStyle(color: _rmSearchHint, fontSize: _rmSearchFontSize),
              prefixIcon: const Icon(Icons.search_rounded, color: _text2, size: 18),
              suffixIcon: _searchQuery.isNotEmpty ? GestureDetector(
                onTap: () => setState(() { _searchCtrl.clear(); _searchQuery = ''; }),
                child: const Icon(Icons.close_rounded, color: _text2, size: 16)) : null,
              filled: true, fillColor: _rmSearchBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: _teal.withAlpha(50))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: _teal, width: 1.5)),
            ),
          )),
          filtered.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Text("검색 결과가 없습니다.", style: TextStyle(color: _text2, fontSize: 13)))
              : Expanded(child: ListView.separated(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Container(margin: const EdgeInsets.symmetric(horizontal: 14), height: 1, color: _rmDividerColor),
                  itemBuilder: (_, i) => _riderCard(filtered[i]))),
        ]),
      );
    },
  );

  Widget _riderCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final uid  = doc.id;
    final isEditingId      = riderIdEditMode[uid]      ?? false;
    final isEditingAccount = riderAccountEditMode[uid] ?? false;
    final isEditingLease   = riderLeaseEditMode[uid]   ?? false;
    final idCtrl = TextEditingController(text: data['reportId'] ?? "");
    _bankCtrlCache.putIfAbsent(uid, () => TextEditingController(text: data['bankName'] ?? ""));
    _accountCtrlCache.putIfAbsent(uid, () => TextEditingController(text: data['accountNumber'] ?? ""));
    final bankCtrl    = _bankCtrlCache[uid]!;
    final accountCtrl = _accountCtrlCache[uid]!;
    _leaseCycleCtrlCache.putIfAbsent(uid, () => TextEditingController(text: data['leaseCycle']?.toString() ?? ''));
    _leaseAmountCtrlCache.putIfAbsent(uid, () {
      final amt = data['leaseAmount'];
      if (amt == null) return TextEditingController(text: '');
      final intAmt = (amt is num) ? amt.toInt() : int.tryParse(amt.toString()) ?? 0;
      return TextEditingController(text: intAmt > 0 ? NumberFormat('#,###').format(intAmt) : '');
    });
    _leaseTypeCache.putIfAbsent(uid, () { final t = data['leaseType'] as String? ?? 'weekly'; return t == 'monthly' ? 'monthly_fixed' : t; });
    if (!_leaseStartCache.containsKey(uid)) { final s = data['leaseStartDate'] as String?; _leaseStartCache[uid] = s != null ? DateTime.tryParse(s) : null; }
    final cycleCtrl  = _leaseCycleCtrlCache[uid]!;
    final amountCtrl = _leaseAmountCtrlCache[uid]!;
    final leaseType  = _leaseTypeCache[uid] ?? 'weekly';
    final startDate  = _leaseStartCache[uid];
    final cycle      = int.tryParse(cycleCtrl.text) ?? 0;
    final amountRaw  = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
    DateTime? lastDate;
    if (startDate != null && cycle > 0) {
      if (leaseType == 'daily') { lastDate = startDate.add(Duration(days: cycle)); }
      else if (leaseType == 'weekly') { lastDate = startDate.add(Duration(days: 7 * (cycle - 1))); }
      else { lastDate = _calcMonthlyDate(startDate, cycle - 1, startDate.day); }
    }
    final totalAmount = amountRaw * cycle;
    final nameStr = data['name'] as String? ?? '?';
    final initial = nameStr.isNotEmpty ? nameStr.substring(0, 1) : '?';

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(14, 4, 14, 4), childrenPadding: EdgeInsets.zero, clipBehavior: Clip.none,
        iconColor: _teal, collapsedIconColor: _text2,
        leading: Container(width: _rmAvatarSize, height: _rmAvatarSize,
            decoration: BoxDecoration(color: _rmAvatarBg, border: Border.all(color: _rmAvatarBorder), borderRadius: BorderRadius.circular(9)),
            child: Center(child: Text(initial, style: const TextStyle(color: _rmAvatarText, fontSize: _rmAvatarFontSize, fontWeight: FontWeight.w700)))),
        title: Row(children: [
          Flexible(child: Text(data['name'] ?? "", overflow: TextOverflow.ellipsis, style: const TextStyle(color: _rmNameColor, fontWeight: FontWeight.w700, fontSize: _rmNameFontSize))),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _RiderHistoryPage(name: data['name'] ?? "라이더", uid: uid))),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(border: Border.all(color: _rmHistBtnBorder), borderRadius: BorderRadius.circular(6)),
                child: const Text("출금내역", style: TextStyle(color: _rmHistBtnColor, fontSize: _rmHistBtnFontSize, fontWeight: FontWeight.w700)),
          ),
          ),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(onTap: () => _call(data['phone'] ?? ""), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: _rmCallColor.withAlpha(20), border: Border.all(color: _rmCallColor.withAlpha(60)), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.wifi_calling_3, color: _rmCallColor, size: 15))),
          const SizedBox(width: 6),
          GestureDetector(onTap: () => _sms(data['phone'] ?? ""),  child: Container(width: 32, height: 32, decoration: BoxDecoration(color: _rmSmsColor.withAlpha(20), border: Border.all(color: _rmSmsColor.withAlpha(60)), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.sms, color: _rmSmsColor, size: 15))),
          const SizedBox(width: 6),
        ]),
        children: [Container(
          color: _surface.withAlpha(200), padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 은행 박스
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: isEditingAccount ? () => _showBankPicker(uid, bankCtrl) : null,
                child: Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: isEditingAccount ? _teal.withAlpha(100) : _borderDim)),
                  child: Row(children: [
                    Expanded(child: Text(bankCtrl.text.isNotEmpty ? bankCtrl.text : "은행 선택", style: const TextStyle(color: _rmFieldTextColor, fontSize: _rmFieldFontSize), overflow: TextOverflow.ellipsis)),
                    if (isEditingAccount) const Icon(Icons.arrow_drop_down, color: _teal, size: 18),
                  ]),
                ),
              )),
              const SizedBox(width: 8),
              SizedBox(width: 46, height: 38, child: GlassShineButton(
                label: isEditingAccount ? "저장" : "수정",
                onPressed: () { if (isEditingAccount) { _saveAccountInfo(uid, bankCtrl.text, accountCtrl.text); } else { setState(() => riderAccountEditMode[uid] = true); } },
                accent: _teal,
                width: 46,
                height: 38,
                radius: 8,
                fontSize: _rmEditBtnFontSize,
              )),
            ]),
            const SizedBox(height: _rmGapRowSmall),
            // 계좌번호 박스
            SizedBox(height: 38, child: TextField(
              controller: accountCtrl, enabled: isEditingAccount, keyboardType: TextInputType.number,
              style: const TextStyle(color: _rmFieldTextColor, fontSize: _rmFieldFontSize), cursorColor: _teal,
              decoration: InputDecoration(hintText: "계좌번호", hintStyle: const TextStyle(color: _rmFieldTextColor, fontSize: _rmFieldFontSize), filled: true, fillColor: _surface, contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _borderDim)),
                enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _teal.withAlpha(100))),
                focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _teal, width: 1.5)),
              ),
            )),
            const SizedBox(height: _rmGapRow),
            // User ID
            Row(children: [
              Expanded(child: SizedBox(height: 38, child: TextField(
                controller: idCtrl, enabled: isEditingId,
                style: const TextStyle(color: _rmFieldTextColor, fontSize: _rmFieldFontSize), cursorColor: _teal,
                decoration: InputDecoration(hintText: "User ID", hintStyle: const TextStyle(color: _rmFieldTextColor, fontSize: _rmFieldFontSize), filled: true, fillColor: _surface, contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _borderDim)),
                  enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _teal.withAlpha(100))),
                  focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _teal, width: 1.5)),
                ),
              ))),
              const SizedBox(width: 8),
              SizedBox(width: 46, height: 38, child: GlassShineButton(
                label: isEditingId ? "저장" : "수정",
                onPressed: () { if (isEditingId) { _saveReportId(uid, idCtrl.text); } else { setState(() => riderIdEditMode[uid] = true); } },
                accent: _teal,
                width: 46,
                height: 38,
                radius: 8,
                fontSize: _rmEditBtnFontSize,
              )),
            ]),
            const SizedBox(height: _rmGapToLease),
            // 리스비 섹션
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: _elevated.withAlpha(80))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  const Text("리스비", style: TextStyle(color: _rmLeaseTitleColor, fontSize: _rmLeaseTitleFontSize, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () { if (isEditingLease) { _saveLease(uid); } else { setState(() => riderLeaseEditMode[uid] = true); } },
                    child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: isEditingLease ? _teal : Colors.transparent, border: Border.all(color: _elevated), borderRadius: BorderRadius.circular(6)),
                      child: Text(isEditingLease ? "저장" : "수정", style: TextStyle(color: isEditingLease ? _surface : _teal, fontSize: _rmLeaseBtnFontSize, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(onTap: () => _resetLease(uid), child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: _elevated), borderRadius: BorderRadius.circular(6)),
                    child: const Text("초기화", style: TextStyle(color: _rmLeaseSmallBtnColor, fontSize: _rmLeaseBtnFontSize)),
                  )),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  _leaseTypeBtn(uid, 'daily',  '매일',  isEditingLease),
                  const SizedBox(width: 4),
                  _leaseTypeBtn(uid, 'weekly', '주1회', isEditingLease),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: isEditingLease ? () => setState(() => _leaseTypeCache[uid] = 'monthly_fixed') : null,
                    child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: leaseType == 'monthly_fixed' ? _teal : Colors.transparent, border: Border.all(color: leaseType == 'monthly_fixed' ? _teal : _borderDim), borderRadius: BorderRadius.circular(5)),
                      child: Text("매월", style: TextStyle(color: leaseType == 'monthly_fixed' ? _surface : _text2, fontSize: _rmLeaseBtnFontSize, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 34, height: 26, child: TextField(
                    controller: cycleCtrl, enabled: isEditingLease, keyboardType: TextInputType.number, textAlign: TextAlign.center,
                    style: const TextStyle(color: _text, fontSize: _rmLeaseInputFontSize), cursorColor: _teal, onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(isDense: true, hintText: "0", hintStyle: const TextStyle(color: _text2, fontSize: _rmLeaseHintFontSize), filled: true, fillColor: _surface, contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: _teal.withAlpha(80))),
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: _borderDim)),
                      focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: _teal))),
                  )),
                  Text(leaseType == 'daily' ? "  일" : "  회차", style: const TextStyle(color: _rmLeaseUnitColor, fontSize: _rmLeaseUnitFontSize)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: isEditingLease ? () async {
                      final p = await showDatePicker(context: context, initialDate: startDate ?? DateTime.now(), firstDate: DateTime(2026), lastDate: DateTime(2030), builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _teal)), child: child!));
                      if (p != null) setState(() => _leaseStartCache[uid] = p);
                    } : null,
                    child: Container(height: 32, decoration: BoxDecoration(color: _surface, border: Border.all(color: isEditingLease ? _teal.withAlpha(100) : _borderDim), borderRadius: BorderRadius.circular(7)), padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(children: [
                        Icon(Icons.calendar_today_rounded, color: isEditingLease ? _teal : _text2, size: 12), const SizedBox(width: 4),
                        Expanded(child: Text(startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : "시작일", textAlign: TextAlign.right, style: TextStyle(color: startDate != null ? _text : _text2, fontSize: _rmLeaseInputFontSize))),
                      ]),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: Row(children: [
                    Expanded(child: SizedBox(height: 32, child: TextField(
                      controller: amountCtrl, enabled: isEditingLease, keyboardType: TextInputType.number, textAlign: TextAlign.right,
                      style: const TextStyle(color: _text, fontSize: _rmLeaseInputFontSize), cursorColor: _teal,
                      onChanged: (v) { final raw = v.replaceAll(',', ''); final n = int.tryParse(raw); if (n != null) { final f = NumberFormat('#,###').format(n); if (f != v) amountCtrl.value = TextEditingValue(text: f, selection: TextSelection.collapsed(offset: f.length)); } setState(() {}); },
                      decoration: InputDecoration(isDense: true, hintText: "1회차금액", hintStyle: const TextStyle(color: _text2, fontSize: _rmLeaseHintFontSize), filled: true, fillColor: _surface, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                        enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide(color: _teal.withAlpha(100))),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: _borderDim)),
                        focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: _teal))),
                    ))),
                    const SizedBox(width: 4), const Text("원", style: TextStyle(color: _rmLeaseUnitColor, fontSize: _rmLeaseUnitFontSize)),
                  ])),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: Container(height: 32, decoration: BoxDecoration(color: _surface, border: Border.all(color: _elevated), borderRadius: BorderRadius.circular(7)), padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(children: [const Icon(Icons.event_rounded, color: _text2, size: 12), const SizedBox(width: 4), Expanded(child: Text(lastDate != null ? DateFormat('yyyy-MM-dd').format(lastDate) : "마지막일", textAlign: TextAlign.right, style: const TextStyle(color: _text2, fontSize: _rmLeaseInputFontSize)))]),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: Row(children: [
                    Expanded(child: Container(height: 32, decoration: BoxDecoration(color: _surface, border: Border.all(color: _elevated), borderRadius: BorderRadius.circular(7)), padding: const EdgeInsets.symmetric(horizontal: 8), alignment: Alignment.centerRight,
                      child: Text(totalAmount > 0 ? NumberFormat('#,###').format(totalAmount.truncate()) : "총금액", style: const TextStyle(color: _text2, fontSize: _rmLeaseInputFontSize)),
                    )),
                    const SizedBox(width: 4), const Text("원", style: TextStyle(color: _rmLeaseUnitColor, fontSize: _rmLeaseUnitFontSize)),
                  ])),
                ]),
                if (leaseType != 'daily')
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('lease_payments').where('uid', isEqualTo: uid).where('isPaid', isEqualTo: true).orderBy('cycle', descending: true).limit(1).snapshots(),
                    builder: (_, snap) {
                      if (!snap.hasData || snap.data!.docs.isEmpty) return const SizedBox.shrink();
                      final d = snap.data!.docs.first.data() as Map<String, dynamic>;
                      final pCycle = d['cycle'] as int? ?? 0; final pAmount = d['amount'] as int? ?? 0;
                      final paidAt = (d['paidAt'] as Timestamp?)?.toDate();
                      final dateStr = paidAt != null ? DateFormat('yyyy-MM-dd').format(paidAt) : '';
                      return Column(children: [
                        Container(height: 1, color: _borderDim, margin: const EdgeInsets.symmetric(vertical: 6)),
                        Row(children: [
                          Text("$pCycle회차", style: const TextStyle(color: _text2, fontSize: _rmLeasePaidFontSize)), const SizedBox(width: 8),
                          Text(dateStr, style: const TextStyle(color: _text2, fontSize: _rmLeasePaidFontSize)), const Spacer(),
                          Text("${NumberFormat('#,###').format(pAmount)} 원", style: const TextStyle(color: _teal, fontSize: _rmLeasePaidFontSize, fontWeight: FontWeight.w700)),
                        ]),
                      ]);
                    },
                  ),
              ]),
            ),
          ]),
        )],
      ),
    );
  }

  Widget _leaseTypeBtn(String uid, String type, String label, bool isEditing) {
    final selected = (_leaseTypeCache[uid] ?? 'weekly') == type;
    return GestureDetector(
      onTap: isEditing ? () => setState(() => _leaseTypeCache[uid] = type) : null,
      child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: selected ? _teal : Colors.transparent, border: Border.all(color: selected ? _teal : _borderDim), borderRadius: BorderRadius.circular(5)),
        child: Text(label, style: TextStyle(color: selected ? _surface : _text2, fontSize: _rmLeaseBtnFontSize, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// === _LeaseAlertsPage ========================================================================

// ═══════════════════════ 8-2. 리스비 (로직) ═══════════════════════
class _LeaseAlertsPage extends StatefulWidget {
  final bool embedded;
  const _LeaseAlertsPage({this.embedded = false});
  @override
  State<_LeaseAlertsPage> createState() => _LeaseAlertsPageState();
}

class _LeaseAlertsPageState extends State<_LeaseAlertsPage> {

  final Map<String, bool> _expanded = {};

  Future<void> _confirm(String docId, String uid, String riderName, int cycle, int amount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(
            color: _surface, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _elevated, width: 1),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_outline_rounded, color: _teal, size: 36),
            const SizedBox(height: 12),
            Text("$riderName 님 $cycle회차",
                style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text("${NumberFormat('#,###').format(amount)}원",
                style: const TextStyle(color: _teal, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text("입금을 확인하시겠습니까?",
                style: TextStyle(color: _text2, fontSize: 13)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GlassShineButton(
                label: "취소",
                onPressed: () => Navigator.pop(ctx, false),
                accent: _text2,
                textColor: _text2,
                pill: true,
                height: 46,
                fontSize: 13,
              )),
              const SizedBox(width: 10),
              Expanded(child: GlassShineButton(
                label: "확인",
                onPressed: () => Navigator.pop(ctx, true),
                accent: _teal,
                pill: true,
                height: 46,
                fontSize: 13,
              )),
            ]),
          ]),
        ),
      ),
    );
    if (confirmed != true) return;
    await FirebaseFirestore.instance.collection('lease_payments').doc(docId).update({
      'isPaid': true, 'paidAt': FieldValue.serverTimestamp(), 'riderPaid': false,
    });
    // 기사 leaseNewAlert 초기화
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'leaseNewAlert': false});
    } catch (_) {}
    if (mounted) _showDone("$riderName 님 $cycle회차\n${NumberFormat('#,###').format(amount)}원\n납부 확인 완료!");
  }

  Future<void> _cancelRiderPaid(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('lease_payments').doc(docId).update({'riderPaid': false});
    } catch (_) {}
  }

  // 주1회/매월: 다음 미납 회차를 완납 처리 (+1회)
  Future<void> _payNextCycle(
      List<Map<String, dynamic>> payments, String uid, String riderName) async {
    final unpaid = payments.where((p) => p['isPaid'] != true).toList()
      ..sort((a, b) =>
          ((a['cycle'] as int?) ?? 0).compareTo((b['cycle'] as int?) ?? 0));
    if (unpaid.isEmpty) return;
    final p = unpaid.first;
    await _confirm(
      p['_docId'] as String? ?? '',
      uid,
      riderName,
      p['cycle'] as int? ?? 0,
      p['amount'] as int? ?? 0,
    );
  }

  void _showDone(String msg) {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _elevated, width: 1)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(msg, style: const TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
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

  Widget _infoRow(String label, String value,
          {Color vc = _laInfoValueColor,
          Color labelColor = _laInfoLabelColor,
          double labelFs = _laInfoFontSize}) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: labelFs)),
        Text(value, style: TextStyle(color: vc, fontSize: _laInfoFontSize, fontWeight: FontWeight.w600)),
      ]);

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final body = StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('lease_payments').orderBy('riderName').snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: _teal));
          if (snap.data!.docs.isEmpty) return const Center(child: Text("리스비 납기 내역이 없습니다.", style: TextStyle(color: _text2, fontSize: 14)));

          // 라이더별 그룹핑
          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (final doc in snap.data!.docs) {
            final d    = doc.data() as Map<String, dynamic>;
            final name = d['riderName'] as String? ?? '';
            grouped.putIfAbsent(name, () => []);
            grouped[name]!.add({...d, '_docId': doc.id});
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(_laListPadL, _laListPadT, _laListPadR, _laListPadB),
            children: grouped.entries.map((entry) {
              final riderName  = entry.key;
              final payments   = entry.value
                ..sort((a, b) => (a['cycle'] as int? ?? 0).compareTo(b['cycle'] as int? ?? 0));
              final paidCount     = payments.where((p) => p['isPaid'] == true).length;
              final totalCount   = payments.length;
              final isExpanded   = _expanded[riderName] ?? false;
              final isDaily      = payments.any((p) => (p['leaseType'] as String?) == 'daily');
              final hasDue       = payments.any((p) =>
                  (p['dueDate'] as String? ?? '').compareTo(today) <= 0 && p['isPaid'] != true);
              final isDueToday   = payments.any((p) =>
                  (p['dueDate'] as String? ?? '') == today && p['isPaid'] != true);
              final riderPaidList = payments.where((p) =>
                  p['riderPaid'] == true && p['isPaid'] != true).toList();
              final hasRiderPaid = riderPaidList.isNotEmpty;
              final uid          = payments.first['uid'] as String? ?? '';

              Color borderColor = _elevated;
              if (paidCount == totalCount) borderColor = _teal.withAlpha(60);
              if (hasDue)                  borderColor = _amber.withAlpha(100);
              if (hasRiderPaid)            borderColor = _teal.withAlpha(120);

              // 리스비 요약 정보 (lease_payments 데이터 기반)
              final leaseType  = payments.first['leaseType']  as String? ?? '';
              final leaseAmt   = payments.first['amount']     as int?    ?? 0;
              final totalCycle = payments.first['totalCycle'] as int?    ?? 0;
              final dueDates   = payments
                  .map((p) => p['dueDate'] as String? ?? '')
                  .where((d) => d.isNotEmpty).toList()..sort();
              final startShort = dueDates.isNotEmpty
                  ? (dueDates.first.length >= 10 ? dueDates.first.substring(5) : dueDates.first) : '';
              final endShort   = dueDates.isNotEmpty
                  ? (dueDates.last.length  >= 10 ? dueDates.last.substring(5)  : dueDates.last)  : '';
              final typeLabel  = isDaily ? '매일' : (leaseType == 'weekly' ? '주1회' : '매월');
              final cycleLabel = isDaily ? '일' : '회차';
              final totalAmt   = leaseAmt * totalCycle;
              final paidAmt    = leaseAmt * paidCount;
              final progress   = totalCount > 0 ? paidCount / totalCount : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _surface, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor,
                      width: hasRiderPaid || isDueToday || (hasDue && !isDueToday) ? 1.5 : 1),
                  boxShadow: _cardShadow,
                ),
                child: Column(children: [
                  // 라이더 헤더 (이름 누르면 펼치기)
                  GestureDetector(
                    onTap: () => setState(() => _expanded[riderName] = !isExpanded),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(children: [
                        Text(riderName, style: const TextStyle(
                            color: _text,
                            fontSize: _laRiderNameFontSize, fontWeight: FontWeight.w700)),
                        if (isDaily) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: _amber.withAlpha(30), borderRadius: BorderRadius.circular(4), border: Border.all(color: _amber.withAlpha(80))),
                            child: const Text("매일", style: TextStyle(color: _amber, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                        const Spacer(),
                        if (hasRiderPaid) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: _teal.withAlpha(20), borderRadius: BorderRadius.circular(5), border: Border.all(color: _teal.withAlpha(80))),
                          child: const Text("입금완료!", style: TextStyle(color: _teal, fontSize: _laBadgeFontSize, fontWeight: FontWeight.w700)),
                        ) else if (isDueToday) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: _teal.withAlpha(20), borderRadius: BorderRadius.circular(5), border: Border.all(color: _teal.withAlpha(80))),
                          child: const Text("오늘 납기", style: TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w700)),
                        ) else if (hasDue) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: _teal.withAlpha(20), borderRadius: BorderRadius.circular(5), border: Border.all(color: _teal.withAlpha(80))),
                          child: const Text("납기초과", style: TextStyle(color: _teal, fontSize: _laBadgeFontSize, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 6),
                        Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: _text2, size: _laChevronSize),
                      ]),
                    ),
                  ),

                  // 펼침: 리스비전체현황 카드 + (매주/매월) 회차별 입금확인
                  if (isExpanded) ...[
                    Container(height: 1, color: _borderDim),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(children: [

                        // 리스비 전체 현황 카드 (기사페이지 동일)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          decoration: BoxDecoration(
                            color: _surface, borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _laCardBorder, width: _laCardBorderWidth),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              const Icon(Icons.moped, color: _teal, size: 16),
                              const SizedBox(width: 6),
                              const Text("리스비 전체 현황", style: TextStyle(color: _laCardTitleColor, fontSize: _laCardTitleFontSize, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFF18203A), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0x4D303854))),
                                child: Text(typeLabel, style: const TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ]),
                            Container(height: 1, color: _elevated.withValues(alpha: 0.6), margin: const EdgeInsets.symmetric(vertical: 10)),
                            _infoRow("1$cycleLabel 금액", "${NumberFormat('#,###').format(leaseAmt)} 원"),
                            const SizedBox(height: 5),
                            _infoRow("총 $cycleLabel", "$totalCycle $cycleLabel"),
                            const SizedBox(height: 5),
                            _infoRow("총 리스비", "${NumberFormat('#,###').format(totalAmt)} 원"),
                            const SizedBox(height: 5),
                            Row(children: [
                              const Text("기간", style: TextStyle(color: _text, fontSize: _laRowFontSize)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: _teal.withAlpha(80)),
                                ),
                                child: Text(startShort, style: const TextStyle(color: _teal, fontSize: _laRowFontSize, fontWeight: FontWeight.w600)),
                              ),
                              const Text("  ~  ", style: TextStyle(color: _text, fontSize: _laRowFontSize)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: (dueDates.isNotEmpty && dueDates.last.compareTo(today) < 0 && paidCount < totalCount)
                                        ? _amber.withAlpha(120) : _teal.withAlpha(80),
                                  ),
                                ),
                                child: Text(endShort, style: TextStyle(
                                  color: (dueDates.isNotEmpty && dueDates.last.compareTo(today) < 0 && paidCount < totalCount)
                                      ? _amber : _teal,
                                  fontSize: _laRowFontSize, fontWeight: FontWeight.w600,
                                )),
                              ),
                            ]),
                            if (isDaily) ...[
                              const SizedBox(height: 5),
                              _infoRow("납부 방식", "출금 시 자동 공제", vc: _amber, labelColor: _amber, labelFs: 13),
                            ],
                            const SizedBox(height: 10),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text("진행 현황", style: TextStyle(color: _amber, fontSize: _laRowFontSize)),
                              RichText(text: TextSpan(children: [
                                TextSpan(text: "$paidCount",
                                    style: const TextStyle(color: _amber, fontSize: _laRowValueFontSize, fontWeight: FontWeight.w700)),
                                TextSpan(text: " / $totalCount $cycleLabel",
                                    style: const TextStyle(color: _amber, fontSize: 17)),
                              ])),
                            ]),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFF18203A),
                                valueColor: const AlwaysStoppedAnimation<Color>(_teal),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text("납부 완료", style: TextStyle(color: _amber, fontSize: _laRowFontSize)),
                              Text("${NumberFormat('#,###').format(paidAmt)} 원",
                                  style: const TextStyle(color: _amber, fontSize: _laRowFontSize, fontWeight: FontWeight.w600)),
                            ]),
                            if (totalAmt > paidAmt) ...[
                              const SizedBox(height: 3),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text("잔여 금액", style: TextStyle(color: _teal, fontSize: _laRowFontSize)),
                                Text("${NumberFormat('#,###').format(totalAmt - paidAmt)} 원",
                                    style: const TextStyle(color: _teal, fontSize: _laRowFontSize)),
                              ]),
                            ],
                          ]),
                        ),

                        // riderPaid == true 일 때: 입금확인 + 취소 버튼
                        if (hasRiderPaid) ...[
                          const SizedBox(height: 8),
                          Builder(builder: (_) {
                            final p      = riderPaidList.first;
                            final docId  = p['_docId'] as String? ?? '';
                            final cycle  = p['cycle']  as int?    ?? 0;
                            final amount = p['amount'] as int?    ?? 0;
                            return Row(children: [
                              Expanded(child: GlassShineButton(
                                label: "취소",
                                onPressed: () => _cancelRiderPaid(docId),
                                accent: _text2,
                                textColor: _text2,
                                height: _laBtnHeight,
                                radius: _laBtnRadius,
                                fontSize: _laBtnFontSize,
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: GlassShineButton(
                                label: "입금확인",
                                onPressed: () => _confirm(docId, uid, riderName, cycle, amount),
                                accent: _teal,
                                height: _laBtnHeight,
                                radius: _laBtnRadius,
                                fontSize: _laBtnFontSize,
                              )),
                            ]);
                          }),
                        ],

                        // 주1회/매월: 관리자 수동 입금완료 (누르면 다음 미납 회차 +1)
                        if (!isDaily && !hasRiderPaid && paidCount < totalCount) ...[
                          const SizedBox(height: 8),
                          GlassShineButton(
                            label: "입금완료 (+1회)",
                            onPressed: () =>
                                _payNextCycle(payments, uid, riderName),
                            accent: _teal,
                            height: _laBtnHeight,
                            radius: _laBtnRadius,
                            fontSize: _laBtnFontSize,
                          ),
                        ],
                      ]),
                    ),
                  ],
                ]),
              );
            }).toList(),
          );
        },
      );
    return widget.embedded
        ? body
        : _adminPanelScaffold(context, "리스비 납기 현황", body);
  }
}


// ═══════════════════════ 8-3. 라이더 출금내역 (로직) ═══════════════════════
class _RiderHistoryPage extends StatefulWidget {
  final String name, uid;
  const _RiderHistoryPage({required this.name, required this.uid});
  @override
  State<_RiderHistoryPage> createState() => _RiderHistoryPageState();
}

class _RiderHistoryPageState extends State<_RiderHistoryPage>
    with SingleTickerProviderStateMixin {

  late TabController _tc;

  // 정산내역 탭
  List<Map<String, dynamic>> _logs       = [];
  bool                        _logsLoaded = false;
  final Map<String, bool>    _logExp     = {};  // 정산 배치 펼치기
  final Map<String, bool>    _dateExp    = {};  // 날짜별 펼치기

  // 누적정산 탭
  DateTime? _start, _end, _startApplied, _endApplied;
  bool   _cumLoaded  = false;
  bool   _cumLoading = false;
  bool   _taxExp = false, _promoExp = false, _deduExp = false, _commExp = false;
  double _gross = 0, _emp = 0, _acc = 0, _tax = 0;
  double _mission = 0, _perOrder = 0, _range = 0;
  double _ins = 0, _wdFee = 0, _comm = 0, _lease = 0, _total = 0;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this);
    _loadLogs();
    _loadCumulative();
  }

  @override
  void dispose() { _tc.dispose(); super.dispose(); }

  // ── 데이터 로더 ──────────────────────────────────────────────────

  Future<void> _loadLogs() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('admin_settlement_logs')
          .where('uid',    isEqualTo: widget.uid)
          .where('status', isEqualTo: '지급완료')
          .orderBy('approvedAt', descending: true)
          .get();
      final list = snap.docs.map((doc) {
        final d = Map<String, dynamic>.from(doc.data());
        d['_docId'] = doc.id;
        return d;
      }).toList();
      if (mounted) setState(() { _logs = list; _logsLoaded = true; });
    } catch (e) {
      if (mounted) setState(() => _logsLoaded = true);
    }
  }

  Future<void> _loadCumulative() async {
    if (_cumLoading) return;
    setState(() { _cumLoading = true; _cumLoaded = false; });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('admin_settlement_logs')
          .where('uid',    isEqualTo: widget.uid)
          .where('status', isEqualTo: '지급완료')
          .get();
      double gross = 0, emp = 0, acc = 0, tax = 0;
      double mission = 0, perOrder = 0, range = 0, ins = 0, wdFee = 0, comm = 0, lease = 0, total = 0;

      final hasFilter = _startApplied != null || _endApplied != null;
      final endDay = _endApplied != null
          ? DateTime(_endApplied!.year, _endApplied!.month, _endApplied!.day, 23, 59, 59)
          : null;

      for (final doc in snap.docs) {
        final data = doc.data();
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
              wdFee    += (item['withdrawalFee']  as num?)?.toDouble() ?? 0;
              comm     += (item['commissionAmt']  as num?)?.toDouble() ?? 0;
            }
          } else {
            final msg = data['message']?.toString() ?? '';
            gross    += _rx(msg, '배달수수료\\(세전\\)').abs();
            emp      += _rx(msg, '고용보험').abs();
            acc      += _rx(msg, '산재보험').abs();
            tax      += _rx(msg, '원천세').abs();
            mission  += _rx(msg, '미션금액').abs();
            perOrder += _rx(msg, '건당프로모션').abs();
            range    += _rx(msg, '구간프로모션').abs();
            ins      += _rx(msg, '시간제보험').abs();
            wdFee    += _rx(msg, '출금수수료').abs();
            comm     += _rxComm(msg);
            lease    += _rx(msg, '리스비\\(일\\)').abs();
          }
        } else {
          int matchedCount = 0;
          for (final item in items) {
            final itemDate = DateTime.tryParse(item['date'] as String? ?? '');
            if (itemDate == null) continue;
            if (_startApplied != null && itemDate.isBefore(_startApplied!)) continue;
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
            wdFee    += (item['withdrawalFee']  as num?)?.toDouble() ?? 0;
            comm     += (item['commissionAmt']  as num?)?.toDouble() ?? 0;
          }
          if (matchedCount > 0 && items.isNotEmpty) {
            final fullLease = (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
            lease += fullLease * matchedCount / items.length;
          }
        }
      }

      if (hasFilter) {
        total = gross + (mission + perOrder + range) - (emp + acc + tax) - (wdFee + comm) - ins - lease;
      }

      if (mounted) {
        setState(() {
          _gross = gross; _emp = emp; _acc = acc; _tax = tax;
          _mission = mission; _perOrder = perOrder; _range = range;
          _ins = ins; _wdFee = wdFee; _comm = comm; _total = total;
          _lease = lease;
          _cumLoaded = true; _cumLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _cumLoaded = true; _cumLoading = false; });
    }
  }

  // ── 헬퍼 ──────────────────────────────────────────────────

  double _rx(String msg, String key) {
    final m = RegExp('$key[^:：]*[：:][\\s]*([-\\d,]+)').firstMatch(msg);
    if (m == null) return 0;
    return double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
  }
  double _rxComm(String msg) {
    final m = RegExp(r'(?<![가-힣])협력사수수료\([^)]+\)\s*[：:]\s*([\d,]+)').firstMatch(msg);
    if (m == null) return 0;
    return double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
  }
  String _fmtC(double v) => NumberFormat('#,###').format(v);

  // ── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_panelOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(_panelRadius),
              border: Border.all(
                  color: _elevated, width: 1),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_panelRadius),
              child: Column(children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: _text, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    RichText(
                        text: TextSpan(
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            children: [
                          TextSpan(text: widget.name,
                              style: const TextStyle(color: _teal, fontSize: 20)),
                          const TextSpan(text: " 님 출금 내역",
                              style: TextStyle(color: _text, fontSize: 19)),
                        ])),
                  ]),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: _subDivMarginH),
                  color: _subDivColor),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 8),
                  padding: const EdgeInsets.all(_tabTrackPad),
                  decoration: BoxDecoration(
                      color: _tabTrackColor,
                      borderRadius: BorderRadius.circular(_tabTrackRadius)),
                  child: TabBar(
                    controller: _tc,
                    indicator: BoxDecoration(
                        color: _tabIndicatorColor,
                        borderRadius: BorderRadius.circular(_tabIndicatorRadius),
                        border: Border.all(color: _tabIndicatorBorder, width: 1)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: _tabSelColor,
                    unselectedLabelColor: _tabUnselColor,
                    dividerColor: Colors.transparent,
                    labelStyle:
                        const TextStyle(fontWeight: FontWeight.w700, fontSize: _tabFontSize),
                    unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.w400, fontSize: _tabFontSize),
                    tabs: const [Tab(text: "정산 내역"), Tab(text: "누적 정산")],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tc,
                    children: [_settlementTab(), _cumulativeTab()],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── 탭 1: 정산내역 ──────────────────────────────────────────────────

  Widget _settlementTab() {
    if (!_logsLoaded) return const Center(child: CircularProgressIndicator(color: _elevated));
    if (_logs.isEmpty) {
      return const Center(
          child: Text("출금 내역이 없습니다.", style: TextStyle(color: _text2, fontSize: 14)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(_rhSettleOuterL, _rhSettleOuterT, _rhSettleOuterR, _rhSettleOuterB),
      itemCount: _logs.length,
      itemBuilder: (_, i) => _logCard(_logs[i]),
    );
  }

  Widget _logCard(Map<String, dynamic> data) {
    final docId      = data['_docId'] as String? ?? '';
    final amount     = (data['amount'] as num?)?.toDouble() ?? 0;
    final items      = (data['items'] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    final approvedAt = (data['approvedAt'] as Timestamp?)?.toDate();
    final dateStr    = approvedAt != null ? DateFormat('yyyy-MM-dd').format(approvedAt) : '';
    final logExp     = _logExp[docId] ?? false;

    // 날짜 범위 라벨
    String dateLabel;
    if (items.isNotEmpty) {
      final first = items.first['date'] as String? ?? '';
      final last  = items.last['date']  as String? ?? '';
      final fs = first.length >= 10 ? first.substring(5) : first;
      final ls = last.length  >= 10 ? last.substring(5)  : last;
      dateLabel = items.length == 1 ? fs : "$fs ~ $ls";
    } else {
      dateLabel = dateStr.length >= 10 ? dateStr.substring(5) : dateStr;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: _rhLogCardGap),
      decoration: BoxDecoration(
        color: _surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _elevated, width: _rhCardBorderWidth),
      ),
      child: Column(children: [

        // 카드 헤더
        GestureDetector(
          onTap: () => setState(() => _logExp[docId] = !logExp),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _rhLogHeadPadH, vertical: _rhLogHeadPadV),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _surface, borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: _elevated.withAlpha(150)),
                ),
                child: Text(dateLabel,
                    style: const TextStyle(color: _rhDateChipColor, fontSize: _rhDateChipFontSize, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              if (items.isNotEmpty)
                Text("  ${items.length}일", style: const TextStyle(color: _rhDaysColor, fontSize: _rhDaysFontSize)),
              const Spacer(),
              Text("${_fmtC(amount)} 원",
                  style: const TextStyle(color: _rhHeadAmtColor, fontSize: _rhHeadAmtFontSize, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),

        // 펼침 내용
        if (logExp) ...[
          Container(height: 1, color: _rhDividerColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(_rhLogBodyPadL, _rhLogBodyPadT, _rhLogBodyPadR, _rhLogBodyPadB),
            child: Column(children: [
              if (items.isNotEmpty) ...[
                // 리스비를 날짜카드 안쪽(출금수수료 밑)으로 이동
                for (int i = 0; i < items.length; i++)
                  _dateItemCard(items[i], docId,
                      leasePerDay: (() {
                        final ld = (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
                        return items.isNotEmpty ? ld / items.length : 0.0;
                      })()),
              ] else
                _oldMsgView(data),

            ]),
          ),
        ],
      ]),
    );
  }

  Widget _dateItemCard(Map<String, dynamic> item, String docId, {double leasePerDay = 0}) {
    final iDate   = item['date']            as String? ?? '';
    final iFinal  = (item['finalAmount']    as num?)?.toDouble() ?? 0;
    final key     = '${docId}_$iDate';
    final iExp    = _dateExp[key] ?? false;
    final iShort  = iDate.length >= 10 ? iDate.substring(5) : iDate;
    final actualFinal = iFinal - leasePerDay;

    final iDel    = (item['deliveryFee']    as num?)?.toDouble() ?? 0;
    final iPromo  = (item['promoTotal']     as num?)?.toDouble() ?? 0;
    final iTax    = (item['tax']            as num?)?.toDouble() ?? 0;
    final iComm   = (item['commissionAmt']  as num?)?.toDouble() ?? 0;
    final iWd     = (item['withdrawalFee']  as num?)?.toDouble() ?? 0;
    final iPOrd   = (item['perOrderAmount'] as num?)?.toDouble() ?? 0;
    final iRng    = (item['rangeAmount']    as num?)?.toDouble() ?? 0;
    final iETax   = (item['employmentTax']  as num?)?.toDouble() ?? 0;
    final iATax   = (item['accidentTax']    as num?)?.toDouble() ?? 0;
    final iITax   = (item['incomeTax']      as num?)?.toDouble() ?? 0;
    final iIns    = (item['insuranceFee']   as num?)?.toDouble() ?? 0;
    final iFee    = iWd + iComm;
    final iDedu   = iIns + leasePerDay;

    bool tog(String k) => _dateExp[k] ?? false;
    void togSet(String k) => setState(() => _dateExp[k] = !(_dateExp[k] ?? false));

    Widget subGroup(List<Widget> ch) => Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(color: _surface.withAlpha(180), borderRadius: BorderRadius.circular(6), border: Border.all(color: _elevated)),
      child: Column(children: ch),
    );
    Widget subRow(String label, String val, {Color lc = _rhSubColor, Color vc = _rhSubColor}) =>
        Padding(padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: TextStyle(color: lc, fontSize: _rhSubFontSize)),
            Text(val,   style: TextStyle(color: vc, fontSize: _rhSubFontSize)),
          ]));
    Widget togRow(String label, double v, Color vc, String k) =>
        GestureDetector(
          onTap: () => togSet(k),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Text(label, style: const TextStyle(color: _rhTogLabelColor, fontSize: _rhTogFontSize, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(tog(k) ? Icons.expand_less : Icons.expand_more, color: _rhTogLabelColor, size: _rhTogIconSize),
              const Spacer(),
              Text("${_fmtC(v)} 원", style: TextStyle(color: vc, fontSize: _rhTogFontSize)),
            ]),
          ),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: _rhItemGap),
      decoration: BoxDecoration(
        color: _surface, borderRadius: BorderRadius.circular(9),
        border: Border.all(color: iExp ? _teal.withAlpha(80) : _elevated),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _dateExp[key] = !iExp),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _rhItemHeadPadH, vertical: _rhItemHeadPadV),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(5), border: Border.all(color: _elevated)),
                child: Text(iShort, style: const TextStyle(color: _rhItemChipColor, fontSize: _rhItemChipFontSize, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _rhPaidBadgeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _rhPaidBadgeColor.withAlpha(80)),
                ),
                child: const Text("입금완료",
                    style: TextStyle(color: _rhPaidBadgeColor, fontSize: _rhPaidFontSize, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
        if (iExp) ...[
          Container(height: 1, color: _borderDim),
          Padding(
            padding: const EdgeInsets.fromLTRB(_rhItemBodyPadL, _rhItemBodyPadT, _rhItemBodyPadR, _rhItemBodyPadB),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("배달수수료 (세전)", style: TextStyle(color: _rhMainColor, fontSize: _rhMainFontSize, fontWeight: FontWeight.w500)),
                  Text("${_fmtC(iDel)} 원", style: const TextStyle(color: _rhMainColor, fontSize: _rhMainFontSize)),
                ]),
              ),
              togRow("지원금합계", iPromo, _text, '${key}_promo'),
              if (tog('${key}_promo')) subGroup([
                if (iPOrd > 0) subRow("건당프로모션", "${_fmtC(iPOrd)} 원"),
                if (iRng  > 0) subRow("구간프로모션", "${_fmtC(iRng)} 원"),
              ]),
              togRow("세금합계", iTax, _pink, '${key}_tax'),
              if (tog('${key}_tax')) subGroup([
                subRow("고용보험", "${_fmtC(iETax)} 원", vc: _text2),
                subRow("산재보험", "${_fmtC(iATax)} 원", vc: _text2),
                subRow("원천세",   "${_fmtC(iITax)} 원", vc: _text2),
              ]),
              if (iFee > 0) togRow("수수료합계", iFee, _pink, '${key}_comm'),
              if (iFee > 0 && tog('${key}_comm')) subGroup([
                if (iWd   > 0) subRow("출금수수료",   "${_fmtC(iWd)} 원",   vc: _text2),
                if (iComm > 0) subRow("협력사수수료", "${_fmtC(iComm)} 원", vc: _text2),
              ]),
              if (iDedu > 0) togRow("공제합계", iDedu, _pink, '${key}_dedu'),
              if (iDedu > 0 && tog('${key}_dedu')) subGroup([
                if (iIns        > 0) subRow("시간제보험", "${_fmtC(iIns)} 원",        vc: _text2),
                if (leasePerDay > 0) subRow("리스비",     "${_fmtC(leasePerDay)} 원", vc: _text2),
              ]),
              Container(height: 1, color: _teal.withValues(alpha: 0.6), margin: const EdgeInsets.symmetric(vertical: 5)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("소계", style: TextStyle(color: _rhSubtotalColor, fontSize: _rhSubtotalLabelFontSize, fontWeight: FontWeight.w700)),
                  Text("${_fmtC(leasePerDay > 0 ? actualFinal : iFinal)} 원",
                      style: const TextStyle(color: _rhSubtotalColor, fontSize: _rhSubtotalValueFontSize, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  // 구형 메시지 파싱 뷰 (items 없는 기존 데이터용)
  Widget _oldMsgView(Map<String, dynamic> data) {
    final msg        = data['message']?.toString() ?? '';
    final deliveryFee  = _rx(msg, '배달수수료\\(세전\\)').abs();
    final tTax         = _rx(msg, '세금').abs();
    final eTax         = _rx(msg, '고용보험').abs();
    final aTax         = _rx(msg, '산재보험').abs();
    final iTax         = _rx(msg, '원천세').abs();
    final missionFee   = _rx(msg, '미션금액').abs();
    final perOrderAmt  = _rx(msg, '건당프로모션').abs();
    final rangeAmt     = _rx(msg, '구간프로모션').abs();
    final promoTotal   = missionFee + perOrderAmt + rangeAmt;
    final insuranceFee = _rx(msg, '시간제보험').abs();
    final withdrawFee  = _rx(msg, '출금수수료').abs();
    final leaseDailyAmt = _rx(msg, '리스비\\(일\\)').abs();
    final commAmt      = _rxComm(msg);
    final deductTotal  = insuranceFee + withdrawFee + leaseDailyAmt;
    final finalWd      = _rx(msg, '최종출금금액').abs();
    final docId        = data['_docId'] as String? ?? '';
    final taxExp       = _dateExp['${docId}_tax']   ?? false;
    final promoExp     = _dateExp['${docId}_promo'] ?? false;
    final deduExp      = _dateExp['${docId}_dedu']  ?? false;
    return Column(children: [
      _row("배달수수료 (세전)", "${_fmtC(deliveryFee)} 원"),
      _divider(),
      _toggle("지원금", "${_fmtC(promoTotal)} 원", _text2, promoExp,
          () => setState(() => _dateExp['${docId}_promo'] = !promoExp), [
        _sub("미션금",       "${_fmtC(missionFee)} 원"),
        _sub("건당프로모션", "${_fmtC(perOrderAmt)} 원"),
        _sub("구간프로모션", "${_fmtC(rangeAmt)} 원"),
      ]),
      _divider(),
      _toggle("세금", "${_fmtC(tTax)} 원", _pink, taxExp,
          () => setState(() => _dateExp['${docId}_tax'] = !taxExp), [
        _sub("고용보험", "${_fmtC(eTax)} 원"),
        _sub("산재보험", "${_fmtC(aTax)} 원"),
        _sub("원천세",   "${_fmtC(iTax)} 원"),
      ]),
      _divider(),
      _row("협력사수수료", "${_fmtC(commAmt)} 원", vc: _pink),
      _divider(),
      _toggle("공제", "${_fmtC(deductTotal)} 원", _pink, deduExp,
          () => setState(() => _dateExp['${docId}_dedu'] = !deduExp), [
        _sub("시간제보험", "${_fmtC(insuranceFee)} 원"),
        _sub("출금수수료", "${_fmtC(withdrawFee)} 원"),
        if (leaseDailyAmt > 0) _sub("리스비(일)", "${_fmtC(leaseDailyAmt)} 원"),
      ]),
      Container(height: 1, color: _teal.withValues(alpha: 0.6), margin: const EdgeInsets.symmetric(vertical: 8)),
      _row("최종출금금액", "${_fmtC(finalWd)} 원", lc: _teal, vc: _teal, bold: true, fs: 14),
    ]);
  }

  // ── 탭 2: 누적정산 ──────────────────────────────────────────────────

  Widget _cumulativeTab() {
    final totalTax   = _emp + _acc + _tax;
    final totalPromo = _mission + _perOrder + _range;
    final totalFee   = _wdFee + _comm;
    final totalDedu  = _ins + _lease;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(_rhCumOuterL, _rhCumOuterT, _rhCumOuterR, _rhCumOuterB),
      child: Container(
        padding: const EdgeInsets.fromLTRB(_rhCumPadL, _rhCumPadT, _rhCumPadR, _rhCumPadB),
        decoration: BoxDecoration(
          color: _surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _elevated, width: _rhCardBorderWidth),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 날짜 필터
          Row(children: [
            Flexible(child: _dateBtn(_start, "시작일",   (d) => setState(() => _start = d))),
            const Text(" ~ ", style: TextStyle(color: _text2, fontSize: 12)),
            Flexible(child: _dateBtn(_end,   "마지막일", (d) => setState(() => _end   = d))),
            const SizedBox(width: 6),
            _smallBtn("조회", () {
              setState(() { _startApplied = _start; _endApplied = _end; _cumLoaded = false; });
              _loadCumulative();
            }, filled: true),
            const SizedBox(width: 6),
            _smallBtn("초기화", () {
              if (_start == null && _end == null && _startApplied == null && _endApplied == null) return; // 기본 상태면 변화 없음
              setState(() { _start = _end = _startApplied = _endApplied = null; });
              _loadCumulative(); // 전체 다시 로드
            }),
          ]),
          Container(height: 1, color: _teal.withValues(alpha: 0.6), margin: const EdgeInsets.symmetric(vertical: 12)),
          if (!_cumLoaded)
            const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: _teal),
            ))
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("배달수수료 (세전)", style: TextStyle(color: _rhMainColor, fontSize: _rhMainFontSize, fontWeight: FontWeight.w500)),
                Text("${_fmtC(_gross)} 원", style: const TextStyle(color: _rhMainColor, fontSize: _rhMainFontSize)),
              ]),
            ),
            _toggle("지원금합계", "${_fmtC(totalPromo)} 원", _text, _promoExp,
                () => setState(() => _promoExp = !_promoExp), [
              if (_perOrder > 0) _subC("건당프로모션", "${_fmtC(_perOrder)} 원"),
              if (_range    > 0) _sub("구간프로모션", "${_fmtC(_range)} 원"),
            ]),
            _toggle("세금합계", "${_fmtC(totalTax)} 원", _pink, _taxExp,
                () => setState(() => _taxExp = !_taxExp), [
              _subC("고용보험", "${_fmtC(_emp)} 원", vc: _text2),
              _subC("산재보험", "${_fmtC(_acc)} 원", vc: _text2),
              _subC("원천세",   "${_fmtC(_tax)} 원", vc: _text2),
            ]),
            if (totalFee > 0) _toggle("수수료합계", "${_fmtC(totalFee)} 원", _pink, _commExp,
                () => setState(() => _commExp = !_commExp), [
              if (_wdFee > 0) _subC("출금수수료",   "${_fmtC(_wdFee)} 원", vc: _text2),
              if (_comm  > 0) _subC("협력사수수료", "${_fmtC(_comm)} 원",  vc: _text2),
            ]),
            if (totalDedu > 0) _toggle("공제합계", "${_fmtC(totalDedu)} 원", _pink, _deduExp,
                () => setState(() => _deduExp = !_deduExp), [
              if (_ins   > 0) _subC("시간제보험", "${_fmtC(_ins)} 원",   vc: _text2),
              if (_lease > 0) _subC("리스비",     "${_fmtC(_lease)} 원", vc: _text2),
            ]),
            Container(height: 1, color: _teal.withValues(alpha: 0.6), margin: const EdgeInsets.symmetric(vertical: 10)),
            _row("총 출금금액", "${_fmtC(_total)} 원",
                lc: _teal, vc: _teal, bold: true, fs: 14),
          ],
        ]),
      ),
    );
  }

  // ── 공통 위젯 ──────────────────────────────────────────────────

  Widget _divider() => Container(height: 1, color: _borderDim, margin: const EdgeInsets.symmetric(vertical: 5));

  Widget _row(String label, String value,
      {Color lc = _text2, Color vc = _text2, bool bold = false, double fs = 12}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: lc, fontSize: fs, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value, style: TextStyle(color: vc, fontSize: fs, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ]));

  Widget _sub(String label, String value) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: _rhSubColor, fontSize: _rhSubFontSize)),
          Text(value, style: const TextStyle(color: _rhSubColor, fontSize: _rhSubFontSize)),
        ]));

  Widget _subC(String label, String value, {Color lc = _rhSubColor, Color vc = _rhSubColor}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: lc, fontSize: _rhSubFontSize)),
          Text(value, style: TextStyle(color: vc, fontSize: _rhSubFontSize)),
        ]));

  Widget _toggle(String label, String value, Color vc,
      bool expanded, VoidCallback onTap, List<Widget> children) =>
      Column(children: [
        GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Text(label, style: const TextStyle(color: _rhTogLabelColor, fontSize: _rhTogFontSize, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.expand_less : Icons.expand_more,
                  color: _rhTogLabelColor, size: _rhTogIconSize),
              const Spacer(),
              Text(value, style: TextStyle(color: vc, fontSize: _rhTogFontSize)),
            ]))),
        if (expanded)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _elevated)),
            child: Column(children: children)),
      ]);

  Widget _dateBtn(DateTime? date, String hint, Function(DateTime) onPick) =>
      GestureDetector(
        onTap: () async {
          final p = await showDatePicker(context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2026), lastDate: DateTime(2030),
              builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _teal)),
                  child: child!));
          if (p != null) onPick(p);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(color: _rhDateBorderColor, width: 1),
              borderRadius: BorderRadius.circular(7)),
          child: Text(date != null ? DateFormat('MM-dd').format(date) : hint,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: date != null ? _rhDateSelColor : _rhDateHintColor, fontSize: _rhDateFontSize)),
        ),
      );

  Widget _smallBtn(String label, VoidCallback onTap, {bool filled = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 28, padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: filled ? _teal : Colors.transparent,
            border: Border.all(color: filled ? _teal : _elevated, width: 1),
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(
              color: filled ? _surface : _teal,
              fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      );
}

// === 1:1 상담 목록 페이지 =====================================================================

// ═══════════════════════ 10-2. 1:1 상담 (로직) ═══════════════════════
class _ChatListPage extends StatelessWidget {
  final bool embedded;
  const _ChatListPage({this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('lastAt', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: _teal));
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text("접수된 상담이 없습니다.", style: TextStyle(color: _csEmptyColor, fontSize: _csEmptyFontSize)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(_csListPadH, _csTabToCardGap, _csListPadH, _csListPadV),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: _csRowGap),
            itemBuilder: (ctx, i) {
              final d    = docs[i].data() as Map<String, dynamic>;
              final uid  = docs[i].id;
              final name = d['riderName'] as String? ?? uid;
              final last = d['lastMessage'] as String? ?? '';
              final at   = d['lastAt'] as Timestamp?;
              final unread = d['unreadByAdmin'] as bool? ?? false;

              return GestureDetector(
                onTap: () => Navigator.push(ctx,
                    MaterialPageRoute(builder: (_) => _AdminChatPage(uid: uid, riderName: name))),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: _csCardBg,
                    borderRadius: BorderRadius.circular(_csCardRadius),
                    border: Border.all(color: unread ? _csCardBorderUnread.withValues(alpha: 0.5) : _csCardBorder, width: unread ? 1 : 0.6),
                  ),
                  child: Row(children: [
                    Container(
                      width: _csAvatarSize, height: _csAvatarSize,
                      decoration: BoxDecoration(
                        color: _csAvatarBg, shape: BoxShape.circle,
                        border: Border.all(color: unread ? _csCardBorderUnread : _csCardBorder, width: unread ? 1 : 0.6),
                      ),
                      child: Icon(Icons.person_outline_rounded, color: unread ? _csAvatarIconUnread : _csAvatarIconColor, size: _csAvatarIconSize),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(name, style: TextStyle(
                              color: unread ? _csNameUnread : _csNameColor,
                              fontSize: _csNameFontSize, fontWeight: FontWeight.w700)),
                          if (unread) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: _csNewBg, borderRadius: BorderRadius.circular(8)),
                              child: const Text("NEW", style: TextStyle(color: _csNewText, fontSize: _csNewFontSize, fontWeight: FontWeight.w700)),
                            ),
                          ],
                          const Spacer(),
                          if (at != null)
                            Text(DateFormat('MM/dd HH:mm').format(at.toDate()),
                                style: const TextStyle(color: _csTimeColor, fontSize: _csTimeFontSize)),
                        ]),
                        const SizedBox(height: 3),
                        Text(last, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _csLastColor, fontSize: _csLastFontSize)),
                      ]),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, color: _csChevronColor, size: _csChevronSize),
                  ]),
                ),
              );
            },
          );
        },
      );
    return embedded ? body : _adminPanelScaffold(context, "1:1 상담", body);
  }
}

// === 관리자 채팅 페이지 ========================================================================

class _AdminChatPage extends StatefulWidget {
  final String uid;
  final String riderName;
  const _AdminChatPage({required this.uid, required this.riderName});
  @override
  State<_AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<_AdminChatPage> {
  final TextEditingController _ctrl       = TextEditingController();
  final ScrollController      _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // 열릴 때 관리자 읽음 처리
    FirebaseFirestore.instance.collection('chats').doc(widget.uid)
        .set({'unreadByAdmin': false}, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final chatRef = FirebaseFirestore.instance.collection('chats').doc(widget.uid);
      await chatRef.set({
        'lastMessage':  msg,
        'lastAt':       FieldValue.serverTimestamp(),
        'unreadByRider': true,
        'unreadByAdmin': false,
      }, SetOptions(merge: true));
      await chatRef.collection('messages').add({
        'sender': 'admin',
        'text':   msg,
        'at':     FieldValue.serverTimestamp(),
      });
      _ctrl.clear();
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  Widget _bubble(String text, bool isAdmin, Timestamp? at) {
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isAdmin ? _teal.withValues(alpha: 0.18) : _surface,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(12),
            topRight:    const Radius.circular(12),
            bottomLeft:  Radius.circular(isAdmin ? 12 : 2),
            bottomRight: Radius.circular(isAdmin ? 2 : 12),
          ),
          border: Border.all(
            color: isAdmin ? _teal.withValues(alpha: 0.4) : _borderDim, width: 0.8),
        ),
        child: Column(crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          Text(text, style: const TextStyle(color: _text, fontSize: 13, height: 1.4)),
          if (at != null) ...[
            const SizedBox(height: 3),
            Text(DateFormat('MM/dd HH:mm').format(at.toDate()),
                style: const TextStyle(color: _text2, fontSize: 9)),
          ],
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _adminPanelScaffold(
      context,
      "${widget.riderName} 님",
      Column(children: [
        // 메시지 목록
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats').doc(widget.uid)
                .collection('messages')
                .orderBy('at', descending: false)
                .snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: _teal));
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                  child: Text("아직 메시지가 없습니다.", style: TextStyle(color: _text2, fontSize: 13)),
                );
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollCtrl.hasClients) {
                  _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
                }
              });
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  return _bubble(d['text'] as String? ?? '', d['sender'] == 'admin', d['at'] as Timestamp?);
                },
              );
            },
          ),
        ),
        // 입력창
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: const BoxDecoration(
            color: _surface,
            border: Border(top: BorderSide(color: Color(0x22C9A84C))),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: 4, minLines: 1,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(color: _text, fontSize: 13),
                cursorColor: _teal,
                decoration: InputDecoration(
                  hintText: "답변 입력...",
                  hintStyle: const TextStyle(color: _text2, fontSize: 13),
                  filled: true, fillColor: _surface,
                  isDense: true, contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0x22C9A84C)),
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _teal),
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sending ? null : _send,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.18), shape: BoxShape.circle,
                  border: Border.all(color: _teal, width: 0.8),
                ),
                child: _sending
                    ? const Padding(padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(color: _teal, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: _teal, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
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

// === 전체 출금 랭킹 페이지 (더보기) ==========================================
// ═══════════════════════ 5-1. 더보기 (전체 랭킹 페이지, 로직) ═══════════════════════
class _FullRankingPage extends StatelessWidget {
  final String title;
  final List<MapEntry<String, double>> ranking;
  const _FullRankingPage({required this.title, required this.ranking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_panelOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(_panelRadius),
              border: Border.all(
                  color: _elevated.withValues(alpha: _panelBorderAlpha), width: 1),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_panelRadius),
              child: Column(children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 16, 0),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: _text, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(title,
                        style: const TextStyle(
                            color: _text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(height: _subGapHeaderToDiv),
                Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: _subDivMarginH),
                    color: _subDivColor),
                const SizedBox(height: _subGapDivToBody),
                Expanded(
                  child: ranking.isEmpty
                      ? const Center(
                          child: Text("지급 내역이 없습니다.",
                              style: TextStyle(
                                  color: _rankEmptyColor,
                                  fontSize: _rankEmptyFontSize)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                          itemCount: ranking.length,
                          itemBuilder: (_, i) {
                            final e = ranking[i];
                            final rank = i + 1;
                            final badgeColor = rank == 1
                                ? _rankGold
                                : rank == 2
                                    ? _rankSilver
                                    : rank == 3
                                        ? _rankBronze
                                        : _rankEtc;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(children: [
                                // 1·2·3등 = 금·은·동 메달 / 4등~ = 숫자
                                SizedBox(
                                  width: _rankBadgeSize,
                                  height: _rankBadgeSize,
                                  child: rank <= 3
                                      ? Icon(Icons.military_tech,
                                          color: badgeColor, size: _rankMedalSize)
                                      : Center(
                                          child: Text("$rank",
                                              style: TextStyle(
                                                  color: badgeColor,
                                                  fontSize: _rankBadgeFontSize,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(e.key,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: _rankNameColor,
                                          fontSize: _rankNameFontSize,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text:
                                          NumberFormat('#,###').format(e.value),
                                      style: const TextStyle(
                                          color: _rankAmtColor,
                                          fontSize: _rankAmtFontSize,
                                          fontWeight: FontWeight.w700)),
                                  const TextSpan(
                                      text: ' 원',
                                      style: TextStyle(
                                          color: _text,
                                          fontSize: _rankAmtUnitFontSize)),
                                ])),
                              ]),
                            );
                          },
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