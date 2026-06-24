import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:mobdev_finals_app/ui/common/app_colors.dart';
import 'package:mobdev_finals_app/ui/common/ui_helpers.dart';

import 'home_viewmodel.dart';

class FixedLayout extends StatefulWidget {
  const FixedLayout({super.key});

  @override
  State<FixedLayout> createState() => _FixedLayoutState();
}

// Defines App Color Scheme
class AppColors {
  //surely no virus
  static const Color navigation = Color(0xFF261F32);
  static const Color accent1 = Color(0xFFB887F3);
  static const Color accent2 = Color(0xFF684B8C);
  static const Color accent3 = Color(0xFF3E2D52);
  static const Color secondary1 = Color(0xFF261F32);
  static const Color secondary2 = Color(0xFF251442);
  static const Color secondary3 = Color(0xFF36156E);
  static const LinearGradient appBG = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1C1723), Color(0xFF19092C)],
  );
}

// Custom Bottom NavBar Item
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
            color: selected ? AppColors.accent1 : AppColors.navigation,
            borderRadius: BorderRadius.circular(6),
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

class _FixedLayoutState extends State<FixedLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navigation,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Icon(Icons.menu, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.more_horiz, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: Text(
          _currentIndex == 0
              ? 'Home Screen'
              : _currentIndex == 1
                  ? 'Search Screen'
                  : 'Profile Screen',
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          color: AppColors.navigation,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.001,
              horizontal: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home,
                  label: 'Home',
                  selected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.lock,
                  label: 'Blocker',
                  selected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.person,
                  label: 'About',
                  selected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
