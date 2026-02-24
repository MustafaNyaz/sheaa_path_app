#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Audio Players
-keep class xyz.luan.audioplayers.** { *; }

# Prevent R8 from stripping native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Ignore Play Store missing classes (Deferred Components not used)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

