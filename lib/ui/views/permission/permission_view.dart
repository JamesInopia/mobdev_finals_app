import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import '../theme/app_colors.dart';
import 'permission_viewmodel.dart';

class PermissionView extends StackedView<PermissionViewModel> {
  const PermissionView({Key? key}) : super(key: key);

  @override
  Widget builder(
      BuildContext context, PermissionViewModel viewModel, Widget? child) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.appBG),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),

                Icon(
                  Icons.accessibility_new,
                  size: screenWidth * 0.25,
                  color: AppColors.accent1,
                ),
                SizedBox(height: screenHeight * 0.04),

                Text(
                  'One Permission Needed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.065,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                Text(
                  'To block apps, FocusGuard needs Accessibility access. '
                  'This lets it detect when a blocked app is opened and redirect you back.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: screenWidth * 0.038,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                _PermissionStep(
                  number: '1',
                  text: 'Tap the button below to open Accessibility Settings',
                ),
                SizedBox(height: screenHeight * 0.018),
                _PermissionStep(
                  number: '2',
                  text: 'Find "FocusGuard Blocker" under Installed Services',
                ),
                SizedBox(height: screenHeight * 0.018),
                _PermissionStep(
                  number: '3',
                  text: 'Toggle it on and tap Allow on the confirmation prompt',
                ),
                SizedBox(height: screenHeight * 0.018),
                _PermissionStep(
                  number: '4',
                  text: 'Come back here — the app will continue automatically',
                ),

                const Spacer(flex: 2),

                SizedBox(
                  height: screenHeight * 0.065,
                  child: ElevatedButton.icon(
                    onPressed: viewModel.openAccessibilitySettings,
                    icon: const Icon(Icons.settings_accessibility),
                    label: const Text(
                      'Open Accessibility Settings',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent1,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // In case auto-detection misses the resume
                TextButton(
                  onPressed: viewModel.checkAndProceed,
                  child: Text(
                    'I already enabled it — continue',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  PermissionViewModel viewModelBuilder(BuildContext context) =>
      PermissionViewModel();

  @override
  void onViewModelReady(PermissionViewModel viewModel) =>
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => viewModel.init(),
      );
}

class _PermissionStep extends StatelessWidget {
  final String number;
  final String text;

  const _PermissionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.accent3,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: AppColors.accent1,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white70,
                fontSize: screenWidth * 0.037,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}