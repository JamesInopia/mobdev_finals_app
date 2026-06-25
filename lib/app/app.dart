import 'package:mobdev_finals_app/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:mobdev_finals_app/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:mobdev_finals_app/ui/views/template/app_template.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// @stacked-import
@StackedApp(
  routes: [
    MaterialRoute(page: FixedLayoutView, initial: true),
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
  ],
)
class App {}
