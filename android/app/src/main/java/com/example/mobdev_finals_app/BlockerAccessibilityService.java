package com.example.mobdev_finals_app;

import android.accessibilityservice.AccessibilityService;
import android.accessibilityservice.AccessibilityServiceInfo;
import android.content.Intent;
import android.content.SharedPreferences;
import android.view.accessibility.AccessibilityEvent;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class BlockerAccessibilityService extends AccessibilityService {

    private SharedPreferences prefs;

    // Packages that should never trigger a block regardless of the blocked list
    private static final Set<String> NEVER_BLOCK_PACKAGES = new HashSet<>(Arrays.asList(
        "com.google.android.googlequicksearchbox",
        "com.nothing.launcher",
        "com.android.launcher",
        "com.google.android.apps.nexuslauncher",
        "com.android.home",
        "com.example.mobdev_finals_app"
    ));

    @Override
    protected void onServiceConnected() {
        super.onServiceConnected();

        // Get shared preferences where Flutter writes the blocked list
        prefs = getSharedPreferences("blocker_prefs", MODE_PRIVATE);

        // Configure which events we want to receive
        AccessibilityServiceInfo info = new AccessibilityServiceInfo();
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED;
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC;
        info.flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS;
        setServiceInfo(info);
    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event == null) return;
        if (event.getEventType() != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return;

        CharSequence packageNameChar = event.getPackageName();
        if (packageNameChar == null) return;
        String foregroundPackage = packageNameChar.toString();

        // Never block our own app or any launcher
        if (NEVER_BLOCK_PACKAGES.contains(foregroundPackage)) return;
        if (foregroundPackage.contains("launcher")) return;
        if (foregroundPackage.contains("home")) return;

        // Read the blocked list — stored as comma separated string by Flutter
        String blockedRaw = prefs.getString("blocked_packages", "");
        if (blockedRaw == null || blockedRaw.isEmpty()) return;

        // Check if the foreground app is in the blocked list
        String[] blockedPackages = blockedRaw.split(",");
        for (String blocked : blockedPackages) {
            if (blocked.trim().equals(foregroundPackage)) {
                // App is blocked — launch our app on top of it
                Intent intent = new Intent(this, MainActivity.class);
                intent.setFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK |
                    Intent.FLAG_ACTIVITY_CLEAR_TOP |
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
                );
                // Pass the blocked package so Flutter knows what triggered it
                intent.putExtra("blocked_package", foregroundPackage);
                startActivity(intent);
                return;
            }
        }
    }

    @Override
    public void onInterrupt() {
        // Required override — called when the service is interrupted
    }
}