import 'package:mobdev_finals_app/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:mobdev_finals_app/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:mobdev_finals_app/ui/views/template/app_template.dart';
import 'package:mobdev_finals_app/ui/views/startup/startup_view.dart';
// ADD THIS — adjust the path to match where you put permission_view.dart
import 'package:mobdev_finals_app/ui/views/permission/permission_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mobdev_finals_app/services/settings_service.dart';

// @stacked-import
@StackedApp(
  routes: [
    MaterialRoute(
        page: StartupView, initial: true), // ← make startup the initial route
    MaterialRoute(page: FixedLayoutView),
    MaterialRoute(page: PermissionView), // ← add this
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SettingsService),
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
  ],
)
class App {}
