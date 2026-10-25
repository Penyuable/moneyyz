# Keep ML Kit text recognition
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.vision.text.**

# Keep Supabase & other plugins
-keep class io.supabase.** { *; }
-keepattributes *Annotation*
