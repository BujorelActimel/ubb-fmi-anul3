# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep Retrofit and Serialization classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class kotlin.Metadata { *; }

# Kotlinx Serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

-keep,includedescriptorclasses class com.traillogger.**$$serializer { *; }
-keepclassmembers class com.traillogger.** {
    *** Companion;
}
-keepclasseswithmembers class com.traillogger.** {
    kotlinx.serialization.KSerializer serializer(...);
}
