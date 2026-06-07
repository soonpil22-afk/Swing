// 관리자 리스비 납기 현황 — 라이더별 리스비 진행/납기 알림 카드 목록
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'admin_common.dart';
import 'glass_shine_button.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _surface  = kSurface;
const _elevated = kElevated;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const _pink     = kPink;
const _amber    = kAmber;
const List<BoxShadow> _cardShadow = kCardShadow;

// ═══════════════ 리스비 납기 현황 카드 상수(_la*) ═══════════════
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
const _laCardBorder            = _elevated; // 전체현황 카드 테두리 색
const double _laCardBorderWidth = 1;    // 전체현황 카드 테두리 두께
const _laCardTitleColor        = _text; // "리스비 전체 현황" 색
const double _laCardTitleFontSize = 13; // "리스비 전체 현황" 크기
const double _laRowFontSize    = 12;    // 정보행(기간·진행·납부·잔여) 글씨 크기
const double _laRowValueFontSize = 16;  // 진행현황 강조 숫자 크기
const double _laChevronSize    = 18;    // 펼침 아이콘 크기

// ═══════════════ 리스비 납기 현황 페이지 (로직) ═══════════════
class LeaseAlertsPage extends StatefulWidget {
  final bool embedded;
  const LeaseAlertsPage({super.key, this.embedded = false});
  @override
  State<LeaseAlertsPage> createState() => _LeaseAlertsPageState();
}

class _LeaseAlertsPageState extends State<LeaseAlertsPage> {

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

              // 기본 _elevated, 강조(완납·납기·입금완료 신고) = _teal
              final borderColor =
                  (paidCount == totalCount || hasDue || hasRiderPaid)
                      ? _teal
                      : _elevated;

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
                            decoration: BoxDecoration(color: _amber.withAlpha(30), borderRadius: BorderRadius.circular(4), border: Border.all(color: _amber)),
                            child: const Text("매일", style: TextStyle(color: _amber, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                        const Spacer(),
                        if (hasRiderPaid) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: _teal.withAlpha(20), borderRadius: BorderRadius.circular(5), border: Border.all(color: _amber)),
                          child: const Text("입금완료!", style: TextStyle(color: _amber, fontSize: _laBadgeFontSize, fontWeight: FontWeight.w700)),
                        ) else if (isDueToday) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: _teal.withAlpha(20), borderRadius: BorderRadius.circular(5), border: Border.all(color: _teal)),
                          child: const Text("오늘 납부", style: TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w700)),
                        ) else if (hasDue) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: _teal.withAlpha(20), borderRadius: BorderRadius.circular(5), border: Border.all(color: _pink)),
                          child: const Text("납기초과", style: TextStyle(color: _pink, fontSize: _laBadgeFontSize, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 6),
                        Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: _text2, size: _laChevronSize),
                      ]),
                    ),
                  ),

                  // 펼침: 리스비전체현황 카드 + (매주/매월) 회차별 입금확인
                  if (isExpanded) ...[
                    Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(horizontal: 12)),
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
                            Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 10)),
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
                            label: "입금완료",
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
        : adminPanelScaffold(context, "리스비 납기 현황", body);
  }
}
