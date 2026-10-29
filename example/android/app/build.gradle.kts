import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val minSdkVersion = 24
val targetSdkVersion = 35

val agpVersion = "8.13.2"
val multidexVersion = "2.0.1"
val firebaseVersion = "23.0.0"
val agconnectVersion = "1.9.1.300"
val hmsVersion = "6.11.0.300"
val rsmVersion = "7.2.0"
val gsonVersion = "2.10.1"

android {
    namespace = "com.sendsay.example_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.sendsay.example_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
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

    flavorDimensions.add("service")
    productFlavors {
        create("fcm") {
            dimension = "service"
//            applicationId = "com.sendsay.example_flutter"
//            buildConfigField("String", "1", "\"2\"")
        }
        create("hms") {
            dimension = "service"
//            applicationId = "com.sendsay.example_flutter_hms"
//            buildConfigField("String", "qa1", "\"2 Test\"")
        }
        create("rsm") {
            dimension = "service"
//            applicationId = "com.sendsay.example_flutter_rsm"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_11
    }
}

flutter {
    source = "../.."
}


dependencies {
    implementation("com.squareup.okhttp3:okhttp:4.9.3")
    implementation("com.google.code.gson:gson:$gsonVersion")

    fcmImplementation("com.google.firebase:firebase-messaging:$firebaseVersion")
    hmsImplementation("com.huawei.agconnect:agconnect-core:$agconnectVersion")
    hmsImplementation("com.huawei.hms:push:$hmsVersion")
    rsmImplementation("ru.rustore.sdk:pushclient:$rsmVersion")

    // libraries to avoid specific crashes on Android 12L devices
//    implementation "androidx.window:window:1.3.0"
//    implementation "androidx.window:window-java:1.3.0"
    // https://stackoverflow.com/a/78343911
//    implementation "androidx.work:work-runtime:2.8.1"
//    implementation "androidx.work:work-runtime-ktx:2.8.1"
//    implementation "androidx.compose.runtime:runtime:1.7.8"

    // tests :
    testImplementation("junit:junit:4.12")
//    testImplementation "ru.sendsay.sdk:sdk:$sendsaySdkVersion"
//    testImplementation project(":sdk")
//    testImplementation(files("../../sdk"))
    testImplementation("com.google.code.gson:gson:$gsonVersion")

//    implementation "androidx.support:support-v4:28.0.0"
}


if (gradle.startParameter.taskRequests.toString().lowercase().contains("fcm")) {
    apply(plugin = "com.google.gms.google-services")
}
if (gradle.startParameter.taskRequests.toString().lowercase().contains("hms")) {
    apply(plugin = "com.huawei.agconnect")
}

// extentions over
fun org.gradle.api.artifacts.dsl.DependencyHandler.fcmImplementation(dep: Any) {
    add("fcmImplementation", dep)
}
fun org.gradle.api.artifacts.dsl.DependencyHandler.hmsImplementation(dep: Any) {
    add("hmsImplementation", dep)
}
fun org.gradle.api.artifacts.dsl.DependencyHandler.rsmImplementation(dep: Any) {
    add("rsmImplementation", dep)
}
