plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") 
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

}

android {
    namespace = "com.example.engenharia_de_software"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // <<< CORREÇÃO AQUI: Note o "is" no começo.
        isCoreLibraryDesugaringEnabled = true 

        // Suas configurações de Java 11 permanecem
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.engenharia_de_software"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Esta linha adiciona a biblioteca que faz o "desugaring" funcionar
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Import the BoM for the Firebase platform
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
    
    implementation("com.google.firebase:firebase-analytics")

    // Add the dependencies for the App Check libraries
    // When using the BoM, you don't specify versions in Firebase library dependencies
    implementation("com.google.firebase:firebase-appcheck-debug")


}