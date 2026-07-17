package com.example.mobdev_finals_app;

import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.provider.Settings;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.example.mobdev_finals_app/installed_apps";

    // Prefixes of packages that should never appear in the app picker
    private static final List<String> SYSTEM_PACKAGE_PREFIXES = Arrays.asList(
        "com.example.mobdev_finals_app",
        "com.google.android",
        "com.google",
        "com.android",
        "com.nothing"
    );

    // Apps that still show on app blocker even if they match a blocked prefix (namely youtube and gmail)
    private static final Set<String> ALLOWED_PACKAGES = new HashSet<>(Arrays.asList(
    "com.google.android.youtube",
    "com.google.android.gm"
    ));

    // Keywords that suggest a package is a background service, not a user app
    private static final List<String> SYSTEM_KEYWORDS = Arrays.asList(
        "intelligence",
        "webview",
        "compute",
        "verifier",
        "config",
        "safety core",
        "private compute",
        "device health",
        "carrier services",
        "print spooler"
    );

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "getInstalledApps":
                        result.success(getInstalledApps());
                        break;
                    case "isAccessibilityEnabled":
                        result.success(isAccessibilityEnabled());
                        break;
                    case "openAccessibilitySettings":
                        openAccessibilitySettings();
                        result.success(null);
                        break;
                    case "updateBlockedApps":
                        List<String> packages = call.argument("packages");
                        if (packages == null) packages = new ArrayList<>();
                        updateBlockedApps(packages);
                        result.success(null);
                        break;
                    case "getBlockedApps":
                        result.success(getBlockedApps());
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            });
    }

    // Checks whether our accessibility service is currently enabled in Settings
    private boolean isAccessibilityEnabled() {
        String expectedService = getPackageName() + "/" +
            BlockerAccessibilityService.class.getCanonicalName();
        String enabledServices = Settings.Secure.getString(
            getContentResolver(),
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        );
        if (enabledServices == null) return false;
        // Accessibility services are stored as a colon-separated string
        for (String service : enabledServices.split(":")) {
            if (service.equalsIgnoreCase(expectedService)) return true;
        }
        return false;
    }

    // Opens Android's Accessibility Settings screen directly
    private void openAccessibilitySettings() {
        Intent intent = new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    // Writes the blocked package list to SharedPreferences so the
    // accessibility service can read it without a MethodChannel
    private void updateBlockedApps(List<String> packages) {
        getSharedPreferences("blocker_prefs", MODE_PRIVATE)
            .edit()
            .putString("blocked_packages", android.text.TextUtils.join(",", packages))
            .apply();
    }

    private List<Map<String, Object>> getBlockedApps() {
        String saved = getSharedPreferences("blocker_prefs", MODE_PRIVATE).getString("blocked_packages", "");

        List<Map<String, Object>> apps = new ArrayList<>();
        if(saved.isEmpty()) {
            return apps;
        }

        PackageManager pm = getPackageManager();
        for(String packageName : saved.split(",")) {
            try {
                // get the app's info then use it to get its name and icon
                ApplicationInfo appInfo = pm.getApplicationInfo(packageName, 0);
                String appName = pm.getApplicationLabel(appInfo).toString();
                Drawable appIcon = pm.getApplicationIcon(appInfo);

                // convert the Drawable icon into a Bitmap icon
                Bitmap bitmap = drawableToBitmap(appIcon);
                ByteArrayOutputStream stream = new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);

                Map<String, Object> map = new HashMap<>();
                map.put("appName", appName);
                map.put("packageName", packageName);
                map.put("icon", stream.toByteArray());
                apps.add(map);
            } catch(PackageManager.NameNotFoundException e) {
                // skip uninstalled apps that were also blocked
            }
        }
        return apps;
    }

    private Bitmap drawableToBitmap(Drawable drawable) {
        if(drawable instanceof BitmapDrawable) {
            return ((BitmapDrawable) drawable).getBitmap();
        }

        Bitmap bitmap = Bitmap.createBitmap(
            drawable.getIntrinsicWidth(),
            drawable.getIntrinsicHeight(),
            Bitmap.Config.ARGB_8888
        );

        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        
        return bitmap;
    }

    private List<Map<String, Object>> getInstalledApps() {
        PackageManager pm = getPackageManager();
        List<PackageInfo> allPackages;

        // Android 13+ requires the new PackageInfoFlags API
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            allPackages = pm.getInstalledPackages(
                PackageManager.PackageInfoFlags.of(PackageManager.GET_META_DATA)
            );
        } else {
            allPackages = pm.getInstalledPackages(PackageManager.GET_META_DATA);
        }

        List<Map<String, Object>> result = new ArrayList<>();

        for (PackageInfo packageInfo : allPackages) {
            try {
                String packageName = packageInfo.packageName;
                ApplicationInfo appInfo = packageInfo.applicationInfo;

                if (appInfo == null) continue;

                // Skip if in the critical blocklist
                if (isSystemPrefix(packageName)) continue;

                // Must have a launch intent — background services don't
                Intent launchIntent = pm.getLaunchIntentForPackage(packageName);
                if (launchIntent == null) continue;

                boolean isUserInstalled =
                    (appInfo.flags & ApplicationInfo.FLAG_SYSTEM) == 0;
                boolean isUpdatedSystemApp =
                    (appInfo.flags & ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0;

                // Pure user installed apps always pass
                // Updated system apps pass only if label doesn't look like a service
                if (!isUserInstalled && isUpdatedSystemApp) {
                    String label = pm.getApplicationLabel(appInfo).toString().toLowerCase();
                    if (hasSystemKeyword(label)) continue;
                } else if (!isUserInstalled) {
                    // System app with no update — skip
                    continue;
                }

                String label = pm.getApplicationLabel(appInfo).toString();

                // Skip apps whose label is just their package name — usually services
                if (label.equals(packageName) || label.trim().isEmpty()) continue;

                // Convert the app icon to PNG bytes to send across the MethodChannel
                Drawable icon = pm.getApplicationIcon(packageName);
                int width  = icon.getIntrinsicWidth()  > 0 ? icon.getIntrinsicWidth()  : 48;
                int height = icon.getIntrinsicHeight() > 0 ? icon.getIntrinsicHeight() : 48;

                Bitmap bitmap = android.graphics.Bitmap.createBitmap(
                    width, height, android.graphics.Bitmap.Config.ARGB_8888
                );
                Canvas canvas = new android.graphics.Canvas(bitmap);
                icon.setBounds(0, 0, width, height);
                icon.draw(canvas);

                ByteArrayOutputStream stream = new ByteArrayOutputStream();
                bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream);

                Map<String, Object> appMap = new HashMap<>();
                appMap.put("appName",     label);
                appMap.put("packageName", packageName);
                appMap.put("icon",        stream.toByteArray());

                result.add(appMap);

            } catch (Exception e) {
                // Skip any app that throws — malformed packages can cause errors
            }
        }

        // Sort alphabetically by app name
        result.sort((a, b) -> {
            String nameA = (String) a.get("appName");
            String nameB = (String) b.get("appName");
            if (nameA == null) return 1;
            if (nameB == null) return -1;
            return nameA.compareToIgnoreCase(nameB);
        });

        return result;
    }

    // Checks if a package name starts with any of our blocked prefixes
    private boolean isSystemPrefix(String packageName) {
    // Whitelist takes priority — always allow these through
    if (ALLOWED_PACKAGES.contains(packageName)) return false;

    // Then check the blocklist
    for (String prefix : SYSTEM_PACKAGE_PREFIXES) {
        if (packageName.startsWith(prefix)) return true;
    }
    return false;
    }

    // Checks if an app label contains any system service keywords
    private boolean hasSystemKeyword(String label) {
        for (String keyword : SYSTEM_KEYWORDS) {
            if (label.contains(keyword)) return true;
        }
        return false;
    }
}