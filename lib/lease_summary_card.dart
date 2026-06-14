// 리스비/기타 "전체 현황" 카드 — 기사·관리자 공용 단일 출처 (디자인 한 곳에서 관리)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _surface  = kSurface;
const _elevated = kElevated;
const _chip     = kChip;
const _text     = kText;
const _teal     = kTeal;
const _pink     = kPink;
const _amber    = kAmber;
const List<BoxShadow> _cardShadow = kCardShadow;

final _nf = NumberFormat('#,###');

class LeaseSummaryCard extends StatelessWidget {
  final String title;      // '리스비' / '기타'
  final IconData icon;
  final Color accent;      // 종류 강조색
  final String typeLabel;  // 매일 / 주1회 / 매월
  final String cycleLabel; // 일 / 회차
  final bool isDaily;
  final int unitAmt;       // 1일/회차 금액
  final int cycle;         // 총 일/회차
  final int totalAmt;      // 총 리스비/기타
  final String startShort; // 기간 시작 (MM-dd)
  final String endShort;   // 기간 끝 (MM-dd)
  final int paidCount;
  final int totalCount;
  final int paidAmt;       // 납부 완료액
  final Color borderColor; // 카드 테두리(강조 시 변경)
  final List<Widget> extra; // 카드 하단 추가 위젯(기사 알림/버튼 등)

  const LeaseSummaryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.typeLabel,
    required this.cycleLabel,
    required this.isDaily,
    required this.unitAmt,
    required this.cycle,
    required this.totalAmt,
    required this.startShort,
    required this.endShort,
    required this.paidCount,
    required this.totalCount,
    required this.paidAmt,
    this.borderColor = _elevated,
    this.extra = const [],
  });

  Widget _infoRow(String label, String value,
          {Color valueColor = _text, Color labelColor = _text}) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 14)),
      ]);

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? paidCount / totalCount : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: accent, size: 26),
          const SizedBox(width: 6),
          Text("$title 전체 현황",
              style: const TextStyle(color: _text, fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _chip,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _elevated, width: 1),
            ),
            child: Text(typeLabel,
                style: TextStyle(color: accent, fontSize: 14)),
          ),
        ]),
        Container(
            height: 1,
            color: _elevated,
            margin: const EdgeInsets.symmetric(vertical: 10)),
        _infoRow("1$cycleLabel 금액", "${_nf.format(unitAmt)} 원"),
        const SizedBox(height: 5),
        _infoRow("총 $cycleLabel", "$cycle $cycleLabel"),
        const SizedBox(height: 5),
        _infoRow("총 $title", "${_nf.format(totalAmt)} 원"),
        const SizedBox(height: 5),
        _infoRow("기간", "$startShort  ~  $endShort"),
        if (isDaily) ...[
          const SizedBox(height: 5),
          _infoRow("납부 방식", "출금 시 자동 공제",
              valueColor: _pink, labelColor: _pink),
        ],
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("진행 현황",
              style: TextStyle(color: _amber, fontSize: 14)),
          Text.rich(TextSpan(children: [
            TextSpan(text: "$paidCount",
                style: const TextStyle(color: _amber, fontSize: 14)),
            TextSpan(text: " / $totalCount $cycleLabel",
                style: const TextStyle(color: _amber, fontSize: 14)),
          ])),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: _chip,
            valueColor: const AlwaysStoppedAnimation<Color>(_teal),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("납부 완료",
              style: TextStyle(color: _amber, fontSize: 14)),
          Text("${_nf.format(paidAmt)} 원",
              style: const TextStyle(color: _amber, fontSize: 14)),
        ]),
        if (totalAmt > paidAmt) ...[
          const SizedBox(height: 3),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("잔여 금액",
                style: TextStyle(color: _teal, fontSize: 14)),
            Text("${_nf.format(totalAmt - paidAmt)} 원",
                style: const TextStyle(color: _teal, fontSize: 14)),
          ]),
        ],
        ...extra,
      ]),
    );
  }
}
