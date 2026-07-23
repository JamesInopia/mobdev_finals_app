import 'package:flutter/material.dart';
import 'package:mobdev_finals_app/ui/views/theme/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'package:mobdev_finals_app/ui/views/startup/settings_viewmodel.dart';

class SettingsPage extends StackedView<SettingsViewModel> {
  const SettingsPage({super.key});

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    if (!viewModel.isInitialized) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: AppColors.container,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: AppColors.containerStroke,
                  width: 1.5,
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ==================== Section 1: Appearance & UI ====================
                  _buildSectionTitle('Appearance & UI'),
                  const SizedBox(height: 12),
                  _buildSectionGroup([
                    _buildNavItem(context, 'Transitions'),
                    _buildNavItem(context, 'Time Format'),
                    _buildNavItem(context, 'Font & Font Size'),
                    _buildNavItem(context, 'Color palette'),
                    _buildNavItem(context, 'Language'),
                    _buildNavItem(context, 'Handedness'),
                  ]),

                  const SizedBox(height: 24),

                  // ==================== Section 2: Notifications ====================
                  _buildSectionTitle('Notifications'),
                  const SizedBox(height: 12),
                  _buildSectionGroup([
                    _buildNavItem(context, 'Scheduled Block Alerts'),
                    _buildNavItem(context, 'Time Limit Alerts'),
                    _buildSwitchItem(
                      'Block Start Alerts',
                      viewModel.blockStartAlerts,
                      viewModel.toggleBlockStartAlerts,
                    ),
                    _buildSwitchItem(
                      'Block End Alerts',
                      viewModel.blockEndAlerts,
                      viewModel.toggleBlockEndAlerts,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ==================== Section 3: General ====================
                  _buildSectionTitle('General'),
                  const SizedBox(height: 12),
                  _buildSectionGroup([
                    _buildSwitchItem(
                      'Enable Tooltips',
                      viewModel.enableTooltips,
                      viewModel.toggleEnableTooltips,
                    ),
                    _buildNavItem(context, 'Require Pin for Deletion'),
                    _buildNavItem(context, 'Clear List of Blocked Apps'),
                    _buildNavItem(context, 'Clear List of Blocked Sites'),
                    _buildNavItem(context, 'Clear List of Scheduled Timers'),
                    _buildNavItem(
                      context,
                      'Reset Settings to Default',
                      textColor: const Color(0xFFE53935),
                      iconColor: const Color(0xFFE53935),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) =>
      SettingsViewModel();

  /// Displays the "Feature coming soon!" popup
  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.container,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: AppColors.containerStroke,
              width: 1.5,
            ),
          ),
          title: const Text(
            'Feature coming soon!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'This setting is currently under development.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Back',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Section Title Text Widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  /// Container wrapper to handle inner indentation
  Widget _buildSectionGroup(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: children,
      ),
    );
  }

  /// Standard Chevron Navigation Item
  Widget _buildNavItem(
    BuildContext context,
    String title, {
    Color textColor = Colors.white70,
    Color iconColor = Colors.white70,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () => _showComingSoonDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white24,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: iconColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle Switch Item
  Widget _buildSwitchItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding:
          const EdgeInsets.only(left: 12.0, right: 0.0, top: 2.0, bottom: 2.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white24,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFFB085FF),
              inactiveThumbColor: Colors.white70,
              inactiveTrackColor: const Color(0xFF383253),
            ),
          ),
        ],
      ),
    );
  }
}
