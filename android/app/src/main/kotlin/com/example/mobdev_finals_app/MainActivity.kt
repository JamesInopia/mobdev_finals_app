package com.example.mobdev_finals_app

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // This string is the identifier — Dart and Kotlin must use the exact same one
    private val CHANNEL = "com.example.mobdev_finals_app/installed_apps"

    private val systemPackagePrefixes = listOf(
    "com.android.settings",
    "com.android.vending",
    "com.android.angle",
    "com.android.phone",
    "com.android.dialer",
    "com.android.contacts",
    "com.android.mms",
    "com.android.launcher",
    "com.android.systemui",
    "com.android.traceur",        // system tracing tool
    "com.android.stk",            // SIM toolkit
    "com.google.android.gms",
    "com.google.android.gsf",
    "com.google.android.inputmethod",
    "com.google.android.packageinstaller",
    "com.nothing.launcher",       // Nothing launcher
    "com.nothing.proxy",
    "com.example.mobdev_finals_app", // your own app
)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getInstalledApps") {
                    result.success(getInstalledApps())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
    val pm = packageManager

    // Query all activities that respond to the MAIN action and LAUNCHER category
    // This is how the home screen finds apps — more reliable than getLaunchIntentForPackage
    val mainIntent = android.content.Intent(android.content.Intent.ACTION_MAIN).also {
        it.addCategory(android.content.Intent.CATEGORY_LAUNCHER)
    }

    // queryIntentActivities finds every app that can appear on the home screen
    val launchableApps = pm.queryIntentActivities(mainIntent, 0)
        .map { it.activityInfo.packageName }
        .toSet() // toSet() removes duplicates since some apps have multiple launcher activities

    return launchableApps
        .filter { packageName ->
            val isNotCritical = systemPackagePrefixes.none { prefix ->
                packageName.startsWith(prefix)
            }
            isNotCritical
        }
        .mapNotNull { packageName ->
            try {
                val appInfo = pm.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
                val label = pm.getApplicationLabel(appInfo).toString()

                val icon = pm.getApplicationIcon(packageName)
                val bitmap = android.graphics.Bitmap.createBitmap(
                    icon.intrinsicWidth, icon.intrinsicHeight,
                    android.graphics.Bitmap.Config.ARGB_8888
                )
                val canvas = android.graphics.Canvas(bitmap)
                icon.setBounds(0, 0, canvas.width, canvas.height)
                icon.draw(canvas)

                val stream = java.io.ByteArrayOutputStream()
                bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
                val iconBytes = stream.toByteArray()

                mapOf(
                    "appName" to label,
                    "packageName" to packageName,
                    "icon" to iconBytes
                )
            } catch (e: Exception) {
                null
            }
        }
        .sortedBy { it["appName"] as String }
}
}