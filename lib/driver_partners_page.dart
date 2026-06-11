// 기사 협력업체 안내 페이지 — 준비중 + 제휴 예정 업종 목록
import 'package:flutter/material.dart';
import 'tokens.dart';
import 'driver_common.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _surface  = kSurface;
const _elevated = kElevated;
const _text     = kText;
const _teal     = kTeal;
const _pink     = kPink;
const List<BoxShadow> _panelShadow = kPanelShadow;
const List<BoxShadow> _cardShadow  = kCardShadow;

const List<String> _partners = [
  '내연오토바이 H모터스 (정비/리스)',
  '전기오토바이 #모터스 (정비/리스/렌탈)',
  '보험 배달서비스공제조합',
  '손해사정사',
  '세무회계사 절세연구소',
  '배달 필수장비',
];

class DriverPartnersPage extends StatelessWidget {
  const DriverPartnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _elevated),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(children: [
                const SizedBox(height: 8),
                pageHeader(context, "협력업체"),
                const SizedBox(height: kGapInner),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  color: _elevated.withValues(alpha: 0.6),
                ),
                const SizedBox(height: kGapSection),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text("준비중입니다!!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _pink,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                      ),
                      for (var i = 0; i < _partners.length; i++)
                        _item(i + 1, _partners[i]),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(int n, String label) => Container(
        margin: const EdgeInsets.only(bottom: kGapCard),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _elevated, width: 1),
          boxShadow: _cardShadow,
        ),
        child: Row(children: [
          SizedBox(
            width: 26,
            child: Text("$n",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _teal, fontSize: 15, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: _text, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}
