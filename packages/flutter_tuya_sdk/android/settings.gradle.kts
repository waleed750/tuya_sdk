pluginManagement {
    repositories {
        google()
        mavenCentral()
        maven(url = "https://maven-other.tuya.com/repository/maven-public/")
        maven(url = "https://maven-other.tuya.com/repository/maven-releases/")
        maven(url = "https://maven-other.tuya.com/repository/maven-commercial-releases/")
        maven(url = "https://jitpack.io")
        gradlePluginPortal()
    }
    plugins {
        id("com.android.library") version "8.7.0"
        id("org.jetbrains.kotlin.android") version "2.0.21"
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven(url = "https://maven-other.tuya.com/repository/maven-public/")
        maven(url = "https://maven-other.tuya.com/repository/maven-releases/")
        maven(url = "https://maven-other.tuya.com/repository/maven-commercial-releases/")
        maven(url = "https://jitpack.io")
        maven(url = "https://maven.aliyun.com/repository/public")
    }
}
rootProject.name = "tuya_flutter_ha_sdk"
