import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Local credentials stay in ignored key.properties; CI supplies environment values.
val signingProperties = Properties().apply {
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.isFile) propertiesFile.inputStream().use { load(it) }
}
val releaseKeystorePath = providers.environmentVariable("RELEASE_KEYSTORE_PATH").orNull
    ?: signingProperties.getProperty("storeFile")
val releaseKeystorePassword = providers.environmentVariable("RELEASE_KEYSTORE_PASSWORD").orNull
    ?: signingProperties.getProperty("storePassword")
if (providers.environmentVariable("CI").orNull == "true") {
    require(!releaseKeystorePath.isNullOrBlank() && !releaseKeystorePassword.isNullOrBlank()) {
        "CI requires RELEASE_KEYSTORE_PATH and RELEASE_KEYSTORE_PASSWORD."
    }
}

android {
    namespace = "com.example.control_financiero"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    flavorDimensions += "env"

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Mi Presupuesto DEV")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Mi Presupuesto")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.control_financiero"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        missingDimensionStrategy("env", "dev")
    }

    signingConfigs {
        create("release") {
            storeFile = releaseKeystorePath?.let { file(it) }
            storeType = "PKCS12"
            storePassword = releaseKeystorePassword
            keyAlias = "mi-presupuesto"
            keyPassword = releaseKeystorePassword
        }
    }

    buildTypes {
        debug {
            // Enable debug-specific options here.
        }
        release {
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
