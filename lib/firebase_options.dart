// 플랫폼별 Firebase 초기화 옵션 (웹용 설정 제공)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

// 웹에서만 사용하는 Firebase 설정. 안드로이드는 google-services.json 사용.
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) return web;
    return null; // 웹이 아니면 기본(google-services.json) 사용
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAjHiGFhJEQgeYF6Vr5_xysfUL5fNs-fXU',
    authDomain: 'swingtiger-723f8.firebaseapp.com',
    projectId: 'swingtiger-723f8',
    storageBucket: 'swingtiger-723f8.firebasestorage.app',
    messagingSenderId: '975377310670',
    appId: '1:975377310670:web:100ce074e79636db04019f',
    measurementId: 'G-X1M28SM381',
  );
}
