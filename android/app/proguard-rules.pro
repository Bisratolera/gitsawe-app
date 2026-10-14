# --- Flutter ---------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn com.google.android.play.core.**

# --- flutter_local_notifications (uses Gson reflection for scheduled payloads)
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# --- just_audio / audio_service / just_audio_background --------------------
-keep class com.ryanheise.** { *; }
-dontwarn com.ryanheise.**
-keep class androidx.media.** { *; }
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# --- home_widget + our AppWidgetProviders (referenced from the manifest) ---
-keep class es.antonborri.home_widget.** { *; }
-keep class com.gitsawe.app.** { *; }
