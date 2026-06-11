// 기사 페이지 공통 "준비중" 안내 서브페이지 (미니게임·타임라인 등 미구현 메뉴용)
import 'package:flutter/material.dart';
import 'tokens.dart';
import 'driver_common.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _elevated = kElevated;
const _text2    = kText2;
const List<BoxShadow> _panelShadow = kPanelShadow;

class DriverSoonPage extends StatelessWidget {
  final String title;
  const DriverSoonPage({super.key, required this.title});

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
                pageHeader(context, title),
                const SizedBox(height: kGapInner),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  color: _elevated.withValues(alpha: 0.6),
                ),
                const Expanded(
                  child: Center(
                    child: Text("준비중",
                        style: TextStyle(
                            color: _text2,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
