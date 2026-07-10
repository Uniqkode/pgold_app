# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Play Core (optional, used by Flutter deferred components)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Google Play Services
-keep class com.google.android.gms.** { *; }

# Keep MobX generated classes
-keep class **.*_$* { *; }
-keep class * implements dart.core.* { *; }

# SharedPreferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# GoRouter navigation state
-keep class * extends com.example.** { *; }

# Keep enum values (ReportReason)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep model classes (JSON serialization)
-keep class com.pgold.** { *; }
