import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.github.triplet.play") version "3.13.0"
}

// ===== KEYSTORE O‘QISH =====
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "uz.voiplay.tv"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "uz.voiplay.tv"
        minSdk = 24
        minSdkVersion 24  // 23 dan 24 ga ko'taring
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 16KB alignment uchun Native Linker flaglari
        externalNativeBuild {
            cmake {
                cppFlags("-Wl,-z,max-page-size=16384")
            }
            ndkBuild {
                arguments("APP_LDFLAGS+=-Wl,-z,max-page-size=16384")
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        jvmToolchain(17)
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file("my-release-key.jks")
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            ndk {
                debugSymbolLevel = "FULL"
            }
            isDebuggable = false
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    lint {
        abortOnError = false
        checkReleaseBuilds = false
        disable.add("DuplicatePlatformClasses")
    }

    // ===== PACKAGING =====
    packaging {
        jniLibs {
            useLegacyPackaging = true // 16KB alignment uchun
            keepDebugSymbols.add("**/*.so")
        }
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0",
                "META-INF/DEPENDENCIES.txt",
                "META-INF/beans.xml"
            )
        }
    }
}

play {
    val saFile = rootProject.file("play-service-account.json")
    if (saFile.exists()) {
        serviceAccountCredentials.set(saFile)
    }

    defaultToAppBundles.set(true)
    track.set("internal")
}

dependencies {
    implementation("com.google.errorprone:error_prone_annotations:2.21.0")
    implementation("javax.annotation:javax.annotation-api:1.3.2")

    implementation("com.google.api-client:google-api-client:1.35.0") {
        exclude(group = "commons-logging", module = "commons-logging")
        exclude(group = "org.apache.httpcomponents", module = "httpclient")
    }

    implementation("com.google.http-client:google-http-client-android:1.43.3")
    implementation("joda-time:joda-time:2.12.5")
}
