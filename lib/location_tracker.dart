// 동선 기록 서비스 — geolocator 위치 스트림을 Firestore에 누적하고 자정 자동 종료
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

// 하루 1문서: location_tracks/{uid}_{yyyy-MM-dd}, points 배열에 {lat,lng,t} 누적
String trackDocId(String uid, DateTime day) =>
    '${uid}_${DateFormat('yyyy-MM-dd').format(day)}';

class LocationTracker {
  LocationTracker._();
  static final LocationTracker instance = LocationTracker._();

  StreamSubscription<Position>? _sub;
  Timer? _midnightTimer;
  String? _uid;
  String? _date;

  bool get isRecording => _sub != null;

  // 위치 권한 확인·요청 (서비스 꺼짐/거부 시 false)
  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  // 플랫폼별 위치 설정 (안드: 포그라운드 서비스로 백그라운드 지속 / iOS: 백그라운드 갱신)
  LocationSettings _settings() {
    const distanceFilter = 15; // 15m 이동마다 기록 → 배터리 절약
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'SwingTiger 동선 기록 중',
          notificationText: '앱을 닫아도 이동 경로를 기록합니다.',
          enableWakeLock: true,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: distanceFilter);
  }

  DocumentReference<Map<String, dynamic>> _docRef(String uid, DateTime day) =>
      FirebaseFirestore.instance.collection('location_tracks').doc(trackDocId(uid, day));

  // 기록 시작 (웹 미지원). 성공 시 true.
  Future<bool> start(String uid) async {
    if (kIsWeb || isRecording) return false;
    if (!await _ensurePermission()) return false;

    final now = DateTime.now();
    _uid = uid;
    _date = DateFormat('yyyy-MM-dd').format(now);

    await _docRef(uid, now).set({
      'uid': uid,
      'date': _date,
      'startedAt': Timestamp.fromDate(now),
      'endedAt': null,
      'active': true,
      'points': FieldValue.arrayUnion([]),
    }, SetOptions(merge: true));

    _listen(now);
    return true;
  }

  // 끊긴 오늘 기록 이어서 시작 (startedAt·기존 points 보존). 성공 시 true.
  Future<bool> resume(String uid) async {
    if (kIsWeb || isRecording) return false;
    if (!await _ensurePermission()) return false;

    final now = DateTime.now();
    _uid = uid;
    _date = DateFormat('yyyy-MM-dd').format(now);

    await _docRef(uid, now).set({
      'endedAt': null,
      'active': true,
    }, SetOptions(merge: true));

    _listen(now);
    return true;
  }

  void _listen(DateTime now) {
    _sub = Geolocator.getPositionStream(locationSettings: _settings())
        .listen(_onPosition);
    _scheduleMidnightStop(now);
  }

  void _onPosition(Position p) {
    final uid = _uid;
    if (uid == null || _date == null) return;
    _docRef(uid, DateTime.now()).set({
      'points': FieldValue.arrayUnion([
        {
          'lat': p.latitude,
          'lng': p.longitude,
          't': DateTime.now().millisecondsSinceEpoch,
        }
      ]),
    }, SetOptions(merge: true));
  }

  // 다음 자정(00:00)에 자동 종료 예약
  void _scheduleMidnightStop(DateTime now) {
    _midnightTimer?.cancel();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), stop);
  }

  // 기록 종료 (수동 또는 자정 자동)
  Future<void> stop() async {
    final uid = _uid;
    final date = _date;
    await _sub?.cancel();
    _sub = null;
    _midnightTimer?.cancel();
    _midnightTimer = null;
    if (uid != null && date != null) {
      // 시작 당일 문서에 종료 표시 (자정 넘김 시에도 시작일 기준)
      final day = DateFormat('yyyy-MM-dd').parse(date);
      await _docRef(uid, day).set({
        'endedAt': Timestamp.fromDate(DateTime.now()),
        'active': false,
      }, SetOptions(merge: true));
    }
    _uid = null;
    _date = null;
  }
}
