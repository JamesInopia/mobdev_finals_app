// only logout function in the future
import 'package:stacked/stacked.dart';

class FixedLayoutViewModel extends BaseViewModel {
  int currentIndex;

  FixedLayoutViewModel(this.currentIndex);

  void setIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
