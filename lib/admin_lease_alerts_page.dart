// 관리자 공제 납부 현황 — 라이더별 리스비/기타 진행·납부 알림 카드 목록
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'admin_common.dart';
import 'glass_shine_button.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _surface  = kSurface;
const _elevated = kElevated;
const _chip     = kChip;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const _pink     = kPink;
const _amber    = kAmber;
const _purple   = kPurple;
const List<BoxShadow> _cardShadow = kCardShadow;

// ═══════════════ 리스비 납부 현황 카드 상수(_la*) ═══════════════
const double _laListPadL = 15;  // 목록 바깥 여백 왼
const double _laListPadT = 4;  // 위
const double _laListPadR = 15;  // 오른
const double _laListPadB = 15;  // 아래
const _laInfoLabelColor = _text;  // 정보 행 라벨 색
const _laInfoValueColor = _text;  // 정보 행 값 색(기본)
const double _laInfoFontSize = 12;// 정보 행 글씨 크기
// 리스비 카드 내용 (글씨·테두리)
const double _laRiderNameFontSize = 14; // 라이더 이름 칩 글씨 크기
const double _laBadgeFontSize  = 10;    // 상태·타입 뱃지 글씨 크기
const _laCardBorder            = _elevated; // 전체현황 카드 테두리 색
const double _laCardBorderWidth = 1;    // 전체현황 카드 테두리 두께
const _laCardTitleColor        = _text; // "리스비 전체 현황" 색
const double _laCardTitleFontSize = 13; // "리스비 전체 현황" 크기
const double _laRowFontSize    = 12;    // 정보행(기간·진행·납부·잔여) 글씨 크기
const double _laRowValueFontSize = 16;  // 진행현황 강조 숫자 크기
const double _laChevronSize    = 18;    // 펼침 아이콘 크기

// 공제 종류 설정값 (리스비 / 기타)
class _Kind {
  final String title;       // '리스비' / '기타'
  final String collection;  // 'lease_payments' / 'etc_payments'
  final String typeField;   // 'leaseType' / 'etcType'
  final String alertField;  // 'leaseNewAlert' / 'etcNewAlert'
  final IconData icon;
  final Color accent;       // 카드 제목 칩·아이콘 강조색
  const _Kind(this.title, this.collection, this.typeField, this.alertField, this.icon, this.accent);
}

const _kLease = _Kind('리스비', 'lease_payments', 'leaseType', 'leaseNewAlert', Icons.moped, _teal);
const _kEtc   = _Kind('기타',  'etc_payments',  'etcType',   'etcNewAlert',  Icons.account_balance_wallet, _purple);

// ═══════════════ 공제 납부 현황 페이지 (로직) ═══════════════
class LeaseAlertsPage extends StatefulWidget {
  final bool embedded;
  const LeaseAlertsPage({super.key, this.embedded = false});
  @override
  State<LeaseAlertsPage> createState() => _LeaseAlertsPageState();
}

class _LeaseAlertsPageState extends State<LeaseAlertsPage> {

  final Map<String, bool> _expanded = {};
  final Map<String, int>  _tab      = {}; // 기사별 리스비(0)/기타(1) 탭 선택

  // 기사별 미납 강조 기준일(anchor) = 그 기사의 업로드된 리포트 최신 날짜.
  // 대기중(요청대기)이거나 미출금 없음이면 '' → 강조 안 함. (오늘 기준 → 리포트 날짜 기준)
  final Map<String, String> _anchors = {};
  final Set<String> _anchorLoading = {};

  Future<void> _loadAnchors(Iterable<String> uids) async {
    final todo = uids
        .where((u) =>
            u.isNotEmpty && !_anchors.containsKey(u) && !_anchorLoading.contains(u))
        .toList();
    if (todo.isEmpty) return;
    _anchorLoading.addAll(todo);
    Set<String> pendingUids = {};
    try {
      final pend = await FirebaseFirestore.instance
          .collection('withdrawal_requests')
          .where('status', isEqualTo: '요청대기')
          .get();
      pendingUids =
          pend.docs.map((d) => (d.data()['uid'] as String?) ?? '').toSet();
    } catch (_) {}
    await Future.wait(todo.map((uid) async {
      if (pendingUids.contains(uid)) {
        _anchors[uid] = '';
        return;
      }
      try {
        final doc = await FirebaseFirestore.instance
            .collection('unpaid_balance').doc(uid).get();
        final items = (doc.data()?['items'] as List?) ?? [];
        var a = '';
        for (final it in items) {
          final d = (it as Map)['date'] as String? ?? '';
          if (d.compareTo(a) > 0) a = d;
        }
        _anchors[uid] = a;
      } catch (_) {
        _anchors[uid] = '';
      }
    }));
    if (mounted) setState(() {});
  }

  // 스트림은 한 번만 생성 (매 빌드마다 재구독 방지 → 무한로딩 차단)
  final Stream<QuerySnapshot> _leaseStream =
      FirebaseFirestore.instance.collection('lease_payments').snapshots();
  final Stream<QuerySnapshot> _etcStream =
      FirebaseFirestore.instance.collection('etc_payments').snapshots();

  Future<void> _confirm(_Kind k, String docId, String uid, String riderName, int cycle, int amount) async {
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
            Text("$riderName 님 ${k.title} $cycle회차",
                style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text("${NumberFormat('#,###').format(amount)}원",
                style: const TextStyle(color: _teal, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text("입금완료 확인 하셨나요!!",
                style: TextStyle(color: _text, fontSize: 13)),
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
    await FirebaseFirestore.instance.collection(k.collection).doc(docId).update({
      'isPaid': true, 'paidAt': FieldValue.serverTimestamp(), 'riderPaid': false,
    });
    // 기사 알림 플래그 초기화
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({k.alertField: false});
    } catch (_) {}
    if (mounted) _showDone("$riderName 님 ${k.title} $cycle회차\n${NumberFormat('#,###').format(amount)}원\n납부 확인 완료!");
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

  // 납부 도래(오늘 이하 미납) 여부
  bool _hasDue(List<Map<String, dynamic>> ps, String anchor) =>
      anchor.isNotEmpty &&
      ps.any((p) =>
          (p['dueDate'] as String? ?? '').compareTo(anchor) <= 0 && p['isPaid'] != true);
  bool _isDueToday(List<Map<String, dynamic>> ps, String anchor) =>
      anchor.isNotEmpty &&
      ps.any((p) => (p['dueDate'] as String? ?? '') == anchor && p['isPaid'] != true);
  bool _hasRiderPaid(List<Map<String, dynamic>> ps) =>
      ps.any((p) => p['riderPaid'] == true && p['isPaid'] != true);

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder<QuerySnapshot>(
      stream: _leaseStream,
      builder: (ctx, leaseSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: _etcStream,
          builder: (ctx2, etcSnap) {
            if (leaseSnap.hasError || etcSnap.hasError) {
              return const Center(child: Text("불러오기 오류. 다시 시도해주세요.", style: TextStyle(color: _text2, fontSize: 14)));
            }
            // 한쪽이라도 준비되면 렌더 (둘 다 대기 중일 때만 로딩)
            if (!leaseSnap.hasData && !etcSnap.hasData) {
              return const Center(child: CircularProgressIndicator(color: _teal));
            }

            // 라이더(uid)별 그룹핑 — 리스비/기타 각각
            final Map<String, List<Map<String, dynamic>>> leaseByUid = {};
            final Map<String, List<Map<String, dynamic>>> etcByUid = {};
            final Map<String, String> nameByUid = {};
            void collect(List<QueryDocumentSnapshot> docs, Map<String, List<Map<String, dynamic>>> into) {
              for (final doc in docs) {
                final d = doc.data() as Map<String, dynamic>;
                final uid = d['uid'] as String? ?? '';
                if (uid.isEmpty) continue;
                into.putIfAbsent(uid, () => []);
                into[uid]!.add({...d, '_docId': doc.id});
                nameByUid.putIfAbsent(uid, () => d['riderName'] as String? ?? '');
              }
            }
            collect(leaseSnap.data?.docs ?? [], leaseByUid);
            collect(etcSnap.data?.docs ?? [], etcByUid);

            if (nameByUid.isEmpty) {
              return const Center(child: Text("공제 납부 내역이 없습니다.", style: TextStyle(color: _text2, fontSize: 14)));
            }

            final uids = nameByUid.keys.toList()
              ..sort((a, b) => (nameByUid[a] ?? '').compareTo(nameByUid[b] ?? ''));
            _loadAnchors(uids); // 기사별 리포트 최신 날짜(anchor) 로드(멱등)

            return ListView(
              padding: const EdgeInsets.fromLTRB(_laListPadL, _laListPadT, _laListPadR, _laListPadB),
              children: uids.map((uid) {
                final riderName = nameByUid[uid] ?? '';
                final lease = leaseByUid[uid] ?? [];
                final etc   = etcByUid[uid] ?? [];
                final isExpanded = _expanded[uid] ?? false;
                final anchor = _anchors[uid] ?? '';

                // 헤더 칩 상태 = 리스비/기타 합산 (강조 기준 = 리포트 최신 날짜)
                // 큰 카드 테두리는 강조 안 함(리스비/기타 구분 위해) → 강조는 각 전체현황 카드로 이동
                final hasRiderPaid = _hasRiderPaid(lease) || _hasRiderPaid(etc);
                final isDueToday   = _isDueToday(lease, anchor) || _isDueToday(etc, anchor);
                final hasDue       = _hasDue(lease, anchor) || _hasDue(etc, anchor);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: _surface, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _elevated, width: 1),
                    boxShadow: _cardShadow,
                  ),
                  child: Column(children: [
                    // 라이더 헤더 (이름 누르면 펼치기)
                    GestureDetector(
                      onTap: () => setState(() => _expanded[uid] = !isExpanded),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(children: [
                          Text(riderName, style: const TextStyle(
                              color: _text,
                              fontSize: _laRiderNameFontSize, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          if (hasRiderPaid) Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(color: _teal.withAlpha(20), borderRadius: BorderRadius.circular(5), border: Border.all(color: _amber)),
                            child: const Text("입금완료!", style: TextStyle(color: _amber, fontSize: _laBadgeFontSize, fontWeight: FontWeight.w700)),
                          ) else if (isDueToday) Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(color: _teal.withAlpha(20), borderRadius: BorderRadius.circular(5), border: Border.all(color: _teal)),
                            child: const Text("납부일", style: TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w700)),
                          ) else if (hasDue) Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(color: _teal.withAlpha(20), borderRadius: BorderRadius.circular(5), border: Border.all(color: _pink)),
                            child: const Text("미납중", style: TextStyle(color: _pink, fontSize: _laBadgeFontSize, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 6),
                          Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isExpanded ? _text2 : _teal, size: _laChevronSize),
                        ]),
                      ),
                    ),

                    // 펼침: 리스비 | 기타 탭 → 선택한 종류의 전체현황 카드
                    if (isExpanded) ...[
                      Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(horizontal: 12)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: () {
                          final hasLease = lease.isNotEmpty;
                          final hasEtc   = etc.isNotEmpty;
                          var tab = _tab[uid] ?? (hasLease ? 0 : 1);
                          if (tab == 0 && !hasLease) tab = 1;
                          if (tab == 1 && !hasEtc) tab = 0;
                          return Column(children: [
                            if (hasLease && hasEtc) ...[
                              _kindTab(uid, tab),
                              const SizedBox(height: 10),
                            ],
                            if (tab == 0)
                              _summaryCard(_kLease, lease, uid, riderName, anchor)
                            else
                              _summaryCard(_kEtc, etc, uid, riderName, anchor),
                          ]);
                        }(),
                      ),
                    ],
                  ]),
                );
              }).toList(),
            );
          },
        );
      },
    );
    return widget.embedded
        ? body
        : adminPanelScaffold(context, "공제 납부 현황", body);
  }

  // ── 전체현황 카드 (리스비/기타 공용) — 버튼을 카드 안에 포함 ──
  // 리스비 | 기타 탭 토글 (규칙 D2 탭 스타일)
  Widget _kindTab(String uid, int current) {
    Widget seg(int idx, String label) {
      final on = current == idx;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab[uid] = idx),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: on ? _chip : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: on ? _elevated : Colors.transparent),
            ),
            child: Center(
                child: Text(label,
                    style: TextStyle(
                        color: on ? _teal : _text2,
                        fontSize: 13,
                        fontWeight: FontWeight.w700))),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: _surface, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        seg(0, '리스비'),
        const SizedBox(width: 3),
        seg(1, '기타'),
      ]),
    );
  }

  Widget _summaryCard(_Kind k, List<Map<String, dynamic>> raw, String uid, String riderName, String anchor) {
    final payments = [...raw]
      ..sort((a, b) => (a['cycle'] as int? ?? 0).compareTo(b['cycle'] as int? ?? 0));
    final paidCount  = payments.where((p) => p['isPaid'] == true).length;
    final totalCount = payments.length;
    final isDaily    = payments.any((p) => (p[k.typeField] as String?) == 'daily');
    final leaseAmt   = payments.first['amount']     as int? ?? 0;
    final totalCycle = payments.first['totalCycle'] as int? ?? 0;
    final dueDates   = payments
        .map((p) => p['dueDate'] as String? ?? '')
        .where((d) => d.isNotEmpty).toList()..sort();
    final startShort = dueDates.isNotEmpty
        ? (dueDates.first.length >= 10 ? dueDates.first.substring(5) : dueDates.first) : '';
    final endShort   = dueDates.isNotEmpty
        ? (dueDates.last.length  >= 10 ? dueDates.last.substring(5)  : dueDates.last)  : '';
    final typeLabel  = isDaily ? '매일' : ((payments.first[k.typeField] as String?) == 'weekly' ? '주1회' : '매월');
    final cycleLabel = isDaily ? '일' : '회차';
    final totalAmt   = leaseAmt * totalCycle;
    final paidAmt    = leaseAmt * paidCount;
    final progress   = totalCount > 0 ? paidCount / totalCount : 0.0;
    final riderPaidList = payments.where((p) =>
        p['riderPaid'] == true && p['isPaid'] != true).toList();
    final hasRiderPaid = riderPaidList.isNotEmpty;
    // 납기 도래(리포트 최신 날짜 이하) 미납 회차 존재 여부 — 기사 입금 신고 대기 표시용
    final hasDue = anchor.isNotEmpty &&
        payments.any((p) =>
            (p['dueDate'] as String? ?? '').compareTo(anchor) <= 0 && p['isPaid'] != true);
    // 이 종류(리스비/기타) 카드 테두리 강조 — 납부도래/기사신고/완납이면 민트
    final allPaidKind = totalCount > 0 && paidCount == totalCount;
    final emphasize = hasDue || hasRiderPaid;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: _surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: (emphasize || allPaidKind) ? _teal : _laCardBorder,
            width: emphasize ? 1.5 : _laCardBorderWidth),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(k.icon, color: k.accent, size: 16),
          const SizedBox(width: 6),
          Text("${k.title} 전체 현황", style: const TextStyle(color: _laCardTitleColor, fontSize: _laCardTitleFontSize, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFF18203A), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0x4D303854))),
            child: Text(typeLabel, style: TextStyle(color: k.accent, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
        Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 10)),
        _infoRow("1$cycleLabel 금액", "${NumberFormat('#,###').format(leaseAmt)} 원"),
        const SizedBox(height: 5),
        _infoRow("총 $cycleLabel", "$totalCycle $cycleLabel"),
        const SizedBox(height: 5),
        _infoRow("총 ${k.title}", "${NumberFormat('#,###').format(totalAmt)} 원"),
        const SizedBox(height: 5),
        Row(children: [
          const Text("기간", style: TextStyle(color: _text, fontSize: _laRowFontSize)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _teal),
            ),
            child: Text(startShort, style: const TextStyle(color: _teal, fontSize: _laRowFontSize, fontWeight: FontWeight.w600)),
          ),
          const Text("  ~  ", style: TextStyle(color: _text, fontSize: _laRowFontSize)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: (anchor.isNotEmpty && dueDates.isNotEmpty && dueDates.last.compareTo(anchor) < 0 && paidCount < totalCount)
                    ? _amber.withAlpha(120) : _teal.withAlpha(80),
              ),
            ),
            child: Text(endShort, style: TextStyle(
              color: (anchor.isNotEmpty && dueDates.isNotEmpty && dueDates.last.compareTo(anchor) < 0 && paidCount < totalCount)
                  ? _amber : _teal,
              fontSize: _laRowFontSize, fontWeight: FontWeight.w600,
            )),
          ),
        ]),
        if (isDaily) ...[
          const SizedBox(height: 5),
          _infoRow("납부 방식", "출금 시 자동 공제", vc: _pink, labelColor: _pink, labelFs: 13),
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

        // 주1회/매월 — 기사 신청 → 관리자 확인 흐름 (매일은 출금 자동공제라 버튼 없음)
        if (!isDaily) ...[
          if (hasRiderPaid) ...[
            const SizedBox(height: 12),
            Builder(builder: (_) {
              final p      = riderPaidList.first;
              final docId  = p['_docId'] as String? ?? '';
              final cycle  = p['cycle']  as int?    ?? 0;
              final amount = p['amount'] as int?    ?? 0;
              return Column(children: [
                // 메시지 박스 — 기사 입금완료 신고 알림
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _amber),
                  ),
                  child: Row(children: [
                    const Icon(Icons.notifications_active_rounded, color: _amber, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text("$riderName 님이 입금완료하였습니다!\n확인하시고 완료해주세요.",
                            style: const TextStyle(
                                color: _text, fontSize: 13, height: 1.5, fontWeight: FontWeight.w600))),
                  ]),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: GlassShineButton(
                    label: "입금완료",
                    onPressed: () => _confirm(k, docId, uid, riderName, cycle, amount),
                    accent: _teal,
                    height: 46,
                    radius: 22,
                    fontSize: 14,
                  ),
                ),
              ]);
            }),
          ] else if (hasDue) ...[
            // 기사 입금 신고 대기 — 비활성
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _elevated),
              ),
              alignment: Alignment.center,
              child: const Text("기사 입금 대기중",
                  style: TextStyle(color: _text2, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ]),
    );
  }
}
