// 경로(LatLng 리스트)를 지도에 폴리라인으로 그리고 차례대로 재생하는 공용 위젯 (오늘·지난 동선 공용)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'tokens.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _surface  = kSurface;
const _elevated = kElevated;
const _text2    = kText2;
const _teal     = kTeal;
const _amber    = kAmber;
const _purple   = kPurple;
const List<BoxShadow> _cardShadow = kCardShadow;

// Firestore points 배열 → 경로 좌표 리스트 (t 오름차순). 오늘·지난 동선 공용.
List<LatLng> parseRoutePoints(List? raw) {
  final pts = (raw ?? [])
      .whereType<Map>()
      .map((m) => {
            'lat': (m['lat'] as num?)?.toDouble(),
            'lng': (m['lng'] as num?)?.toDouble(),
            't': (m['t'] as num?)?.toInt() ?? 0,
          })
      .where((m) => m['lat'] != null && m['lng'] != null)
      .toList()
    ..sort((a, b) => (a['t'] as int).compareTo(b['t'] as int));
  return pts.map((m) => LatLng(m['lat'] as double, m['lng'] as double)).toList();
}

class RouteMapView extends StatefulWidget {
  final List<LatLng> route;
  const RouteMapView({super.key, required this.route});
  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  final MapController _map = MapController();
  Timer? _playTimer;
  int _idx = 0;
  bool _playing = false;

  List<LatLng> get _route => widget.route;

  @override
  void didUpdateWidget(RouteMapView old) {
    super.didUpdateWidget(old);
    if (_idx > _route.length - 1) _idx = _route.isEmpty ? 0 : _route.length - 1;
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (_route.length < 2) return;
    if (_playing) {
      _playTimer?.cancel();
      setState(() => _playing = false);
      return;
    }
    if (_idx >= _route.length - 1) _idx = 0;
    setState(() => _playing = true);
    _playTimer = Timer.periodic(const Duration(milliseconds: 400), (t) {
      if (_idx >= _route.length - 1) {
        t.cancel();
        setState(() => _playing = false);
        return;
      }
      setState(() => _idx++);
      _map.move(_route[_idx], _map.camera.zoom);
    });
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _elevated, width: 1),
          boxShadow: _cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _route.isEmpty ? _empty() : _map3(),
        ),
      );

  Widget _empty() => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.map_outlined, color: _text2, size: 40),
          SizedBox(height: 10),
          Text("표시할 동선이 없습니다.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _text2, fontSize: 13, height: 1.4)),
        ]),
      );

  Widget _map3() {
    final playPos = _route[_idx.clamp(0, _route.length - 1)];
    return Stack(children: [
      FlutterMap(
        mapController: _map,
        options: MapOptions(initialCenter: _route.last, initialZoom: 14),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.swingtiger.app',
          ),
          PolylineLayer(polylines: [
            Polyline(points: _route, color: _teal, strokeWidth: 5),
          ]),
          MarkerLayer(markers: [
            _pin(_route.first, _amber, Icons.flag_rounded),    // 출발
            _pin(playPos, _purple, Icons.navigation_rounded),  // 현재(재생) 위치
          ]),
        ],
      ),
      // 재생/일시정지 버튼 (지도 우하단)
      Positioned(
        right: 10,
        bottom: 10,
        child: GestureDetector(
          onTap: _route.length < 2 ? null : _togglePlay,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _surface,
              shape: BoxShape.circle,
              border: Border.all(color: _amber, width: 1),
              boxShadow: _cardShadow,
            ),
            child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: _amber, size: 26),
          ),
        ),
      ),
    ]);
  }

  Marker _pin(LatLng p, Color c, IconData icon) => Marker(
        point: p,
        width: 30,
        height: 30,
        child: Icon(icon, color: c, size: 26),
      );
}
