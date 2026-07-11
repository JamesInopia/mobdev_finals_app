import 'package:flutter/services.dart';

// Mirrors what Kotlin sends back for each app
class InstalledApp {
  final String appName;
  final String packageName;
  final Uint8List icon; // raw PNG bytes we convert to an image widget

  const InstalledApp({
    required this.appName,
    required this.packageName,
    required this.icon,
  });
}

class AppFetcher {
  // Must exactly match the string in MainActivity.kt
  static const _channel = MethodChannel(
    'com.example.mobdev_finals_app/installed_apps',
  );

  static Future<List<InstalledApp>> getInstalledApps() async {
    // invokeMethod sends the call to Kotlin and waits for the result
    final List result = await _channel.invokeMethod('getInstalledApps');

    // Each item comes back as a Map — we convert it into an InstalledApp
    return result.map((item) {
      final map = Map<String, dynamic>.from(item);
      return InstalledApp(
        appName: map['appName'] as String,
        packageName: map['packageName'] as String,
        icon: map['icon'] as Uint8List,
      );
    }).toList();
  }
}