// 기사 정산내역 조회 — 정산내역 카드 + 출금내역(시작일/기간) 탭 조회
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'driver_common.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg     = kAppBg;
const _panel     = kPanel;
const _surface   = kSurface;
const _chip      = kChip;
const _elevated  = kElevated;
const _text      = kText;
const _text2     = kText2;
const _teal      = kTeal;
const _purple    = kPurple;
const _amber     = kAmber;
const _pink      = kPink;
const Color _bgScaffold = _appBg;
const List<BoxShadow> _cardShadow  = kCardShadow;
const List<BoxShadow> _panelShadow = kPanelShadow;

// ═══════════════ 정산내역 페이지 상수(_hp* / _st* / _ht*) ═══════════════
const Color  _hpPanelColor       = _panel;     // 패널 배경색
const Color  _hpPanelBorderColor = _elevated;  // 패널 테두리 색
const double _hpPanelBorderAlpha = 1.0;        // 테두리 투명도 (1.0=솔리드)
const double _hpOuterPad         = 10;  // 패널 바깥 여백
const double _hpPanelRadius      = 24;  // 패널 모서리
const Color  _hpTabTrackColor    = _surface;   // 탭 전체 배경(트랙)
const Color  _hpTabIndicatorColor = _chip;     // 선택된 탭 배경
const Color  _hpTabIndicatorBorder = _elevated; // 선택탭 테두리
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
const double _hpGapHeaderToDiv = kGapInner;  // 뒤로가기 ↔ 경계선 갭
const double _hpGapDivToTab    = kGapSection;  // 경계선 ↔ 정산내역 탭 갭
const double _hpDivMarginH     = 15; // 경계선 좌우 여백(끝까지 안 붙음)

// ═══════════════════════════════════════════════════════════════════════
// 정산내역 카드 (리포트 업로드 내용) (조정값)
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
const Color  _stCardBorderOpen  = _elevated; // 펼친 상태 테두리
const Color  _stCardBorderClose = _elevated;  // 접힌 상태 테두리
const double _stCardRadius      = 12;  // 카드 모서리
const double _stCardGap         = kGapCard;   // 카드 사이 간격
const double _stCardHeadPadH    = 4;   // 카드 머리 좌우 여백
const double _stCardHeadPadV    = 12;  // 카드 머리 위아래 여백
const Color  _stDateChipBg      = _chip;   // 날짜 칩 배경
const Color  _stDateChipBorder  = _elevated; // 날짜 칩 테두리
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
const Color  _stDayChipBorder   = _elevated; // 일자 칩 테두리
const Color  _stDayChipText     = _teal;   // 일자 칩 글씨 색
const double _stDayChipFontSize = 11;      // 일자 칩 글씨 크기
const double _stRowFontSize     = 12;      // 행 라벨 글씨 크기
const double _stRowAmtFontSize  = 16;      // 행 금액 글씨 크기
const Color  _stRowLabelColor   = _text;   // 기본 라벨 색
const Color  _stRowPinkColor    = _pink;   // 세금/수수료/공제 라벨 색
const double _stToggleIconSize  = 15;      // 토글 화살표 크기
const Color  _stSubBoxBg        = _appBg;  // 하위 박스 배경
const Color  _stSubBoxBorder    = _elevated; // 하위 박스 테두리
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
// ── 추가. 미출금(23시 마감 경과) 상태 표시 ──
const Color  _stUnpaidColor   = _purple;  // "미출금" 배지/글씨 색 (퍼플)
const String _stUnpaidLabel   = '미출금';  // 미출금 상태 표시 문구
const int    _stCutoffHour    = 23;       // 출금 마감 시각(23시)

// ═══════════════════════════════════════════════════════════════════════
// 출금내역 탭 (시작일 카드 등) (조정값)
// ═══════════════════════════════════════════════════════════════════════
const Color  _htCardBg          = _surface;    // 카드 배경색
const Color  _htCardBorder      = _elevated; // 카드 테두리 색
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
const Color  _htBtnFilledText   = _teal;    // 조회(채움) 글씨 색
const Color  _htBtnLineBorder   = _pink; // 초기화(선) 테두리
const Color  _htBtnLineText     = _pink;     // 초기화(선) 글씨 색
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
const double _htToggleIconSize  = 15;     // 토글 화살표 크기
const Color  _htSubBoxBg        = _appBg;     // 하위 박스 배경
const Color  _htSubBoxBorder    = _elevated; // 하위 박스 테두리
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

// ═══════════════ 정산내역 조회 페이지 (로직) ═══════════════
class HistoryPage extends StatefulWidget {
  final String uid;
  const HistoryPage({super.key, required this.uid});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
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

  // ── 메인배경 + 탭 ──
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
                pageHeader(context, "정산 내역"),
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

  // ── 정산탭 전용 공통 함수 ──
  Widget _stAmt(double v, Color numColor,
      {double fs = 13, bool bold = false, Color? unitColor, double? unitFs}) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: fmtAbs(v),
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
              color: exp ? _text2 : _teal, size: _stToggleIconSize),
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

  // 추가. 미출금 항목이 23시 마감을 지났는지 판별
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
    final etcDedu   = (data['etcDeduction']   as num?)?.toDouble() ?? 0;
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
              statusBadge(status, stColor),
              const SizedBox(width: 8),
              _stAmt(amount, _stHeadAmtColor, fs: _stHeadAmtFontSize, bold: true),
            ]),
          ),
        ),
        if (exp) ...[
          Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(horizontal: 10)),
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
                final pmApplied = item['promoApplied'] == true;
                final pmDaily = (item['deliveryCount'] as num?)?.toInt() ?? 0;
                final pmWeekly = (item['promoCount'] as num?)?.toInt() ?? pmDaily;
                final pmCnt = pmApplied ? "당일$pmDaily·주간$pmWeekly건" : "$pmDaily건";
                final mission = (item['missionFee'] as num?)?.toDouble() ?? 0;
                final tax = (item['tax'] as num?)?.toDouble() ?? 0;
                final emp = (item['employmentTax'] as num?)?.toDouble() ?? 0;
                final acc = (item['accidentTax'] as num?)?.toDouble() ?? 0;
                final inc = (item['incomeTax'] as num?)?.toDouble() ?? 0;
                final wd = (item['withdrawalFee'] as num?)?.toDouble() ?? 0;
                final comm = (item['commissionAmt'] as num?)?.toDouble() ?? 0;
                final ins = (item['insuranceFee'] as num?)?.toDouble() ?? 0;
                final fee = wd + comm;
                final dailyLease = items.isNotEmpty ? leaseDedu / items.length : 0.0;
                final dailyEtc = items.isNotEmpty ? etcDedu / items.length : 0.0;
                final iDedu = ins + dailyLease + dailyEtc;

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
                        color: _elevated,
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
                        _stSubRow("미션금액", mission, _stSubRowColor),
                        _stSubRow("건당프로모션 ($pmCnt)", pOrd, _stSubRowColor),
                        _stSubRow("구간프로모션 ($pmCnt)", rng, _stSubRowColor),
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
                    _stToggleRow(deduK, "공제합계", iDedu, _stRowPinkColor),
                    if (_itemToggles[deduK] == true)
                      _stSubGroup([
                        _stSubRow("시간제보험", ins, _stSubRowColor),
                        _stSubRow("리스비", dailyLease, _stSubRowColor),
                        _stSubRow("기타", dailyEtc, _stSubRowColor),
                      ]),
                    const SizedBox(height: 6),
                    Container(height: 1, color: _elevated),
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

  // ── 출금탭 전용 공통 함수 ──
  Widget _htAmt(double v, Color numColor,
      {double fs = 13, bool bold = false, Color? unitColor, double? unitFs}) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: fmtAbs(v),
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
              color: exp ? _text2 : _teal, size: _htToggleIconSize),
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
                _htSubRow("시간제보험", _hIns, _htSubRowColor),
                _htSubRow("리스비", _hLease, _htSubRowColor),
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
          color: Colors.transparent,
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

