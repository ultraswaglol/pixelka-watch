pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")

// ==========================================================================
// 🔥 FIX FOR OLD PLUGINS (Pixelka Watch Patch)
// Так как мы удалили package из манифеста библиотеки wear,
// мы обязаны добавить namespace здесь вручную.
// ==========================================================================
gradle.beforeProject {
    if (this.path == ":wear") {
        // Важно: используем именно тот ID, который был в манифесте
        this.buildFile.appendText("\nandroid { namespace = \"com.mjohnsullivan.flutterwear.wear\" }")
    }
}