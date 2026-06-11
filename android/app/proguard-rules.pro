# Mantener información genérica
-keepattributes Signature

# Mantener anotaciones
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations

# Gson
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }