// 관리자 서브페이지 공용 — 전체배경→패널→뒤로가기 헤더 래퍼 스캐폴드
import 'package:flutter/material.dart';
import 'tokens.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _elevated = kElevated;
const _text     = kText;
const List<BoxShadow> _panelShadow = kPanelShadow;

// 패널 레이아웃 공통값 (admin_page.dart 메인 패널과 동일)
const double _panelOuterPad    = 10;
const double _panelRadius      = 24;
const double _panelBorderAlpha = 1.0;

// 서브페이지 공용 래퍼 (전체배경 → 메인배경 패널 → 뒤로가기 헤더 + 내용)
Widget adminPanelScaffold(BuildContext context, String title, Widget child,
    {Color? dividerColor, double dividerInset = 0}) {
  return Scaffold(
    backgroundColor: _appBg,
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(_panelOuterPad),
        child: Container(
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(_panelRadius),
            border: Border.all(
                color: _elevated.withValues(alpha: _panelBorderAlpha), width: 1),
            boxShadow: _panelShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_panelRadius),
            child: Column(children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: _text, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(title,
                      style: const TextStyle(
                          color: _text, fontSize: 18, fontWeight: FontWeight.w700)),
                ]),
              ),
              Container(
                  height: 1,
                  margin: EdgeInsets.symmetric(horizontal: dividerInset),
                  color: dividerColor ?? _elevated),
              Expanded(child: child),
            ]),
          ),
        ),
      ),
    ),
  );
}
