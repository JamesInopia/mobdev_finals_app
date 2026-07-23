import 'package:flutter/material.dart';
import 'package:mobdev_finals_app/ui/views/theme/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'app_templatemodel.dart';
import '../pages/page_settings.dart';
import '../pages/page_about.dart';
import '../pages/page_report.dart';

class MenuTabTemplate extends StackedView<FixedLayoutViewModel> {
  final int initialIndex;
  const MenuTabTemplate({super.key, this.initialIndex = 0});

  @override
  Widget builder(
      BuildContext context, FixedLayoutViewModel viewModel, Widget? child) {
    final titles = ["Settings", "About Us", "Provide Feedback"];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navigation,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          titles[viewModel.currentIndex],
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await Navigator.maybePop(context);
          },
        ),
      ),
      body: IndexedStack(
        index: viewModel.currentIndex,
        children: const [
          SettingsPage(),
          AboutPage(),
          ReportPage(),
        ],
      ),
    );
  }

  @override
  FixedLayoutViewModel viewModelBuilder(BuildContext context) =>
      FixedLayoutViewModel(initialIndex);
}
