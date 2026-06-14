// 출금내역/누적정산 "기간별 합계" 카드 — 기사·관리자 공용 단일 출처 (기사 디자인 기준)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _surface  = kSurface;
const _elevated = kElevated;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const _pink     = kPink;
const List<BoxShadow> _cardShadow = kCardShadow;

final _nf = NumberFormat('#,###');

class WithdrawalBreakdownCard extends StatefulWidget {
  // 날짜 헤더
  final DateTime? startDate, endDate;
  final ValueChanged<DateTime> onPickStart, onPickEnd;
  final VoidCallback onSearch, onReset;
  // 상태
  final bool loading; // 조회 중 → 스피너
  final bool loaded;  // false면 "조회 버튼을 눌러주세요"
  // 금액값
  final double gross;                    // 배달수수료(세전)
  final double mission, perOrder, range; // 지원금합계
  final double emp, acc, incomeTax;      // 세금합계
  final double wdFee, comm;              // 수수료합계
  final double ins, lease, etc;          // 공제합계
  final double total;                    // 총 출금금액

  const WithdrawalBreakdownCard({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onSearch,
    required this.onReset,
    required this.loading,
    required this.loaded,
    required this.gross,
    required this.mission,
    required this.perOrder,
    required this.range,
    required this.emp,
    required this.acc,
    required this.incomeTax,
    required this.wdFee,
    required this.comm,
    required this.ins,
    required this.lease,
    required this.etc,
    required this.total,
  });

  @override
  State<WithdrawalBreakdownCard> createState() =>
      _WithdrawalBreakdownCardState();
}

class _WithdrawalBreakdownCardState extends State<WithdrawalBreakdownCard> {
  bool _promo = false, _tax = false, _comm = false, _dedu = false;

  // 금액(숫자 강조색 + " 원")
  Widget _amt(double v, Color numColor,
          {Color? unitColor, double fs = 14, double? unitFs}) =>
      Text.rich(TextSpan(children: [
        TextSpan(text: _nf.format(v), style: TextStyle(color: numColor, fontSize: fs)),
        TextSpan(
            text: ' 원',
            style: TextStyle(color: unitColor ?? _text, fontSize: unitFs ?? fs)),
      ]));

  Widget _dateBtn(DateTime? date, String hint, ValueChanged<DateTime> onPick) =>
      GestureDetector(
        onTap: () async {
          final p = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2026),
            lastDate: DateTime(2030),
            builder: (c, child) => Theme(
                data: ThemeData.dark()
                    .copyWith(colorScheme: const ColorScheme.dark(primary: _teal)),
                child: child!),
          );
          if (p != null) onPick(p);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(color: date != null ? _teal : _elevated),
              borderRadius: BorderRadius.circular(7)),
          child: Text(date != null ? DateFormat('MM-dd').format(date) : hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: date != null ? _teal : _text, fontSize: 14)),
        ),
      );

  Widget _smallBtn(String label, VoidCallback onTap, {bool filled = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: filled ? _teal : _pink, width: 1),
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(color: filled ? _teal : _pink, fontSize: 14)),
        ),
      );

  Widget _detailRow(String label, double v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: _text, fontSize: 14)),
          _amt(v, _text, fs: 14),
        ]),
      );

  Widget _toggleRow(String label, double v, Color labelColor, bool exp,
          VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Text(label, style: TextStyle(color: labelColor, fontSize: 14)),
            const SizedBox(width: 4),
            Icon(exp ? Icons.expand_less : Icons.expand_more,
                color: exp ? _text2 : _teal, size: 15),
            const Spacer(),
            _amt(v, labelColor, fs: 14),
          ]),
        ),
      );

  Widget _subGroup(List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
            color: _appBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _elevated)),
        child: Column(children: children),
      );

  Widget _subRow(String label, double v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: _text2, fontSize: 12)),
          _amt(v, _text2, unitColor: _text2, fs: 12, unitFs: 12),
        ]),
      );

  Widget _div() => Container(
      height: 1,
      color: _elevated.withValues(alpha: 0.6),
      margin: const EdgeInsets.symmetric(vertical: 12));

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _elevated, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Column(children: [
        Row(children: [
          _dateBtn(w.startDate, "시작일", w.onPickStart),
          const Text("  ~  ", style: TextStyle(color: _text, fontSize: 14)),
          _dateBtn(w.endDate, "종료일", w.onPickEnd),
          const SizedBox(width: 8),
          _smallBtn("조회", w.onSearch, filled: true),
          const SizedBox(width: 6),
          _smallBtn("초기화", w.onReset),
        ]),
        _div(),
        if (w.loading)
          const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: _teal))
        else if (!w.loaded)
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child:
                  Text("조회 버튼을 눌러주세요", style: TextStyle(color: _text2, fontSize: 14)))
        else ...[
          _detailRow("배달수수료 (세전)", w.gross),
          const SizedBox(height: 2),
          _toggleRow("지원금합계", w.mission + w.perOrder + w.range, _text, _promo,
              () => setState(() => _promo = !_promo)),
          if (_promo)
            _subGroup([
              _subRow("미션금액", w.mission),
              _subRow("건당프로모션", w.perOrder),
              _subRow("구간프로모션", w.range),
            ]),
          _toggleRow("세금합계", w.emp + w.acc + w.incomeTax, _pink, _tax,
              () => setState(() => _tax = !_tax)),
          if (_tax)
            _subGroup([
              _subRow("고용보험", w.emp),
              _subRow("산재보험", w.acc),
              _subRow("원천세", w.incomeTax),
            ]),
          _toggleRow("수수료합계", w.wdFee + w.comm, _pink, _comm,
              () => setState(() => _comm = !_comm)),
          if (_comm)
            _subGroup([
              _subRow("출금수수료", w.wdFee),
              _subRow("협력사수수료", w.comm),
            ]),
          _toggleRow("공제합계", w.ins + w.lease + w.etc, _pink, _dedu,
              () => setState(() => _dedu = !_dedu)),
          if (_dedu)
            _subGroup([
              _subRow("시간제보험", w.ins),
              _subRow("리스비", w.lease),
              _subRow("기타", w.etc),
            ]),
          _div(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("총 출금금액", style: TextStyle(color: _teal, fontSize: 16)),
            _amt(w.total, _teal, unitColor: _teal, fs: 16, unitFs: 16),
          ]),
        ],
      ]),
    );
  }
}
