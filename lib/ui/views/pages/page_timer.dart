// all timer content
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobdev_finals_app/services/app_fetcher.dart';
import 'package:mobdev_finals_app/ui/views/theme/app_colors.dart';
import 'package:scroll_time_picker/scroll_time_picker.dart';

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

  Duration timeLimitDuration = const Duration(hours: 1, minutes: 0, seconds: 0);
  Duration timeLimitMinimum = const Duration(hours: 1, minutes: 0, seconds: 0);

  Duration penaltyDuration = const Duration(hours: 3, minutes: 0, seconds: 0);
  Duration penaltyMinimum = const Duration(hours: 3, minutes: 0, seconds: 0);

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

    String twoDigits(int num) => num.toString().padLeft(2, '0');
    final timeLimitHours = twoDigits(timeLimitDuration.inHours);
    final timeLimitMinutes =
        twoDigits(timeLimitDuration.inMinutes.remainder(60));
    final timeLimitSeconds =
        twoDigits(timeLimitDuration.inSeconds.remainder(60));

    final penaltyHours = twoDigits(penaltyDuration.inHours);
    final penaltyMinutes = twoDigits(penaltyDuration.inMinutes.remainder(60));
    final penaltySeconds = twoDigits(penaltyDuration.inSeconds.remainder(60));

    return Container(
      height: screenHeight * 0.54,
      decoration: const BoxDecoration(
        color: AppColors.secondary2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: screenWidth * 0.12,
              height: screenHeight * 0.005,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.secondary3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.22,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "TIME LIMIT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.07,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _SetTimerPopup.showPopup(
                                  context,
                                  "TIME LIMIT",
                                  timeLimitDuration,
                                  timeLimitMinimum, (selectedDuration) {
                                setState(() {
                                  timeLimitDuration = selectedDuration;
                                });
                              });
                            },
                            child: Text(
                              "$timeLimitHours:$timeLimitMinutes:$timeLimitSeconds",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.secondary3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.22,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "PENALTY",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.07,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _SetTimerPopup.showPopup(
                                  context,
                                  "PENALTY",
                                  penaltyDuration,
                                  penaltyMinimum, (selectedDuration) {
                                setState(() {
                                  penaltyDuration = selectedDuration;
                                });
                              });
                            },
                            child: Text(
                              "$penaltyHours:$penaltyMinutes:$penaltySeconds",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent3,
                      ),
                      onPressed: () {},
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.06,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent2,
                      ),
                      onPressed: () {},
                      child: Text(
                        "CONFIRM",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.06,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
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

  late DateTime blockStartTime;
  late DateTime blockEndTime;

  int to24h(int hour12, bool isPm) {
    int hour24;

    if (isPm && hour12 != 12) {
      hour24 = hour12 + 12;
    } else if (!isPm && hour12 == 12) {
      hour24 = 0;
    } else {
      hour24 = hour12;
    }

    return hour24;
  }

  @override
  void initState() {
    super.initState();
    blockStartTime = DateTime(2000, 1, 1, to24h(12, false), 0);
    blockEndTime = DateTime(2000, 1, 1, to24h(12, true), 0);
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

    String startTimeText = DateFormat('h:mm a').format(blockStartTime);
    String endTimeText = DateFormat('h:mm a').format(blockEndTime);

    return Container(
      height: screenHeight * 0.54,
      decoration: const BoxDecoration(
        color: AppColors.secondary2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: screenWidth * 0.12,
              height: screenHeight * 0.005,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.secondary3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.22,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "BLOCK START",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.06,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _SetTimeOfDayPopup.showPopup(
                                  context, "BLOCK START", blockStartTime,
                                  (selectedTime) {
                                setState(() {
                                  blockStartTime = selectedTime;
                                });
                              });
                            },
                            child: Text(
                              "$startTimeText",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.secondary3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: SizedBox(
                      height: screenHeight * 0.22,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "BLOCK END",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.06,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _SetTimeOfDayPopup.showPopup(
                                  context, "BLOCK END", blockEndTime,
                                  (selectedTime) {
                                setState(() {
                                  blockEndTime = selectedTime;
                                });
                              });
                            },
                            child: Text(
                              "${endTimeText}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent3,
                      ),
                      onPressed: () {},
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.06,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent2,
                      ),
                      onPressed: () {},
                      child: Text(
                        "CONFIRM",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.06,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── CupertinoTimer Popup ───────────────────────────────────────────────────────────

class _SetTimerPopup {
  static void showPopup(
    BuildContext context,
    String timerType,
    Duration initialTime,
    Duration minimumTime,
    ValueChanged<Duration> onTimeSelected,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Duration tempTime = initialTime;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: SizedBox(
            width: screenWidth * 0.9,
            height: screenHeight * 0.45,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.secondary3,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        width: screenWidth * 0.82,
                        height: screenHeight * 0.08,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "SET $timerType",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.08,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.secondary3,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        width: screenWidth * 0.82,
                        height: screenHeight * 0.22,
                        child: CupertinoTimerPicker(
                          mode: CupertinoTimerPickerMode.hms,
                          initialTimerDuration: tempTime,
                          onTimerDurationChanged: (Duration newDuration) {
                            tempTime = newDuration;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: screenHeight * 0.05,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent3,
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              child: Text(
                                "CANCEL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: screenHeight * 0.05,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent2,
                              ),
                              onPressed: () {
                                if (tempTime >= minimumTime) {
                                  onTimeSelected(tempTime);
                                  Navigator.of(dialogContext).pop();
                                } else {}
                              },
                              child: Text(
                                "CONFIRM",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── CupertinoDate Popup ───────────────────────────────────────────────────────────

class _SetTimeOfDayPopup {
  static void showPopup(
    BuildContext context,
    String timerType,
    DateTime initialTime,
    ValueChanged<DateTime> onTimeSelected,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    DateTime tempTime = initialTime;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.05,
          ),
          child: SizedBox(
            width: screenWidth * 0.9,
            height: screenHeight * 0.45,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.secondary3,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        width: screenWidth * 0.82,
                        height: screenHeight * 0.08,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "SET $timerType",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.08,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.secondary3,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        width: screenWidth * 0.82,
                        height: screenHeight * 0.22,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          use24hFormat: false,
                          initialDateTime: tempTime,
                          onDateTimeChanged: (DateTime newTime) {
                            tempTime = newTime;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: screenHeight * 0.05,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent3,
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              child: Text(
                                "CANCEL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: screenHeight * 0.05,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent2,
                              ),
                              onPressed: () {
                                onTimeSelected(tempTime);
                                Navigator.of(dialogContext).pop();
                              },
                              child: Text(
                                "CONFIRM",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.05,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
