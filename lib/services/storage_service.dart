import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _linksKey = 'my_saved_links_with_time';

// ==========================================
// 1. DATA STORAGE FUNCTIONS (Step 1)
// ==========================================

Future<void> addLinkToList(String url) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> rawList = prefs.getStringList(_linksKey) ?? [];

  Map<String, String> newEntry = {
    'url': url,
    'timestamp': DateTime.now().toIso8601String(),
  };

  rawList.add(jsonEncode(newEntry));
  await prefs.setStringList(_linksKey, rawList);
}

Future<List<Map<String, dynamic>>> getLinksList() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> rawList = prefs.getStringList(_linksKey) ?? [];

  List<Map<String, dynamic>> structuredLinks = [];
  DateTime now = DateTime.now();

  for (String rawItem in rawList) {
    Map<String, dynamic> entry = jsonDecode(rawItem);
    DateTime savedTime = DateTime.parse(entry['timestamp']);
    Duration difference = now.difference(savedTime);

    structuredLinks.add({
      'url': entry['url'],
      'elapsed': difference,
    });
  }

  return structuredLinks;
}

Future<void> removeLinkFromList(String url) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> rawList = prefs.getStringList(_linksKey) ?? [];

  rawList.removeWhere((rawItem) {
    Map<String, dynamic> entry = jsonDecode(rawItem);
    return entry['url'] == url;
  });

  await prefs.setStringList(_linksKey, rawList);
}

// ==========================================
// 2. UI FORMATTING UTILITY (Step 2)
// ==========================================

String formatElapsedTime(Duration duration) {
  // 1. Calculate values from largest units down to smallest units
  int years = (duration.inDays / 365).floor();
  int months = ((duration.inDays % 365) / 30).floor();
  int days = (duration.inDays % 30);
  int hours = duration.inHours.remainder(24);
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);

  // 2. HIGHEST UNIT LOGIC CHECK (Stops at the first match going down the chain)

  // Year Check
  if (years >= 1) {
    return "$years ${years == 1 ? 'Year' : 'Years'}";
  }

  // Month Check
  if (months >= 1) {
    return "$months ${months == 1 ? 'Month' : 'Months'}";
  }

  // Day Check
  if (days >= 1) {
    return "$days ${days == 1 ? 'Day' : 'Days'}";
  }

  // Hour Check
  if (hours >= 1) {
    return "$hours ${hours == 1 ? 'Hour' : 'Hours'}";
  }

  // Minute Check
  if (minutes >= 1) {
    return "$minutes ${minutes == 1 ? 'Minute' : 'Minutes'}";
  }

  // Default Fallback (Seconds)
  return "$seconds ${seconds == 1 ? 'Second' : 'Seconds'}";
}

// 3. HARD-CODED DATA INITIALIZER
Future<void> seedHardCodedData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Only add data if storage is currently empty so you don't overwrite user changes
  if (prefs.getStringList(_linksKey) == null) {
    List<String> hardCodedList = [
      jsonEncode({
        'url': 'https://flutter.dev',
        // Sets the time to exactly 3 days, 4 hours, and 10 minutes ago
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 3, hours: 4, minutes: 10))
            .toIso8601String(),
      }),
      jsonEncode({
        'url': 'https://pub.dev',
        // Sets the time to exactly 12 hours ago
        'timestamp': DateTime.now()
            .subtract(const Duration(hours: 12))
            .toIso8601String(),
      }),
      jsonEncode({
        'url': 'https://github.com',
        // Sets the time to right now (0 seconds elapsed)
        'timestamp': DateTime.now().toIso8601String(),
      }),
    ];

    // Save your hard-coded list to storage
    await prefs.setStringList(_linksKey, hardCodedList);
  }
}
