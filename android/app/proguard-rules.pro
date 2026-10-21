# Keep WorkManager database classes from being stripped/obfuscated in release builds
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class * extends androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# Keep Room database and SQLite
-keep class androidx.room.** { *; }
-dontwarn androidx.room.**
-keep class androidx.sqlite.** { *; }
-dontwarn androidx.sqlite.**

# Keep AndroidX Startup
-keep class androidx.startup.** { *; }

# Keep Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Keep Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
