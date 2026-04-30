import java.util.Properties
import java.io.FileInputStream

// 1. .env 파일 읽기 로직 (맨 위에 배치)
val env = Properties()
val envFile = rootProject.file("../.env")
if (envFile.exists()) {
    envFile.inputStream().use { env.load(it) }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin은 반드시 Android/Kotlin 플러그인 다음에 와야 함
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.next502_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // 고유한 Application ID
        applicationId = "com.example.next502_app"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 2. AndroidManifest에서 사용할 수 있도록 변수 주입
        // .env 파일에서 NAVER_MAP_CLIENT_ID 값을 가져오며, 없으면 빈 값을 넣음
        manifestPlaceholders["NAVER_MAP_CLIENT_ID"] = env.getProperty("NAVER_MAP_CLIENT_ID") ?: ""
    }

    buildTypes {
        release {
            // 출시용 서명 설정이 생략되었으므로 디버그 키를 임시 사용
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 필요한 추가 의존성이 있다면 여기에 추가
}