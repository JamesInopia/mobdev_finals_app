import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:mobdev_finals_app/app/app.locator.dart';
import 'package:mobdev_finals_app/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/widgets.dart';

class PermissionViewModel extends BaseViewModel with WidgetsBindingObserver {
  final _navigationService = locator<NavigationService>();

  static const _channel = MethodChannel(
    'com.example.mobdev_finals_app/installed_apps',
  );

  void init() {
    // Start listening for app lifecycle changes —
    // when user comes back from Settings we check automatically
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Fires every time the app is resumed from background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAndProceed();
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  Future<void> checkAndProceed() async {
    try {
      final bool enabled =
          await _channel.invokeMethod('isAccessibilityEnabled');
      if (enabled) {
        _navigationService.replaceWithFixedLayoutView();
      }
    } catch (_) {}
  }
}