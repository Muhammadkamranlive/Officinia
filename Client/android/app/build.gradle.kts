plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // ✅ FINAL & PROFESSIONAL PACKAGE
    namespace = "com.autosoftapps.officina"

    // ✅ REQUIRED BY PLAY STORE (2026)
    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Best balance for performance + compatibility
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // Required for modern APIs on old devices
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        // ⚠️ CANNOT CHANGE AFTER PUBLISH
        applicationId = "com.autosoftapps.officina"

        // ✅ OLD + NEW DEVICE SUPPORT
        // Android 7.0 (2016) → still HUGE user base
        minSdk = 24

        // ✅ MANDATORY (Android 15)
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // OK for first upload only
            signingConfig = signingConfigs.getByName("debug")

             // ✅ Kotlin DSL requires '='
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    // Java 8+ support on old Android
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )
}

flutter {
    source = "../.."
}
