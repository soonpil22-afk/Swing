plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // ★ 필수 추가: 파이어베이스 연결을 위한 구글 서비스 플러그인입니다.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.swingtiger.app"  // ✅ 변경
    
    // 최신 패키지 호환성을 위해 숫자를 직접 지정해주는 것이 안전합니다.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.swingtiger.app"  // ✅ 변경
        
        // Firebase 및 최신 플러그인 구동을 위한 권장 최소 버전입니다.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
