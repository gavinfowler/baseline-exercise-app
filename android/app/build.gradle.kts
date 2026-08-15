import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload-key credentials, kept out of the repository. See
// android/key.properties.example for how to create them.
val keystorePropertiesFile = rootProject.file("key.properties")
val hasUploadKey = keystorePropertiesFile.exists()
val keystoreProperties = Properties().apply {
    if (hasUploadKey) {
        FileInputStream(keystorePropertiesFile).use { load(it) }
    }
}

android {
    namespace = "com.gavinfowler.baseline"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications, which uses java.time APIs to
        // schedule the rest-timer alert. Without desugaring the build fails
        // outright on checkDebugAarMetadata.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Permanent once the app is published: the Play Store keys an app's
        // identity on this and it can never be changed afterwards.
        applicationId = "com.gavinfowler.baseline"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("upload") {
            if (hasUploadKey) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Falls back to the debug key so a fresh clone can still run
            // `flutter run --release`. Play rejects a debug-signed upload, so
            // the fallback cannot ship by accident — but it is warned about
            // loudly below all the same.
            signingConfig = if (hasUploadKey) {
                signingConfigs.getByName("upload")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// Fires only when actually assembling a release, so day-to-day debug builds
// stay quiet.
gradle.taskGraph.whenReady {
    val releasing = allTasks.any {
        it.name.contains("Release") && (it.name.startsWith("assemble") || it.name.startsWith("bundle"))
    }
    if (releasing && !hasUploadKey) {
        logger.warn(
            "\n*** Baseline: no android/key.properties — this release is signed " +
                "with the DEBUG key and cannot be uploaded to Google Play. " +
                "See android/key.properties.example. ***\n"
        )
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
