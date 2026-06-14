// 관리자 공제 납부 현황 — 라이더별 리스비/기타 진행·납부 알림 카드 목록
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'admin_common.dart';
import 'glass_shine_button.dart';
import 'lease_status.dart';
import 'lease_summary_card.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
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
// 리스비 카드 내용 (글씨·테두리)
const double _laRiderNameFontSize = 14; // 라이더 이름 칩 글씨 크기
const double _laBadgeFontSize  = 10;    // 상태·타입 뱃지 글씨 크기
const _laCardBorder            = _elevated; // 전체현황 카드 테두리 색
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
    _anchors.addAll(await loadLeaseAnchors(todo));
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
                style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text("${NumberFormat('#,###').format(amount)}원",
                style: const TextStyle(color: _teal, fontSize: 17, fontWeight: FontWeight.w400)),
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
          Text(msg, style: const TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
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


  // 종류별 상태: 'paid'(기사 입금신고) | 'overdue'(미납부) | 'today'(납부일) | null
  // 매일=리포트 최신 날짜(anchor) / 주1회·매월=실제 오늘 날짜 기준
  String? _statusOf(List<Map<String, dynamic>> ps, String typeField, String anchor) =>
      leaseStatusOf(ps, typeField, anchor);

  // 종류별 상태 칩 (리스비 미납부 / 기타 납부일 등)
  Widget _statusChip(String title, String? status) {
    if (status == null) return const SizedBox.shrink();
    String label;
    Color color;
    if (status == 'paid') {
      label = '$title 입금완료';
      color = _amber;
    } else if (status == 'today') {
      label = '$title 납부일';
      color = _teal;
    } else {
      label = '$title 미납부';
      color = _pink;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: _teal.withAlpha(20),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: _laBadgeFontSize, fontWeight: FontWeight.w400)),
    );
  }

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

                // 헤더 칩 = 리스비/기타 따로 (매일=anchor / 주1회·매월=오늘)
                final leaseStatus = _statusOf(lease, 'leaseType', anchor);
                final etcStatus   = _statusOf(etc, 'etcType', anchor);

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
                              fontSize: _laRiderNameFontSize, fontWeight: FontWeight.w400)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.end,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (leaseStatus != null) _statusChip('리스비', leaseStatus),
                                if (etcStatus != null) _statusChip('기타', etcStatus),
                              ],
                            ),
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
                        fontSize: 14,
                        fontWeight: on ? FontWeight.w400 : FontWeight.w400))),
          ),
        ),
      );
    }

    // 트랙을 카드(_surface)보다 어둡게(_appBg) + 테두리 → 위 허브 탭처럼 또렷하게
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: _appBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _elevated, width: 1)),
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
    final riderPaidList = payments.where((p) =>
        p['riderPaid'] == true && p['isPaid'] != true).toList();
    final hasRiderPaid = riderPaidList.isNotEmpty;
    // 이 종류(리스비/기타) 카드 테두리 — 미납부=핑크 / 납부일·입금신고=민트
    final status = _statusOf(payments, k.typeField, anchor);
    final allPaidKind = totalCount > 0 && paidCount == totalCount;
    Color borderCol = _laCardBorder;
    if (status == 'overdue') {
      borderCol = _pink;
    } else if (status == 'today' || status == 'paid') {
      borderCol = _teal;
    } else if (allPaidKind) {
      borderCol = _teal;
    }

    return LeaseSummaryCard(
      title: k.title,
      icon: k.icon,
      accent: k.accent,
      typeLabel: typeLabel,
      cycleLabel: cycleLabel,
      isDaily: isDaily,
      unitAmt: leaseAmt,
      cycle: totalCycle,
      totalAmt: totalAmt,
      startShort: startShort,
      endShort: endShort,
      paidCount: paidCount,
      totalCount: totalCount,
      paidAmt: paidAmt,
      borderColor: borderCol,
      extra: [

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
                                color: _text, fontSize: 13, height: 1.5, fontWeight: FontWeight.w400))),
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
          ] else if (status == 'overdue' || status == 'today') ...[
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
                  style: TextStyle(color: _text2, fontSize: 14, fontWeight: FontWeight.w400)),
            ),
          ],
        ],
      ],
    );
  }
}
