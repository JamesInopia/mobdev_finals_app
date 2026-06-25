import 'package:stacked/stacked.dart';
import 'package:mobdev_finals_app/app/app.locator.dart';
import 'package:mobdev_finals_app/app/app.bottomsheets.dart';
import 'package:mobdev_finals_app/ui/common/app_strings.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  int _counter = 0;
  String get counterLabel => 'Counter is: $_counter';

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  void showBottomSheet() {
    final bottomSheetService = locator<BottomSheetService>();
    bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }
}
