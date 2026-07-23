import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class SettingsService with ListenableServiceMixin {
  // Preference Keys
  static const String _keyBlockStart = 'key_block_start_alerts';
  static const String _keyBlockEnd = 'key_block_end_alerts';
  static const String _keyEnableTooltips = 'key_enable_tooltips';

  // Reactive properties
  final _blockStartAlerts = ReactiveValue<bool>(true);
  final _blockEndAlerts = ReactiveValue<bool>(true);
  final _enableTooltips = ReactiveValue<bool>(false);
  final _isInitialized = ReactiveValue<bool>(false);

  // Public Getters
  bool get blockStartAlerts => _blockStartAlerts.value;
  bool get blockEndAlerts => _blockEndAlerts.value;
  bool get enableTooltips => _enableTooltips.value;
  bool get isInitialized => _isInitialized.value;

  SettingsService() {
    // Register reactive values so Stacked ViewModels listen automatically
    listenToReactiveValues([
      _blockStartAlerts,
      _blockEndAlerts,
      _enableTooltips,
      _isInitialized,
    ]);
    _loadFromDisk();
  }

  /// Initialize and load saved state from disk
  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    _blockStartAlerts.value = prefs.getBool(_keyBlockStart) ?? true;
    _blockEndAlerts.value = prefs.getBool(_keyBlockEnd) ?? true;
    _enableTooltips.value = prefs.getBool(_keyEnableTooltips) ?? false;
    _isInitialized.value = true;
  }

  /// Setters with disk persistence
  Future<void> setBlockStartAlerts(bool value) async {
    _blockStartAlerts.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBlockStart, value);
  }

  Future<void> setBlockEndAlerts(bool value) async {
    _blockEndAlerts.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBlockEnd, value);
  }

  Future<void> setEnableTooltips(bool value) async {
    _enableTooltips.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnableTooltips, value);
  }
}
