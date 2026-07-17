import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LinkStorageService {
  static const String _linksKey = 'my_saved_links_with_time';

  // Adds a new link with the current timestamp
  Future<void> addLink(String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawList = prefs.getStringList(_linksKey) ?? [];

    Map<String, String> newEntry = {
      'url': url,
      'timestamp': DateTime.now().toIso8601String(),
    };

    rawList.add(jsonEncode(newEntry));
    await prefs.setStringList(_linksKey, rawList);
  }

  // Retrieves all links and calculates the elapsed time
  Future<List<Map<String, dynamic>>> getLinks() async {
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

  // Removes a specific link by its URL
  Future<void> removeLink(String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawList = prefs.getStringList(_linksKey) ?? [];

    rawList.removeWhere((rawItem) {
      Map<String, dynamic> entry = jsonDecode(rawItem);
      return entry['url'] == url;
    });

    await prefs.setStringList(_linksKey, rawList);
  }

  // Checks if the database is entirely empty
  Future<bool> isDatabaseEmpty() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? rawList = prefs.getStringList(_linksKey);
    return rawList == null || rawList.isEmpty;
  }
}
