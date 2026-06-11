// 미니게임 점수 랭킹 — 상위 10명 표시, 그 외 등수는 본인 순위만 따로 표시
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tokens.dart';
import 'driver_common.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _surface  = kSurface;
const _elevated = kElevated;
const _chip     = kChip;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const _amber    = kAmber;
const List<BoxShadow> _panelShadow = kPanelShadow;
const List<BoxShadow> _cardShadow  = kCardShadow;

class GameRankingPage extends StatefulWidget {
  final String uid;
  const GameRankingPage({super.key, required this.uid});
  @override
  State<GameRankingPage> createState() => _GameRankingPageState();
}

class _GameRankingPageState extends State<GameRankingPage> {
  // game_scores 전체 구독(단일 컬렉션, 정렬은 화면에서 — 규칙 F). 라이더 수가 적어 전량 조회 OK.
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream =
      FirebaseFirestore.instance.collection('game_scores').snapshots();

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
                pageHeader(context, "미니게임 랭킹"),
                const SizedBox(height: kGapInner),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  color: _elevated.withValues(alpha: 0.6),
                ),
                const SizedBox(height: kGapSection),
                Expanded(child: _list()),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: _teal));
          }
          final all = snap.data!.docs.toList()
            ..sort((a, b) => ((b.data()['score'] as num?) ?? 0)
                .compareTo((a.data()['score'] as num?) ?? 0));
          if (all.isEmpty) {
            return const Center(
                child: Text("아직 기록이 없습니다.",
                    style: TextStyle(color: _text2, fontSize: 13)));
          }
          final myIdx = all.indexWhere((d) => d.id == widget.uid);
          final top = all.take(10).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            children: [
              for (var i = 0; i < top.length; i++)
                _rankRow(i + 1, top[i].data(), me: top[i].id == widget.uid),
              // 본인이 10등 밖이면 본인 순위만 따로
              if (myIdx >= 10) ...[
                const SizedBox(height: kGapSection),
                Row(children: [
                  Expanded(child: Container(height: 1, color: _elevated)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("내 순위",
                        style: TextStyle(color: _text2, fontSize: 11)),
                  ),
                  Expanded(child: Container(height: 1, color: _elevated)),
                ]),
                const SizedBox(height: kGapCard),
                _rankRow(myIdx + 1, all[myIdx].data(), me: true),
              ],
            ],
          );
        },
      );

  Widget _rankRow(int rank, Map<String, dynamic> d, {required bool me}) {
    final name = (d['name'] as String?)?.trim();
    final score = (d['score'] as num?)?.toInt() ?? 0;
    final medal = rank == 1
        ? _amber
        : (rank <= 3 ? _teal : _text2); // 1등 금, 2~3등 민트, 그외 회색
    return Container(
      margin: const EdgeInsets.only(bottom: kGapCard),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: me ? _chip : _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: me ? _teal : _elevated, width: 1),
        boxShadow: _cardShadow,
      ),
      child: Row(children: [
        SizedBox(
          width: 30,
          child: Text("$rank",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: medal, fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(name == null || name.isEmpty ? "이름없음" : name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: me ? _teal : _text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ),
        Text.rich(TextSpan(children: [
          TextSpan(
              text: "$score",
              style: const TextStyle(
                  color: _teal, fontSize: 15, fontWeight: FontWeight.w800)),
          const TextSpan(
              text: " 점",
              style: TextStyle(color: _text, fontSize: 12)),
        ])),
      ]),
    );
  }
}
