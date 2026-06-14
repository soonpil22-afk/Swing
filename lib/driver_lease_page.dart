// 기사 공제 현황 페이지 — 리스비/기타 전체현황 카드 + 주1회/매월 입금완료 버튼
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'driver_common.dart';
import 'glass_shine_button.dart';
import 'lease_summary_card.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg     = kAppBg;
const _panel     = kPanel;
const _surface   = kSurface;
const _chip      = kChip;
const _elevated  = kElevated;
const _text      = kText;
const _text2     = kText2;
const _teal      = kTeal;
const _pink      = kPink;
const _purple    = kPurple;
const Color _bgScaffold = _appBg;
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
const Color  _lpEmptyIconColor  = _text2;  // 아이콘 색
const double _lpEmptyIconSize   = 48;      // 아이콘 크기
const Color  _lpEmptyTitleColor = _text2;  // 제목 색
const double _lpEmptyTitleFontSize = 14;   // 제목 크기
const double _lpPayBtnHeight    = 46;      // 버튼 높이
const double _lpPayBtnRadius    = 22;      // 버튼 모서리
const double _lpPayBtnFontSize  = 14;      // 버튼 글씨 크기
const Color  _lpPaidBoxBg       = _chip;   // 박스 배경색
const Color  _lpPaidBorderColor = _teal;   // 테두리 색
const double _lpPaidFontSize    = 12;      // 글씨 크기
const double _lpPaidRadius      = 22;      // 박스 모서리
const double _lpOverBoxBgAlpha  = 0.06;    // 배경 투명도
const double _lpOverBoxRadius   = 12;      // 박스 모서리
const double _lpOverBoxBorderWidth = 1;  // 테두리 두께
const double _lpOverIconSize    = 22;      // 아이콘 크기
const double _lpOverTitleFontSize = 13;    // 제목 글씨 크기
const Color  _lpOverSubColor    = _text;  // 부제 글씨 색
const double _lpOverSubFontSize = 12;      // 부제 글씨 크기


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

class _DriverLeasePageState extends State<DriverLeasePage>
    with SingleTickerProviderStateMixin {
  // 입금완료 처리 중 상태 (컬렉션별)
  final Map<String, bool> _submitting = {};

  late final TabController _tabCtrl = TabController(length: 2, vsync: this);

  // 미납 강조 기준일 = 업로드된 리포트 최신 날짜(메인 카드 배지와 동일 기준).
  // 출금신청 대기중이면 비움(처리중) → 강조 안 함. (매일 타입에만 사용)
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

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
      final snap = await FirebaseFirestore.instance
          .collection(collection)
          .where('uid', isEqualTo: widget.uid)
          .where('isPaid', isEqualTo: false)
          .get();
      // 주1회/매월 수동 입금신고 = 오늘(실제 날짜) 이하 마감 미납 회차 일괄 처리
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final due = snap.docs.where((d) {
        final dd = (d.data() as Map)['dueDate'] as String? ?? '';
        return dd.isNotEmpty && dd.compareTo(today) <= 0;
      }).toList();
      if (due.isEmpty) {
        if (mounted) showInfoDialog(context, "납부할 회차를 찾을 수 없습니다.");
        return;
      }
      final batch = FirebaseFirestore.instance.batch();
      for (final d in due) {
        batch.update(d.reference, {'riderPaid': true});
      }
      await batch.commit();
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
                final leaseDocs = leaseSnap.data?.docs ?? [];
                final etcDocs = etcSnap.data?.docs ?? [];
                final hasLease = userData != null && leaseDocs.isNotEmpty;
                final hasEtc   = userData != null && etcDocs.isNotEmpty;

                ListView kindList(_DKind k, List<QueryDocumentSnapshot> docs) => ListView(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      children: _kindSection(k, docs, userData),
                    );
                // 데이터 있으면 카드, 없으면 "내역 없음" (탭은 항상 유지)
                Widget kindTabView(bool has, _DKind k, List<QueryDocumentSnapshot> docs) =>
                    has ? kindList(k, docs) : _kindEmpty(k.title);

                // 탭(리스비|기타)은 항상 표시, 카드만 데이터 유무로 표시 (정산내역과 동일 TabBar)
                return Column(children: [
                  _kindTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        kindTabView(hasLease, _kLease, leaseDocs),
                        kindTabView(hasEtc, _kEtc, etcDocs),
                      ],
                    ),
                  ),
                ]);
              },
            );
          },
        );
      },
    );
  }

  // 종류별 빈 상태 (해당 탭에 데이터 없을 때)
  Widget _kindEmpty(String title) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.moped, color: _lpEmptyIconColor, size: _lpEmptyIconSize),
          const SizedBox(height: 12),
          Text("$title 납부 내역이 없습니다.",
              style: const TextStyle(
                  color: _lpEmptyTitleColor,
                  fontSize: _lpEmptyTitleFontSize,
                  fontWeight: FontWeight.w400)),
        ]),
      );

  // 리스비 | 기타 탭 — 정산내역 페이지 탭과 동일(TabBar)
  Widget _kindTabBar() => Container(
        margin: const EdgeInsets.fromLTRB(12, 2, 12, 8),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: _surface, borderRadius: BorderRadius.circular(10)),
        child: TabBar(
          controller: _tabCtrl,
          indicator: BoxDecoration(
              color: _chip,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: _elevated, width: 1)),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: _teal,
          unselectedLabelColor: _text2,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
          tabs: const [Tab(text: '리스비'), Tab(text: '기타')],
        ),
      );

  // 한 종류(리스비/기타)의 전체현황 카드. 미납(도래) 안내·입금완료 버튼은 카드 안에 표시.
  List<Widget> _kindSection(
      _DKind k, List<QueryDocumentSnapshot> rawDocs, Map<String, dynamic>? userData) {
    if (rawDocs.isEmpty || userData == null) return [];
    final docs = [...rawDocs]
      ..sort((a, b) => ((a.data() as Map)['dueDate'] as String? ?? '')
          .compareTo((b.data() as Map)['dueDate'] as String? ?? ''));
    final isDaily = (userData['${k.prefix}Type'] as String?) == 'daily';
    final paid = docs.where((d) => (d.data() as Map)['isPaid'] == true).toList();
    final unpaid = docs.where((d) => (d.data() as Map)['isPaid'] != true).toList();
    String dd(QueryDocumentSnapshot d) => (d.data() as Map)['dueDate'] as String? ?? '';

    int overdueCount = 0, todayCount = 0;
    bool hasAlert = false, riderAlreadyPaid = false;

    if (isDaily) {
      // 매일 = 정산(리포트)에 묶여 자동처리 → 리포트 최신 날짜(anchor) 기준 (테두리 강조만)
      hasAlert = _anchor.isNotEmpty &&
          unpaid.any((d) => dd(d).isNotEmpty && dd(d).compareTo(_anchor) <= 0);
    } else {
      // 주1회/매월 = 기사·관리자 수동처리 → 실제 오늘 날짜 기준
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final overdue = unpaid.where((d) => dd(d).isNotEmpty && dd(d).compareTo(today) < 0).toList();
      final todayDue = unpaid.where((d) => dd(d) == today).toList();
      overdueCount = overdue.length;
      todayCount = todayDue.length;
      hasAlert = overdueCount > 0 || todayCount > 0;
      riderAlreadyPaid =
          [...overdue, ...todayDue].any((d) => (d.data() as Map)['riderPaid'] == true);
    }

    return [
      _summaryCard(k, userData, paid.length, docs.length,
          hasAlert: hasAlert,
          overdueCount: overdueCount,
          todayCount: todayCount,
          riderAlreadyPaid: riderAlreadyPaid),
    ];
  }

  // 미납부(핑크)/오늘 납부일(민트) 안내 박스 — _lpOver* 사이즈 재사용
  Widget _noticeBox(Color c, IconData icon, String title, String sub) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: c.withValues(alpha: _lpOverBoxBgAlpha),
            borderRadius: BorderRadius.circular(_lpOverBoxRadius),
            border: Border.all(color: c, width: _lpOverBoxBorderWidth)),
        child: Row(children: [
          Icon(icon, color: c, size: _lpOverIconSize),
          const SizedBox(width: 10),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    color: c,
                    fontSize: _lpOverTitleFontSize,
                    fontWeight: FontWeight.w400)),
            Text(sub,
                style: const TextStyle(
                    color: _lpOverSubColor, fontSize: _lpOverSubFontSize)),
          ])),
        ]),
      );

  // ── 전체현황 카드 (리스비/기타 공용) ──
  Widget _summaryCard(_DKind k, Map<String, dynamic> u, int paidCount, int totalCount,
      {bool hasAlert = false,
      int overdueCount = 0,
      int todayCount = 0,
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
    final startShort = startStr.length >= 10 ? startStr.substring(5) : startStr;
    final endShort = endStr.length >= 10 ? endStr.substring(5) : endStr;

    return LeaseSummaryCard(
      title: k.title,
      icon: k.icon,
      accent: k.accent,
      typeLabel: typeLabel,
      cycleLabel: cycleLabel,
      isDaily: isDaily,
      unitAmt: leaseAmt,
      cycle: leaseCycle,
      totalAmt: totalAmt,
      startShort: startShort,
      endShort: endShort,
      paidCount: paidCount,
      totalCount: totalCount,
      paidAmt: paidAmt,
      borderColor: hasAlert ? _teal : _elevated,
      extra: [
        // 주1회/매월: 미납부(지난 회차, 핑크) / 오늘 납부일(민트) + 입금완료 버튼 (카드 안에 표시)
        if (!isDaily && (overdueCount > 0 || todayCount > 0)) ...[
          const SizedBox(height: 14),
          if (!riderAlreadyPaid) ...[
            if (overdueCount > 0)
              _noticeBox(_pink, Icons.warning_rounded,
                  "${k.title} 미납부 $overdueCount건입니다!",
                  "${NumberFormat('#,###').format(leaseAmt * overdueCount)}원 납부 부탁드립니다."),
            if (overdueCount > 0 && todayCount > 0) const SizedBox(height: 8),
            if (todayCount > 0)
              _noticeBox(_teal, Icons.notifications_active_rounded,
                  "오늘 ${k.title} 납부일입니다!",
                  "${NumberFormat('#,###').format(leaseAmt * todayCount)}원 납부 부탁드립니다."),
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
                          color: _text,
                          fontSize: _lpPaidFontSize,
                          fontWeight: FontWeight.w400))),
            ),
        ],
      ],
    );
  }

}
