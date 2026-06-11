package com.swingtiger.app  // ✅ 변경

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val appChannel = "swingtiger/app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 앱을 종료하지 않고 백그라운드로 내림(홈 버튼과 동일) → 위치 추적 포그라운드 서비스 유지
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "moveToBack") {
                    moveTaskToBack(true)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
