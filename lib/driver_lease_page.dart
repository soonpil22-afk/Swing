// 기사 공제 현황 페이지 — 리스비/기타 전체현황 카드 + 주1회/매월 입금완료 버튼
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'driver_common.dart';
import 'glass_shine_button.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg     = kAppBg;
const _panel     = kPanel;
const _surface   = kSurface;
const _chip      = kChip;
const _elevated  = kElevated;
const _text      = kText;
const _text2     = kText2;
const _teal      = kTeal;
const _amber     = kAmber;
const _pink      = kPink;
const _purple    = kPurple;
const _red       = kRed;
const Color _bgScaffold = _appBg;
const List<BoxShadow> _cardShadow  = kCardShadow;
const List<BoxShadow> _panelShadow = kPanelShadow;

// ═══════════════ 리스비 페이지 상수(_lp* / _ls*) ═══════════════
const Color  _lpPanelColor       = _panel;     // 패널 배경색
const Color  _lpPanelBorderColor = _elevated;  // 패널 테두리 색
const double _lpPanelBorderAlpha = 1.0;        // 테두리 투명도 (1.0=솔리드)
const double _lpOuterPad         = 10;  // 패널 바깥 여백
const double _lpPanelRadius      = 24;  // 패널 모서리
// ── 헤더 아래 경계선 갭 ──
const double _lpGapHeaderToDiv = kGapInner;  // 뒤로가기 ↔ 경계선 갭
const double _lpGapDivToCard   = kGapSection;  // 경계선 ↔ 리스비 전체현황 카드 갭
const double _lpDivMarginH     = 15; // 경계선 좌우 여백(끝까지 안 붙음)
const Color  _lpDueAmtColor     = _text;  // 금액 안내 글씨 색
const Color  _lpEmptyIconColor  = _text2;  // 아이콘 색
const double _lpEmptyIconSize   = 48;      // 아이콘 크기
const Color  _lpEmptyTitleColor = _text2;  // 제목 색
const double _lpEmptyTitleFontSize = 14;   // 제목 크기
const Color  _lpEmptySubColor   = _text2;  // 부제 색
const double _lpEmptySubFontSize = 12;     // 부제 크기
const Color  _lpDueBoxColor     = _teal; // 박스 강조색
const double _lpDueBoxBgAlpha   = 0.06;    // 배경 투명도
const double _lpDueBoxRadius    = 12;      // 박스 모서리
const double _lpDueBoxBorderWidth = 1;   // 테두리 두께
const double _lpDueIconSize     = 22;      // 아이콘 크기
const double _lpDueTitleFontSize = 13;     // 제목 글씨 크기
const double _lpDueAmtFontSize  = 12;      // 금액 안내 글씨 크기
const double _lpPayBtnHeight    = 46;      // 버튼 높이
const double _lpPayBtnRadius    = 22;      // 버튼 모서리
const double _lpPayBtnFontSize  = 14;      // 버튼 글씨 크기
const Color  _lpPaidBoxBg       = _chip;   // 박스 배경색
const Color  _lpPaidBorderColor = _teal;   // 테두리 색
const Color  _lpPaidTextColor   = _text2;  // 글씨 색
const double _lpPaidFontSize    = 12;      // 글씨 크기
const double _lpPaidRadius      = 22;      // 박스 모서리
const Color  _lpOverBoxColor    = _red;    // 박스 강조색
const double _lpOverBoxBgAlpha  = 0.06;    // 배경 투명도
const double _lpOverBoxRadius   = 12;      // 박스 모서리
const double _lpOverBoxBorderWidth = 1;  // 테두리 두께
const double _lpOverIconSize    = 22;      // 아이콘 크기
const double _lpOverTitleFontSize = 13;    // 제목 글씨 크기
const Color  _lpOverSubColor    = _text2;  // 부제 글씨 색
const double _lpOverSubFontSize = 12;      // 부제 글씨 크기

const Color  _lsCardBg          = _surface;   // 카드 배경색
const Color  _lsCardBorderNormal = _elevated; // 일반 테두리(기본)
const Color  _lsCardBorderAlert = _teal;      // 알림 시 테두리 색(강조)
const double _lsCardRadius      = 14;  // 카드 모서리
const double _lsCardPadL = 16;  // 안쪽 여백 왼
const double _lsCardPadT = 14;  // 안쪽 여백 위
const double _lsCardPadR = 16;  // 안쪽 여백 오른
const double _lsCardPadB = 16;  // 안쪽 여백 아래
const double _lsHeadIconSize    = 16;      // 아이콘 크기
const Color  _lsHeadTitleColor  = _text;   // "리스비 전체 현황" 글씨 색
const double _lsHeadTitleFontSize = 13;    // 제목 글씨 크기
const Color  _lsTypeChipBg      = _chip;   // 타입 칩 배경
const Color  _lsTypeChipBorder  = _elevated; // 타입 칩 테두리
const double _lsTypeChipFontSize = 11;     // 타입 칩 글씨 크기
const Color  _lsInfoLabelColor  = _text;   // 정보 라벨 색
const Color  _lsInfoValueColor  = _text;   // 정보 값 색
const Color  _lsInfoPinkColor   = _pink;  // "출금 시 자동공제" 값 색
const double _lsInfoFontSize    = 12;      // 정보 글씨 크기
const Color  _lsPayMethodLabelColor    = _pink; // "납부 방식" 라벨 글씨 색
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

// 공제 종류 (리스비 / 기타)
class _DKind {
  final String prefix;      // users 필드 prefix: lease / etc
  final String collection;  // 회차 컬렉션
  final String title;       // '리스비' / '기타'
  final IconData icon;
  final Color accent;       // 제목 아이콘·칩 강조색
  const _DKind(this.prefix, this.collection, this.title, this.icon, this.accent);
}

const _kLease = _DKind('lease', 'lease_payments', '리스비', Icons.moped, _teal);
const _kEtc   = _DKind('etc', 'etc_payments', '기타', Icons.account_balance_wallet, _purple);

// ═══════════════ 공제 현황 페이지 (로직) ═══════════════
class DriverLeasePage extends StatefulWidget {
  final String uid;
  const DriverLeasePage({super.key, required this.uid});
  @override
  State<DriverLeasePage> createState() => _DriverLeasePageState();
}

class _DriverLeasePageState extends State<DriverLeasePage> {
  // 입금완료 처리 중 상태 (컬렉션별)
  final Map<String, bool> _submitting = {};

  // 미납 강조 기준일 = 업로드된 리포트 최신 날짜(메인 카드 배지와 동일 기준).
  // 출금신청 대기중이면 비움(처리중) → 강조 안 함.
  String _anchor = '';

  // 스트림은 한 번만 생성 (재구독 방지)
  late final Stream<DocumentSnapshot> _userStream;
  late final Stream<QuerySnapshot> _leaseStream;
  late final Stream<QuerySnapshot> _etcStream;

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots();
    // orderBy 미사용 (복합 인덱스 불필요) → dueDate는 화면에서 정렬
    _leaseStream = FirebaseFirestore.instance
        .collection(_kLease.collection).where('uid', isEqualTo: widget.uid).snapshots();
    _etcStream = FirebaseFirestore.instance
        .collection(_kEtc.collection).where('uid', isEqualTo: widget.uid).snapshots();
    _markAsSeen();
    _loadAnchor();
  }

  // 미납 강조 기준일 로드 (driver_page와 동일: 대기중이면 빈값, 아니면 미출금 최신 리포트 날짜)
  Future<void> _loadAnchor() async {
    try {
      final pending = await FirebaseFirestore.instance
          .collection('withdrawal_requests')
          .where('uid', isEqualTo: widget.uid)
          .where('status', isEqualTo: '요청대기')
          .limit(1).get();
      var anchor = '';
      if (pending.docs.isEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('unpaid_balance').doc(widget.uid).get();
        final items = (doc.data()?['items'] as List?) ?? [];
        for (final it in items) {
          final d = (it as Map)['date'] as String? ?? '';
          if (d.compareTo(anchor) > 0) anchor = d;
        }
      }
      if (mounted) setState(() => _anchor = anchor);
    } catch (_) {}
  }

  Future<void> _markAsSeen() async {
    for (final coll in [_kLease.collection, _kEtc.collection]) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(coll)
            .where('uid', isEqualTo: widget.uid)
            .where('isPaid', isEqualTo: true)
            .where('seenByRider', isEqualTo: false)
            .get();
        if (snap.docs.isEmpty) continue;
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snap.docs) {
          batch.update(doc.reference, {'seenByRider': true});
        }
        await batch.commit();
      } catch (_) {}
    }
  }

  Future<void> _submitPaid(String collection) async {
    if (_submitting[collection] == true) return;
    setState(() => _submitting[collection] = true);
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final snap = await FirebaseFirestore.instance
          .collection(collection)
          .where('uid', isEqualTo: widget.uid)
          .where('dueDate', isEqualTo: today)
          .where('isPaid', isEqualTo: false)
          .get();
      if (snap.docs.isEmpty) {
        if (mounted) showInfoDialog(context, "오늘 납부 회차를 찾을 수 없습니다.");
        return;
      }
      await snap.docs.first.reference.update({'riderPaid': true});
      if (mounted) showInfoDialog(context, "입금완료 처리되었습니다!\n관리자가 확인 후 납부 처리합니다.");
    } catch (_) {
      if (mounted) showInfoDialog(context, "처리 실패. 다시 시도해주세요.");
    } finally {
      if (mounted) setState(() => _submitting[collection] = false);
    }
  }

  // ── 메인배경 ──
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
                pageHeader(context, "리스비 납부 현황"),
                const SizedBox(height: _lpGapHeaderToDiv),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: _lpDivMarginH),
                  color: _elevated,
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
      stream: _userStream,
      builder: (_, userSnap) {
        final userData = userSnap.data?.data() as Map<String, dynamic>?;
        return StreamBuilder<QuerySnapshot>(
          stream: _leaseStream,
          builder: (_, leaseSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: _etcStream,
              builder: (ctx, etcSnap) {
                if (userData == null && !leaseSnap.hasData && !etcSnap.hasData) {
                  return const Center(child: CircularProgressIndicator(color: _teal));
                }
                final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                final leaseDocs = leaseSnap.data?.docs ?? [];
                final etcDocs = etcSnap.data?.docs ?? [];

                final sections = <Widget>[
                  ..._kindSection(_kLease, leaseDocs, userData, today),
                  ..._kindSection(_kEtc, etcDocs, userData, today),
                ];

                if (sections.isEmpty) {
                  return const Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.moped, color: _lpEmptyIconColor, size: _lpEmptyIconSize),
                    SizedBox(height: 12),
                    Text("공제 납부 내역이 없습니다.",
                        style: TextStyle(
                            color: _lpEmptyTitleColor,
                            fontSize: _lpEmptyTitleFontSize,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Text("관리자에게 문의해 주세요.",
                        style: TextStyle(color: _lpEmptySubColor, fontSize: _lpEmptySubFontSize)),
                  ]));
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  children: sections,
                );
              },
            );
          },
        );
      },
    );
  }

  // 한 종류(리스비/기타)의 카드 + 납부초과 박스
  List<Widget> _kindSection(
      _DKind k, List<QueryDocumentSnapshot> rawDocs, Map<String, dynamic>? userData, String today) {
    if (rawDocs.isEmpty || userData == null) return [];
    final docs = [...rawDocs]
      ..sort((a, b) => ((a.data() as Map)['dueDate'] as String? ?? '')
          .compareTo((b.data() as Map)['dueDate'] as String? ?? ''));
    final isDaily = (userData['${k.prefix}Type'] as String?) == 'daily';
    final paid = docs.where((d) => (d.data() as Map)['isPaid'] == true).toList();
    final unpaid = docs.where((d) => (d.data() as Map)['isPaid'] != true).toList();
    final todayDue = unpaid.where((d) => (d.data() as Map)['dueDate'] == today).toList();
    final overdue = unpaid.where((d) =>
        ((d.data() as Map)['dueDate'] as String? ?? '').compareTo(today) < 0).toList();
    final riderAlreadyPaid = todayDue.any((d) => (d.data() as Map)['riderPaid'] == true);
    // 테두리 강조 = 미납 중 마감일이 "리포트 최신 날짜(anchor)" 이하인 게 있을 때.
    // (오늘 기준이면 익일 업로드 전 하루 먼저 강조됨 → 리포트 날짜 기준으로 맞춤)
    final hasAlert = _anchor.isNotEmpty &&
        unpaid.any((d) {
          final dd = (d.data() as Map)['dueDate'] as String? ?? '';
          return dd.isNotEmpty && dd.compareTo(_anchor) <= 0;
        });

    return [
      _summaryCard(k, userData, paid.length, docs.length,
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
              border: Border.all(color: _lpOverBoxColor, width: _lpOverBoxBorderWidth)),
          child: Row(children: [
            const Icon(Icons.warning_rounded, color: _lpOverBoxColor, size: _lpOverIconSize),
            const SizedBox(width: 10),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("${k.title} 납부 초과 ${overdue.length}건이 있습니다!",
                  style: const TextStyle(
                      color: _lpOverBoxColor,
                      fontSize: _lpOverTitleFontSize,
                      fontWeight: FontWeight.w700)),
              const Text("관리자에게 문의해 주세요.",
                  style: TextStyle(color: _lpOverSubColor, fontSize: _lpOverSubFontSize)),
            ])),
          ]),
        ),
    ];
  }

  // ── 전체현황 카드 (리스비/기타 공용) ──
  Widget _summaryCard(_DKind k, Map<String, dynamic> u, int paidCount, int totalCount,
      {bool hasAlert = false,
      bool hasTodayDue = false,
      bool riderAlreadyPaid = false}) {
    final leaseType = u['${k.prefix}Type'] as String? ?? '';
    final leaseAmt = u['${k.prefix}Amount'] as int? ?? 0;
    final leaseCycle = u['${k.prefix}Cycle'] as int? ?? 0;
    final startStr = u['${k.prefix}StartDate'] as String? ?? '';
    final endStr = u['${k.prefix}LastDate'] as String? ?? '';
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
              color: hasAlert ? _lsCardBorderAlert : _lsCardBorderNormal,
              width: 1),
          boxShadow: _cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(k.icon, color: k.accent, size: _lsHeadIconSize),
          const SizedBox(width: 6),
          Text("${k.title} 전체 현황",
              style: const TextStyle(
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
                style: TextStyle(
                    color: k.accent,
                    fontSize: _lsTypeChipFontSize,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
        Container(
            height: 1,
            color: _elevated,
            margin: const EdgeInsets.symmetric(vertical: 10)),
        _infoRow2("1$cycleLabel 금액", "${NumberFormat('#,###').format(leaseAmt)} 원"),
        const SizedBox(height: 5),
        _infoRow2("총 $cycleLabel", "$leaseCycle $cycleLabel"),
        const SizedBox(height: 5),
        _infoRow2("총 ${k.title}", "${NumberFormat('#,###').format(totalAmt)} 원"),
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
        // 주1회/매월 납부일: 안내 + 입금완료 버튼 / 관리자 확인 대기중 (카드 안에 표시)
        if (!isDaily && hasTodayDue) ...[
          const SizedBox(height: 14),
          if (!riderAlreadyPaid) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: _lpDueBoxColor.withValues(alpha: _lpDueBoxBgAlpha),
                  borderRadius: BorderRadius.circular(_lpDueBoxRadius),
                  border: Border.all(
                      color: _lpDueBoxColor,
                      width: _lpDueBoxBorderWidth)),
              child: Row(children: [
                const Icon(Icons.notifications_active_rounded,
                    color: _pink, size: _lpDueIconSize),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("오늘 ${k.title} 납부일입니다!",
                      style: const TextStyle(
                          color: _text,
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
                onPressed: _submitting[k.collection] == true ? null : () => _submitPaid(k.collection),
                loading: _submitting[k.collection] == true,
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
                    color: _lpPaidBorderColor),
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
