// template for settings and about page
import 'package:flutter/material.dart';
import 'package:mobdev_finals_app/ui/views/theme/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'app_templatemodel.dart';
import '../pages/page_settings.dart';
import '../pages/page_about.dart';
import '../pages/page_report.dart';
import 'package:mobdev_finals_app/ui/common/app_colors.dart';

class MenuTabTemplate extends StackedView<FixedLayoutViewModel> {
  final int initialIndex;
  const MenuTabTemplate({super.key, this.initialIndex = 0});

  @override
  Widget builder(
      BuildContext context, FixedLayoutViewModel viewModel, Widget? child) {
    final titles = ["Settings", "About", "Report a Problem"];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navigation,
        title: Text(
          titles[viewModel.currentIndex],
          style: const TextStyle(
            color: Colors.white, // Put your desired color here
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
