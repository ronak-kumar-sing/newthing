# Anchor ProGuard Rules
# Keep Flutter plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Drift/SQLite
-keep class com.drift.** { *; }
-keep class sqlite3.** { *; }

# Keep Riverpod
-keep class flutter_riverpod.** { *; }

# Keep Notification plugin
-keep class com.dexterous.** { *; }

# Keep Google Fonts
-keep class com.google.fonts.** { *; }

# Keep permission handler
-keep class com.baseflow.** { *; }

# Keep MainActivity and widgets
-keep class com.example.anchor.MainActivity { *; }
-keep class com.example.anchor.widgets.** { *; }

# Keep WorkManager
-keep class androidx.work.** { *; }
-keep class be.wils.gerrit.flutter_workmanager.** { *; }

# Don't warn about missing Play Core classes (deferred components not used)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
