// 기사 지난 동선 보기 — 날짜별 기록 목록 + 선택한 날의 경로를 지도로 다시 보기
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'driver_common.dart';
import 'route_map_view.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _surface  = kSurface;
const _elevated = kElevated;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const List<BoxShadow> _panelShadow = kPanelShadow;
const List<BoxShadow> _cardShadow  = kCardShadow;

// 패널 스캐폴드 (뒤로가기 헤더 + 경계선 + 내용)
Widget _panelScaffold(BuildContext context, String title, Widget child) =>
    Scaffold(
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
                const SizedBox(height: kGapSection),
                Expanded(child: child),
              ]),
            ),
          ),
        ),
      ),
    );

class DriverTimelineHistoryPage extends StatefulWidget {
  final String uid;
  const DriverTimelineHistoryPage({super.key, required this.uid});
  @override
  State<DriverTimelineHistoryPage> createState() =>
      _DriverTimelineHistoryPageState();
}

class _DriverTimelineHistoryPageState extends State<DriverTimelineHistoryPage> {
  // uid 단일 where만 사용(복합 인덱스 회피), 정렬은 화면에서 (규칙 F)
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream =
      FirebaseFirestore.instance
          .collection('location_tracks')
          .where('uid', isEqualTo: widget.uid)
          .snapshots();

  @override
  Widget build(BuildContext context) => _panelScaffold(context, "지난 동선", _list());

  Widget _list() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: _teal));
          }
          final docs = snap.data!.docs.toList()
            ..sort((a, b) => (b.data()['date'] as String? ?? '')
                .compareTo(a.data()['date'] as String? ?? ''));
          if (docs.isEmpty) {
            return const Center(
                child: Text("저장된 동선이 없습니다.",
                    style: TextStyle(color: _text2, fontSize: 13)));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: kGapCard),
            itemBuilder: (_, i) => _dayCard(docs[i].data()),
          );
        },
      );

  Widget _dayCard(Map<String, dynamic> data) {
    final date = data['date'] as String? ?? '';
    final route = parseRoutePoints(data['points'] as List?);
    final count = route.length;
    return GestureDetector(
      onTap: count < 1
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => _RouteDayPage(date: date, data: data))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _elevated, width: 1),
          boxShadow: _cardShadow,
        ),
        child: Row(children: [
          const Icon(Icons.route_rounded, color: _teal, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_fmtDate(date),
                style: const TextStyle(
                    color: _text, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_fmtDist(route),
                style: const TextStyle(
                    color: _teal, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text("$count개 지점",
                style: const TextStyle(color: _text2, fontSize: 11)),
          ]),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: _text2, size: 20),
        ]),
      ),
    );
  }

  // 경로 좌표 누적 거리 → "X.X km" (1km 미만은 "Xm")
  static const Distance _distance = Distance();
  String _fmtDist(List<LatLng> route) {
    var m = 0.0;
    for (var i = 1; i < route.length; i++) {
      m += _distance.as(LengthUnit.Meter, route[i - 1], route[i]);
    }
    return m < 1000 ? '${m.round()}m' : '${(m / 1000).toStringAsFixed(1)}km';
  }

  // yyyy-MM-dd → "M월 d일 (요일)"
  static const _kWeek = ['월', '화', '수', '목', '금', '토', '일'];
  String _fmtDate(String date) {
    try {
      final d = DateFormat('yyyy-MM-dd').parse(date);
      return '${d.month}월 ${d.day}일 (${_kWeek[d.weekday - 1]})';
    } catch (_) {
      return date;
    }
  }
}

// 선택한 날짜의 경로 한 화면
class _RouteDayPage extends StatelessWidget {
  final String date;
  final Map<String, dynamic> data;
  const _RouteDayPage({required this.date, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<LatLng> route = parseRoutePoints(data['points'] as List?);
    return _panelScaffold(
      context,
      date,
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: RouteMapView(route: route),
      ),
    );
  }
}
