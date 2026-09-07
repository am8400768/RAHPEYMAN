plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load release signing config from android/key.properties if it exists.
// Create the file from key.properties.example and NEVER commit it (see .gitignore).
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.withReader { reader ->
        keystoreProperties.load(reader)
    }
}

android {
    namespace = "ir.rahpeyman.app"

    compileSdk = 36

    buildToolsVersion = "36.0.0"

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "ir.rahpeyman.app"

        minSdk = flutter.minSdkVersion

        targetSdk = 36

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            release {
                keyAlias = keystoreProperties["keyAlias"]
                keyPassword = keystoreProperties["keyPassword"]
                storeFile = file(keystoreProperties["storeFile"])
                storePassword = keystoreProperties["storePassword"]
            }
        }
    }

    buildTypes {
        release {
            // Use the real release keystore when key.properties exists,
            // otherwise fall back to debug signing so local builds still work.
            signingConfig = keystorePropertiesFile.exists()
                ? signingConfigs.getByName("release")
                : signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("com.google.android.play:integrity:1.6.0")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
