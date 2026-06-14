// 기사 타임라인 — 동선 기록 시작/종료, 끊김 감지·이어서 시작, 오늘 경로 지도 표시, 지난 동선 진입
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'driver_common.dart';
import 'glass_shine_button.dart';
import 'location_tracker.dart';
import 'route_map_view.dart';
import 'app_dialogs.dart';
import 'driver_timeline_history_page.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _surface  = kSurface;
const _elevated = kElevated;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const _pink     = kPink;
const List<BoxShadow> _panelShadow = kPanelShadow;

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

  List<LatLng> _route = [];
  bool _active = false;        // Firestore상 기록중 여부
  bool _resumeAsked = false;   // 끊김 안내 1회만

  bool get _recording => LocationTracker.instance.isRecording;

  @override
  void initState() {
    super.initState();
    // Android 13+ 알림 권한 요청 → 기록 중 포그라운드 알림이 보이도록
    requestNotificationPermission();
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

  // ── 끊김 감지 안내 (문서는 기록중인데 실제 추적기는 꺼진 경우) ──
  void _showResumeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _pink, width: 1),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("지난 기록이 중단됐어요.\n이어서 다시 시작할까요?",
                style: TextStyle(
                    color: _pink, fontSize: 15, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: GlassShineButton(
                  label: "아니오",
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _markStopped();
                  },
                  accent: _text2,
                  textColor: _text2,
                  height: 46,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: kGapCard),
              Expanded(
                child: GlassShineButton(
                  label: "이어서 시작",
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final ok = await LocationTracker.instance.resume(widget.uid);
                    if (!ok && mounted) {
                      showInfoDialog(context, "위치 권한을 허용해야 동선을 기록할 수 있습니다.");
                    }
                    if (mounted) setState(() {});
                  },
                  accent: _teal,
                  textColor: _teal,
                  height: 46,
                  fontSize: 14,
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // 끊긴 기록을 "종료"로 마감 (이어서 안 함 선택 시)
  Future<void> _markStopped() async {
    await FirebaseFirestore.instance
        .collection('location_tracks')
        .doc(trackDocId(widget.uid, DateTime.now()))
        .set({'active': false, 'endedAt': Timestamp.now()},
            SetOptions(merge: true));
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
          _route = parseRoutePoints(data?['points'] as List?);
          _active = (data?['active'] as bool?) ?? false;
          // 문서는 기록중인데 추적기는 꺼져 있으면 = 비정상 끊김 → 1회 안내
          if (_active && !_recording && !_resumeAsked) {
            _resumeAsked = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showResumeDialog();
            });
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Column(children: [
              Expanded(child: RouteMapView(route: _route)),
              const SizedBox(height: kGapCard),
              _controls(),
            ]),
          );
        },
      );

  // ── 하단 컨트롤 (상태 + 기록 토글 + 지난 동선 + 안내) ──
  Widget _controls() {
    final recording = _recording || _active;
    return Column(children: [
      Row(children: [
        Icon(Icons.fiber_manual_record,
            color: recording ? _pink : _text, size: 12),
        const SizedBox(width: 6),
        Text(recording ? "기록 중" : "기록 정지",
            style: TextStyle(
                color: recording ? _pink : _text,
                fontSize: 13,
                fontWeight: FontWeight.w400)),
        const Spacer(),
        Text("오늘 ${_route.length}개 지점 · ${DateFormat('M.d').format(DateTime.now())}",
            style: const TextStyle(color: _text, fontSize: 12)),
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
            label: "지난 동선",
            icon: Icons.history_rounded,
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DriverTimelineHistoryPage(uid: widget.uid))),
            accent: _text2,
            textColor: _text,
            height: 48,
            fontSize: 14,
          ),
        ),
      ]),
      const SizedBox(height: kGapInner),
      const Text("기록 시작 전 위치 권한 설정 → 항상 허용",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: _pink, fontSize: 12, fontWeight: FontWeight.w400)),
    ]);
  }
}
