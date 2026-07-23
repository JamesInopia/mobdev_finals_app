import 'package:stacked/stacked.dart';
import 'package:mobdev_finals_app/app/app.locator.dart'; // Adjust path if using locator
import 'package:mobdev_finals_app/services/settings_service.dart';

class SettingsViewModel extends ReactiveViewModel {
  final _settingsService = locator<SettingsService>();

  // Register service so ViewModel re-renders on any setting change
  @override
  List<ListenableServiceMixin> get listenableServices => [_settingsService];

  bool get isInitialized => _settingsService.isInitialized;
  bool get blockStartAlerts => _settingsService.blockStartAlerts;
  bool get blockEndAlerts => _settingsService.blockEndAlerts;
  bool get enableTooltips => _settingsService.enableTooltips;

  void toggleBlockStartAlerts(bool val) =>
      _settingsService.setBlockStartAlerts(val);
  void toggleBlockEndAlerts(bool val) =>
      _settingsService.setBlockEndAlerts(val);
  void toggleEnableTooltips(bool val) =>
      _settingsService.setEnableTooltips(val);
}
