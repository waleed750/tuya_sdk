import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.isynclouds.syncn"
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
        applicationId = "com.isynclouds.syncn"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
         ndk {
            // add the ABIs you want to package
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
    }

     packaging {
        jniLibs {
            pickFirsts += listOf(
                "lib/*/libc++_shared.so",
                "lib/*/libyuv.so",
                "lib/*/libopenh264.so",
                "lib/*/libthing_security.so",
                "lib/*/libthing_security_algorithm.so"
            )
        }
        resources {
            excludes += listOf(
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/LICENSE",
                "META-INF/NOTICE.txt",
                "META-INF/INDEX.LIST",
                "**/values/values.xml",
                "**/values-*/values.xml"
            )
        }
    }
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        }
    }
}
configurations.all {
    exclude(group = "com.thingclips.smart", module = "thingsmart-modularCampAnno")
    exclude(group = "commons-io", module = "commons-io")
    // exclude(group = "com.facebook.fresco", module: "drawee")
    // exclude(group = "com.facebook.fresco", module: "fresco")
}

flutter {
    source = "../.."
}


dependencies {
    // Exclude commons-io from all configurations
    configurations.all {
        exclude(group = "commons-io", module = "commons-io")
    }
    
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
  implementation(files("libs/security-algorithm-1.0.0-beta.aar"))
  implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.aar"))))
}
