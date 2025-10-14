plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}


dependencies {
     // Tuya Home SDK Core (ensure version matches your downloaded SDK, e.g., 6.2.2)
    implementation("com.thingclips.smart:thingsmart:6.2.2")

  // Tuya BizBundles BOM (aligns all BizBundles to version 6.2.16)
//   implementation platform("com.thingclips.smart:thingsmart-BizBundlesBom:6.2.16")

  implementation ("com.thingclips.smart:thingsmart-ipcsdk:6.4.2")
  // Example BizBundle: Device Activator
  implementation ("com.thingclips.smart:thingsmart-bizbundle-device_activator")

  implementation ("com.thingclips.smart:thingsmart-lock-sdk:6.0.1")

  // SoLoader (required by Tuya SDK)
  implementation ("com.facebook.soloader:soloader:0.10.4+")
  
  implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.aar"))))
}
