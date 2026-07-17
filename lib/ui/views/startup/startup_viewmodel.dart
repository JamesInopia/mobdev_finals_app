import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:mobdev_finals_app/app/app.locator.dart';
import 'package:mobdev_finals_app/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  static const _channel = MethodChannel(
    'com.example.mobdev_finals_app/installed_apps',
  );

  Future runStartupLogic() async {
    await Future.delayed(const Duration(seconds: 2));

    final bool accessibilityEnabled = await _checkAccessibility();

    if (accessibilityEnabled) {
      // Permission already granted — go straight to the main app
      _navigationService.replaceWithFixedLayoutView();
    } else {
      // Permission not granted — show the permission screen first
      _navigationService.replaceWithPermissionView();
    }
  }

  Future<bool> _checkAccessibility() async {
    try {
      final bool result =
          await _channel.invokeMethod('isAccessibilityEnabled');
      return result;
    } catch (_) {
      // If the channel call fails for any reason, default to false
      // so the user is always prompted rather than silently skipping
      return false;
    }
  }
}