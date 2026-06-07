// 관리자 출금 랭킹 더보기 — 전체 라이더 출금 순위 목록 페이지
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _elevated = kElevated;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const List<BoxShadow> _panelShadow = kPanelShadow;

// 자체 스캐폴드 레이아웃 (메인 패널과 동일)
const double _panelBorderAlpha = 1.0;
const double _panelOuterPad = 10;
const double _panelRadius   = 24;
const Color  _subDivColor   = _elevated;
const double _subDivMarginH = 15;
const double _subGapHeaderToDiv = kGapInner;
const double _subGapDivToBody   = kGapSection;

// 랭킹 행 상수(_rank*)
const _rankNameColor    = _text;
const double _rankNameFontSize  = 13;
const _rankAmtColor     = _teal;
const double _rankAmtFontSize   = 14;
const double _rankAmtUnitFontSize = 12;
const double _rankBadgeSize     = 24;
const double _rankBadgeFontSize = 12;
const double _rankMedalSize     = 26;
const _rankGold   = Color.fromARGB(255, 241, 201, 97);
const _rankSilver = Color.fromARGB(255, 200, 207, 216);
const _rankBronze = Color.fromARGB(255, 177, 118, 79);
const _rankEtc    = _text;
const _rankEmptyColor   = _text2;
const double _rankEmptyFontSize = 12;

// ═══════════════ 전체 출금 랭킹 페이지 (로직) ═══════════════
class FullRankingPage extends StatelessWidget {
  final String title;
  final List<MapEntry<String, double>> ranking;
  const FullRankingPage({super.key, required this.title, required this.ranking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,
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
                  padding: const EdgeInsets.fromLTRB(6, 6, 16, 0),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: _text, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(title,
                        style: const TextStyle(
                            color: _text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(height: _subGapHeaderToDiv),
                Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: _subDivMarginH),
                    color: _subDivColor),
                const SizedBox(height: _subGapDivToBody),
                Expanded(
                  child: ranking.isEmpty
                      ? const Center(
                          child: Text("지급 내역이 없습니다.",
                              style: TextStyle(
                                  color: _rankEmptyColor,
                                  fontSize: _rankEmptyFontSize)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                          itemCount: ranking.length,
                          itemBuilder: (_, i) {
                            final e = ranking[i];
                            final rank = i + 1;
                            final badgeColor = rank == 1
                                ? _rankGold
                                : rank == 2
                                    ? _rankSilver
                                    : rank == 3
                                        ? _rankBronze
                                        : _rankEtc;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(children: [
                                // 1·2·3등 = 금·은·동 메달 / 4등~ = 숫자
                                SizedBox(
                                  width: _rankBadgeSize,
                                  height: _rankBadgeSize,
                                  child: rank <= 3
                                      ? Icon(Icons.military_tech,
                                          color: badgeColor, size: _rankMedalSize)
                                      : Center(
                                          child: Text("$rank",
                                              style: TextStyle(
                                                  color: badgeColor,
                                                  fontSize: _rankBadgeFontSize,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(e.key,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: _rankNameColor,
                                          fontSize: _rankNameFontSize,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text:
                                          NumberFormat('#,###').format(e.value),
                                      style: const TextStyle(
                                          color: _rankAmtColor,
                                          fontSize: _rankAmtFontSize,
                                          fontWeight: FontWeight.w700)),
                                  const TextSpan(
                                      text: ' 원',
                                      style: TextStyle(
                                          color: _text,
                                          fontSize: _rankAmtUnitFontSize)),
                                ])),
                              ]),
                            );
                          },
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
