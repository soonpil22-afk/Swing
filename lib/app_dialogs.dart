// 앱 공통 다이얼로그 — 시스템 뒤로가기 시 종료 확인 등
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tokens.dart';
import 'glass_shine_button.dart';

// 앱을 종료하지 않고 백그라운드로 내림(홈 버튼과 동일) → 위치 추적 등 포그라운드 서비스 유지
const MethodChannel _appChannel = MethodChannel('swingtiger/app');
Future<void> minimizeApp() async {
  if (kIsWeb) return;
  try {
    await _appChannel.invokeMethod('moveToBack');
  } catch (_) {}
}

// Android 13+ 알림 권한 요청 (동선 기록 포그라운드 알림 표시에 필요)
Future<void> requestNotificationPermission() async {
  if (kIsWeb) return;
  try {
    await _appChannel.invokeMethod('requestNotifications');
  } catch (_) {}
}

// "어플을 종료하시겠습니까?" 취소/종료 다이얼로그. 종료 선택 시 true.
Future<bool> showExitConfirmDialog(BuildContext context) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kElevated, width: 1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("어플을 종료하시겠습니까?",
              style: TextStyle(
                  color: kText, fontSize: 15, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: GlassShineButton(
                label: "취소",
                onPressed: () => Navigator.pop(ctx, false),
                accent: kText2,
                textColor: kText2,
                height: 46,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: kGapCard),
            Expanded(
              child: GlassShineButton(
                label: "종료",
                onPressed: () => Navigator.pop(ctx, true),
                accent: kPink,
                textColor: kPink,
                height: 46,
                fontSize: 14,
              ),
            ),
          ]),
        ]),
      ),
    ),
  );
  return r ?? false;
}
