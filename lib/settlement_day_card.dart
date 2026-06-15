// 정산 날짜별 상세 블록 — 기사·관리자(정산내역·출금신청) 공용 단일 출처 (기사 디자인 기준)
// 날짜칩 + 상태배지 + 배달수수료 + 지원금/세금/수수료/공제 토글 + 소계. 토글 펼침은 자체 관리.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';

final _nf = NumberFormat('#,###');
String _fmtAbs(double v) => _nf.format(v.abs());

class SettlementDayCard extends StatefulWidget {
  final String dateShort;                 // 날짜 칩 (MM-dd)
  final String? statusLabel;              // 상태 배지 글씨 (null이면 배지 없음)
  final Color statusColor;                // 상태 배지 색
  final double del;                       // 배달수수료(세전)
  final double promoTotal;                // 지원금합계
  final double mission, perOrder, range;  // 지원금 하위 (미션·건당·구간)
  final String pmCnt;                     // 프로모 건수 라벨 (예: "당일3·주간7건")
  final double tax;                       // 세금합계
  final double emp, acc, incomeTax;       // 세금 하위 (고용·산재·원천세)
  final double wdFee, comm;               // 수수료합계 = wdFee + comm
  final double ins, lease, etc;           // 공제합계 = ins + lease + etc
  final double subtotal;                  // 소계 (각 페이지가 계산해 전달)
  final bool signed;                      // 소계 부호 표시 (음수 가능 시 true)
  final bool showTopDivider;              // 날짜 사이 구분선 (둘째 날부터 true)

  const SettlementDayCard({
    super.key,
    required this.dateShort,
    this.statusLabel,
    this.statusColor = kTeal,
    required this.del,
    required this.promoTotal,
    required this.mission,
    required this.perOrder,
    required this.range,
    required this.pmCnt,
    required this.tax,
    required this.emp,
    required this.acc,
    required this.incomeTax,
    required this.wdFee,
    required this.comm,
    required this.ins,
    required this.lease,
    required this.etc,
    required this.subtotal,
    this.signed = false,
    this.showTopDivider = false,
  });

  @override
  State<SettlementDayCard> createState() => _SettlementDayCardState();
}

class _SettlementDayCardState extends State<SettlementDayCard> {
  // 토글 펼침 상태 (지원금·세금·수수료·공제)
  bool _promo = false, _tax = false, _comm = false, _dedu = false;

  // 크기 (카드 패턴: 행 14 / 하위 12 / 소계 16 / 날짜칩 14 / 배지 13)
  static const double _chipFs = 14, _rowFs = 14, _subFs = 12, _totalFs = 16, _badgeFs = 13;

  // 금액 (숫자 강조색 + " 원")
  Widget _amt(double v, Color numColor,
          {double fs = 14, Color? unitColor, double? unitFs, bool signed = false}) =>
      Text.rich(TextSpan(children: [
        TextSpan(
            text: (signed && v < 0 ? '-' : '') + _fmtAbs(v),
            style: TextStyle(color: numColor, fontSize: fs)),
        TextSpan(
            text: ' 원',
            style: TextStyle(color: unitColor ?? kText, fontSize: unitFs ?? fs)),
      ]));

  // 일반 행 (배달수수료 등)
  Widget _detailRow(String label, double v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: kText, fontSize: _rowFs)),
          _amt(v, kText, fs: _rowFs),
        ]),
      );

  // 토글 행 (지원금/세금/수수료/공제 합계)
  Widget _toggleRow(String label, double v, Color valueColor, bool exp, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Text(label, style: const TextStyle(color: kText, fontSize: _rowFs)),
            const SizedBox(width: 4),
            Icon(exp ? Icons.expand_less : Icons.expand_more,
                color: exp ? kText2 : kTeal, size: 15),
            const Spacer(),
            _amt(v, valueColor, fs: _rowFs),
          ]),
        ),
      );

  // 펼친 하위 박스
  Widget _subGroup(List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
            color: kAppBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kElevated)),
        child: Column(children: children),
      );

  // 하위 행
  Widget _subRow(String label, double v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: kText2, fontSize: _subFs)),
          _amt(v, kText2, unitColor: kText2, fs: _subFs, unitFs: _subFs),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (w.showTopDivider)
        Container(height: 1, color: kElevated, margin: const EdgeInsets.symmetric(vertical: 10)),
      // 날짜 칩 + 상태 배지
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: kElevated)),
            child: Text(w.dateShort, style: const TextStyle(color: kTeal, fontSize: _chipFs)),
          ),
          const Spacer(),
          if (w.statusLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: w.statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: w.statusColor),
              ),
              child: Text(w.statusLabel!,
                  style: TextStyle(color: w.statusColor, fontSize: _badgeFs)),
            ),
        ]),
      ),
      _detailRow("배달수수료 (세전)", w.del),
      const SizedBox(height: 2),
      _toggleRow("지원금합계", w.promoTotal, kText, _promo,
          () => setState(() => _promo = !_promo)),
      if (_promo)
        _subGroup([
          _subRow("미션금액", w.mission),
          _subRow("건당프로모션 (${w.pmCnt})", w.perOrder),
          _subRow("구간프로모션 (${w.pmCnt})", w.range),
        ]),
      _toggleRow("세금합계", w.tax, kPink, _tax, () => setState(() => _tax = !_tax)),
      if (_tax)
        _subGroup([
          _subRow("고용보험", w.emp),
          _subRow("산재보험", w.acc),
          _subRow("원천세", w.incomeTax),
        ]),
      _toggleRow("수수료합계", w.wdFee + w.comm, kPink, _comm,
          () => setState(() => _comm = !_comm)),
      if (_comm)
        _subGroup([
          _subRow("출금수수료", w.wdFee),
          _subRow("협력사수수료", w.comm),
        ]),
      _toggleRow("공제합계", w.ins + w.lease + w.etc, kPink, _dedu,
          () => setState(() => _dedu = !_dedu)),
      if (_dedu)
        _subGroup([
          _subRow("시간제보험", w.ins),
          _subRow("리스비", w.lease),
          _subRow("기타", w.etc),
        ]),
      const SizedBox(height: 6),
      Container(height: 1, color: kElevated),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("소계", style: TextStyle(color: kTeal, fontSize: _totalFs)),
        _amt(w.subtotal, kTeal,
            fs: _totalFs, unitColor: kTeal, unitFs: _totalFs, signed: w.signed),
      ]),
    ]);
  }
}
