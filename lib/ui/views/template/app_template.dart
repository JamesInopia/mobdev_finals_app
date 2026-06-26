// appbar, bottomnav, page switcher
import 'package:flutter/material.dart';
import 'package:mobdev_finals_app/ui/views/theme/app_colors.dart';
import 'package:stacked/stacked.dart';
import 'app_templatemodel.dart';
import '../pages/page_home.dart';
import '../pages/page_blocker.dart';
import '../pages/page_about.dart';
import 'package:mobdev_finals_app/ui/common/app_colors.dart';

class FixedLayoutView extends StackedView<FixedLayoutViewModel> {
  const FixedLayoutView({super.key});

  @override
  Widget builder(
    BuildContext context,
    FixedLayoutViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navigation,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.accent3,
        child: ListView(
          padding: const EdgeInsets.only(top: 30, left: 5, right: 5),
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                listTileTheme: const ListTileThemeData(
                  textColor: Colors.white,
                ),
              ),
              child: Column(
                children: const [
                  ListTile(title: Text('Settings')),
                  ListTile(title: Text('About')),
                  ListTile(title: Text('Privacy')),
                  ListTile(title: Text('Report a Problem')),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: viewModel.currentIndex,
        children: const [
          HomePage(), // index = 0
          BlockerPage(), // index = 1
          AboutPage(), // index = 2
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.navigation,
        child: SafeArea(
          bottom: true,
          child: Container(
            color: AppColors.navigation,
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.001,
                horizontal: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home,
                    label: 'Home',
                    selected: viewModel.currentIndex == 0,
                    onTap: () => viewModel.setIndex(0),
                  ),
                  _NavItem(
                    icon: Icons.lock,
                    label: 'Blocker',
                    selected: viewModel.currentIndex == 1,
                    onTap: () => viewModel.setIndex(1),
                  ),
                  _NavItem(
                    icon: Icons.person,
                    label: 'About',
                    selected: viewModel.currentIndex == 2,
                    onTap: () => viewModel.setIndex(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  FixedLayoutViewModel viewModelBuilder(BuildContext context) =>
      FixedLayoutViewModel(0);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent1.withValues(alpha: 1)
                : AppColors.accent1.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(6),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.accent1.withValues(alpha: 0.9),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? Colors.black : Colors.white,
                size: screenWidth * 0.06,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.black : Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
