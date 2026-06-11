// 기사 타임라인 — 동선 기록 시작/종료 + 오늘 경로를 지도에 표시하고 차례대로 재생
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'driver_common.dart';
import 'glass_shine_button.dart';
import 'location_tracker.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _surface  = kSurface;
const _elevated = kElevated;
const _text2    = kText2;
const _teal     = kTeal;
const _pink     = kPink;
const _amber    = kAmber;
const List<BoxShadow> _panelShadow = kPanelShadow;
const List<BoxShadow> _cardShadow  = kCardShadow;

class DriverTimelinePage extends StatefulWidget {
  final String uid;
  const DriverTimelinePage({super.key, required this.uid});
  @override
  State<DriverTimelinePage> createState() => _DriverTimelinePageState();
}

class _DriverTimelinePageState extends State<DriverTimelinePage> {
  // 오늘 동선 문서 구독 (build마다 재구독 금지 → State 필드로 한 번만 생성)
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _trackStream =
      FirebaseFirestore.instance
          .collection('location_tracks')
          .doc(trackDocId(widget.uid, DateTime.now()))
          .snapshots();

  GoogleMapController? _map;
  List<LatLng> _route = [];
  bool _active = false; // Firestore상 기록중 여부

  // 재생 상태
  Timer? _playTimer;
  int _playIdx = 0;
  bool _playing = false;

  bool get _recording => LocationTracker.instance.isRecording;

  @override
  void dispose() {
    _playTimer?.cancel();
    _map?.dispose();
    super.dispose();
  }

  // ── 기록 시작/종료 ──
  Future<void> _toggleRecord() async {
    if (kIsWeb) {
      showInfoDialog(context, "동선 기록은 모바일 앱에서만 가능합니다.");
      return;
    }
    if (_recording) {
      await LocationTracker.instance.stop();
    } else {
      final ok = await LocationTracker.instance.start(widget.uid);
      if (!ok && mounted) {
        showInfoDialog(context, "위치 권한을 허용해야 동선을 기록할 수 있습니다.");
      }
    }
    if (mounted) setState(() {});
  }

  // ── 경로 차례대로 재생 ──
  void _togglePlay() {
    if (_route.length < 2) return;
    if (_playing) {
      _playTimer?.cancel();
      setState(() => _playing = false);
      return;
    }
    if (_playIdx >= _route.length - 1) _playIdx = 0;
    setState(() => _playing = true);
    _playTimer = Timer.periodic(const Duration(milliseconds: 400), (t) {
      if (_playIdx >= _route.length - 1) {
        t.cancel();
        setState(() => _playing = false);
        return;
      }
      setState(() => _playIdx++);
      _map?.animateCamera(CameraUpdate.newLatLng(_route[_playIdx]));
    });
  }

  // 문서 → 경로 좌표 리스트 (t 오름차순)
  List<LatLng> _parseRoute(Map<String, dynamic>? data) {
    final raw = (data?['points'] as List?) ?? [];
    final pts = raw
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
                pageHeader(context, "타임라인"),
                const SizedBox(height: kGapInner),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  color: _elevated.withValues(alpha: 0.6),
                ),
                const SizedBox(height: kGapSection),
                Expanded(child: _body()),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _trackStream,
        builder: (_, snap) {
          final data = snap.data?.data();
          _route = _parseRoute(data);
          _active = (data?['active'] as bool?) ?? false;
          if (_playIdx > _route.length - 1) {
            _playIdx = _route.isEmpty ? 0 : _route.length - 1;
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Column(children: [
              Expanded(child: _mapCard()),
              const SizedBox(height: kGapCard),
              _controls(),
            ]),
          );
        },
      );

  // ── 지도 카드 (경로 폴리라인 + 재생 마커) ──
  Widget _mapCard() {
    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _elevated, width: 1),
        boxShadow: _cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _route.isEmpty ? _emptyMap() : _googleMap(),
      ),
    );
    return box;
  }

  Widget _emptyMap() => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.map_outlined, color: _text2, size: 40),
          SizedBox(height: 10),
          Text("아직 기록된 동선이 없습니다.\n기록을 시작하면 오늘 경로가 표시됩니다.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _text2, fontSize: 13, height: 1.4)),
        ]),
      );

  Widget _googleMap() {
    final playPos = _route[_playIdx.clamp(0, _route.length - 1)];
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _route.last, zoom: 15),
      myLocationEnabled: !kIsWeb,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (c) => _map = c,
      polylines: {
        Polyline(
          polylineId: const PolylineId('route'),
          points: _route,
          color: _teal,
          width: 5,
        ),
      },
      markers: {
        Marker(
          markerId: const MarkerId('start'),
          position: _route.first,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: '출발'),
        ),
        Marker(
          markerId: const MarkerId('current'),
          position: playPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      },
    );
  }

  // ── 하단 컨트롤 (상태 + 기록 토글 + 재생) ──
  Widget _controls() {
    final recording = _recording || _active;
    return Column(children: [
      Row(children: [
        Icon(Icons.fiber_manual_record,
            color: recording ? _pink : _text2, size: 12),
        const SizedBox(width: 6),
        Text(recording ? "기록 중" : "기록 정지",
            style: TextStyle(
                color: recording ? _pink : _text2,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        const Spacer(),
        Text("오늘 ${_route.length}개 지점 · ${DateFormat('M.d').format(DateTime.now())}",
            style: const TextStyle(color: _text2, fontSize: 12)),
      ]),
      const SizedBox(height: kGapInner),
      Row(children: [
        Expanded(
          child: GlassShineButton(
            label: recording ? "기록 종료" : "기록 시작",
            icon: recording ? Icons.stop_rounded : Icons.play_arrow_rounded,
            onPressed: _toggleRecord,
            accent: recording ? _pink : _teal,
            textColor: recording ? _pink : _teal,
            height: 48,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: kGapCard),
        Expanded(
          child: GlassShineButton(
            label: _playing ? "일시정지" : "경로 재생",
            icon: _playing ? Icons.pause_rounded : Icons.smart_display_rounded,
            onPressed: _route.length < 2 ? null : _togglePlay,
            accent: _amber,
            textColor: _amber,
            height: 48,
            fontSize: 14,
          ),
        ),
      ]),
    ]);
  }
}
