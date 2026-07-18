// all timer content
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobdev_finals_app/services/app_fetcher.dart';
import 'package:mobdev_finals_app/ui/views/theme/app_colors.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<InstalledApp> _blockedApps = [];

  static const _channel = MethodChannel(
    'com.example.mobdev_finals_app/installed_apps',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _syncBlockedApps() async {
    final packages = _blockedApps.map((a) => a.packageName).toList();
    await _channel.invokeMethod('updateBlockedApps', {'packages': packages});
  }

  // time limit bottom sheet
  void _openTimeLimitSheet() async {
    final InstalledApp? picked = await showModalBottomSheet<InstalledApp>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TimeLimitSheet(),
    );

    if (picked != null &&
        !_blockedApps.any((a) => a.packageName == picked.packageName)) {
      setState(() => _blockedApps.add(picked));
      await _syncBlockedApps();
    }
  }

  // time limit bottom sheet
  void _openScheduleSheet() async {
    final InstalledApp? picked = await showModalBottomSheet<InstalledApp>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ScheduleSheet(),
    );

    if (picked != null &&
        !_blockedApps.any((a) => a.packageName == picked.packageName)) {
      setState(() => _blockedApps.add(picked));
      await _syncBlockedApps();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 23.0,
              right: 23.0), // Outer layout padding matches BlockerPage
          child: Column(
            children: [
              // ── TOP BUTTON ROW ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _tabController.index == 0
                                ? AppColors.accent1
                                : AppColors.accent2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            minimumSize:
                                Size(screenWidth * 0.35, screenHeight * 0.06),
                          ),
                          onPressed: () => _tabController.animateTo(0),
                          child: Text(
                            'TIME LIMIT',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'RobotoFlex',
                                fontWeight: FontWeight.w900,
                                fontSize: screenWidth * 0.04),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _tabController.index == 1
                                ? AppColors.accent1
                                : AppColors.accent2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            minimumSize:
                                Size(screenWidth * 0.35, screenHeight * 0.06),
                          ),
                          onPressed: () => _tabController.animateTo(1),
                          child: Text(
                            'SCHEDULED',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'RobotoFlex',
                                fontWeight: FontWeight.w900,
                                fontSize: screenWidth * 0.04),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── THE TAB VIEW CONTENT ─────────────────────────────────────────
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                      bottom: 23.0), // Match bottom margin from BlockerPage
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Card(
                        color: AppColors.container,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppColors.containerStroke,
                            width: 1.5,
                          ),
                        ),
                        child: EmptyNoData(
                            tab: "Time Limits", onAdd: _openTimeLimitSheet),
                      ),
                      Card(
                        color: AppColors.container,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppColors.containerStroke,
                            width: 1.5,
                          ),
                        ),
                        child: EmptyNoData(
                            tab: "Schedules", onAdd: _openScheduleSheet),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ── Time Limit Bottom Sheet ───────────────────────────────────────────────────

class _TimeLimitSheet extends StatefulWidget {
  const _TimeLimitSheet();

  @override
  State<_TimeLimitSheet> createState() => _TimeLimitSheetState();
}

class _TimeLimitSheetState extends State<_TimeLimitSheet> {
  List<InstalledApp> _filtered = [];
  bool _loading = true;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.5,
      decoration: const BoxDecoration(
        color: AppColors.secondary2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.47,
                height: screenHeight * 0.22,
                decoration: BoxDecoration(
                  color: AppColors.secondary3,
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "TIME LIMIT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "4:30:00",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: screenWidth * 0.47,
                height: screenHeight * 0.22,
                decoration: BoxDecoration(
                  color: AppColors.secondary3,
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "PENALTY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "3:00:00",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.47,
                height: screenHeight * 0.22,
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent3,
                  ),
                  onPressed: () {},
                  child: Text("CANCEL",
                      style: TextStyle(
                          color: Colors.white, fontSize: screenWidth * 0.06)),
                ),
              ),
              const SizedBox(width: 15),
              Container(
                width: screenWidth * 0.47,
                height: screenHeight * 0.22,
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent2,
                  ),
                  onPressed: () {},
                  child: Text("CONFIRM",
                      style: TextStyle(
                          color: Colors.white, fontSize: screenWidth * 0.06)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Schedule Bottom Sheet ───────────────────────────────────────────────────

class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet();

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  List<InstalledApp> _filtered = [];
  bool _loading = true;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.5,
      decoration: const BoxDecoration(
        color: AppColors.secondary2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.47,
                height: screenHeight * 0.22,
                decoration: BoxDecoration(
                  color: AppColors.secondary3,
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "BLOCK START",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "5:00 PM",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: screenWidth * 0.47,
                height: screenHeight * 0.22,
                decoration: BoxDecoration(
                  color: AppColors.secondary3,
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "BLOCK END",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "5:00 AM",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.47,
                height: screenHeight * 0.22,
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent3,
                  ),
                  onPressed: () {},
                  child: Text("CANCEL",
                      style: TextStyle(
                          color: Colors.white, fontSize: screenWidth * 0.06)),
                ),
              ),
              const SizedBox(width: 15),
              Container(
                width: screenWidth * 0.47,
                height: screenHeight * 0.22,
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent2,
                  ),
                  onPressed: () {},
                  child: Text("CONFIRM",
                      style: TextStyle(
                          color: Colors.white, fontSize: screenWidth * 0.06)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class EmptyNoData extends StatelessWidget {
  final String tab;
  final VoidCallback onAdd;

  const EmptyNoData({
    super.key,
    required this.tab,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 80, color: Colors.white24),
            const SizedBox(height: 24),
            Text(
              'No $tab set yet',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set $tab that let you use your blocked apps temporarily',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent1,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
