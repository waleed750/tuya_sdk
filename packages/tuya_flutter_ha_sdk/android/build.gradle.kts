plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

// Local safeguard for Gradle 8 config clash
afterEvaluate {
    val cfg = configurations.findByName("debugRuntimeClasspathCopy")
    if (cfg != null) {
        cfg.isCanBeConsumed = false
        cfg.isCanBeResolved = true
    }
}

android {
    namespace = "us.kpmsg.tuya_flutter_ha_sdk"
    compileSdk = 35

    defaultConfig {
        minSdk = 23
        consumerProguardFiles("consumer-rules.pro")
    }

    buildFeatures {
        buildConfig = false
        aidl = false
        renderScript = false
        shaders = false
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
        freeCompilerArgs += listOf("-Xjvm-default=all")
    }

    lint {
        abortOnError = false
    }
}

dependencies {
    // Tuya core & BizBundles
    implementation("com.thingclips.smart:thingsmart:6.2.2")
    implementation(platform("com.thingclips.smart:thingsmart-BizBundlesBom:6.2.16"))
    implementation("com.thingclips.smart:thingsmart-ipcsdk:6.4.2")
    implementation("com.thingclips.smart:thingsmart-bizbundle-device_activator")
    implementation("com.thingclips.smart:thingsmart-lock-sdk:6.0.1")

    // util libs
    implementation("com.alibaba:fastjson:1.1.67.android")
    implementation("com.squareup.okhttp3:okhttp-urlconnection:3.14.9")
    implementation("com.facebook.soloader:soloader:0.10.4+")

    // Kotlin stdlib comes transitively, but keep explicit if needed:
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.0.21")

    testImplementation("junit:junit:4.13.2")
    testImplementation("org.mockito:mockito-core:5.0.0")
}
