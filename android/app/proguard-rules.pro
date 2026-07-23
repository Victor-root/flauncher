## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication

## Shizuku user service (instantiated by name in a separate privileged process)
-keep class me.efesser.flauncher.UserService { *; }
-keep interface me.efesser.flauncher.IUserService { *; }
-keep class me.efesser.flauncher.IUserService$Stub { *; }