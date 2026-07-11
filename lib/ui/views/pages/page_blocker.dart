import 'package:flutter/material.dart';
import 'package:mobdev_finals_app/services/app_fetcher.dart';
import '../theme/app_colors.dart';

class BlockerPage extends StatefulWidget {
  const BlockerPage({super.key});

  @override
  State<BlockerPage> createState() => _BlockerPageState();
}

class _BlockerPageState extends State<BlockerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<InstalledApp> _blockedApps = [];

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

  void _openAppPicker() async {
    final InstalledApp? picked = await showModalBottomSheet<InstalledApp>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AppPickerSheet(),
    );

    if (picked != null &&
        !_blockedApps.any((a) => a.packageName == picked.packageName)) {
      setState(() => _blockedApps.add(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Need a Break?',
            style: TextStyle(
                color: AppColors.text1, fontSize: screenWidth * 0.05)),
        centerTitle: true,
        flexibleSpace:
            Container(decoration: BoxDecoration(gradient: AppColors.appBG)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                    child: Text('APPS',
                        style: TextStyle(
                            color: Colors.white, fontSize: screenWidth * 0.04)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                    child: Text('SITES',
                        style: TextStyle(
                            color: Colors.white, fontSize: screenWidth * 0.04)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _blockedApps.isEmpty
              ? EmptyNoData(tab: "Apps", onAdd: _openAppPicker)
              : _BlockedAppsList(
                  apps: _blockedApps,
                  onAdd: _openAppPicker,
                  onRemove: (app) => setState(
                    () => _blockedApps.removeWhere(
                        (a) => a.packageName == app.packageName),
                  ),
                ),
          EmptyNoData(tab: "Sites", onAdd: () {}),
        ],
      ),
    );
  }
}

// ── App Picker Bottom Sheet ───────────────────────────────────────────────────

class _AppPickerSheet extends StatefulWidget {
  const _AppPickerSheet();

  @override
  State<_AppPickerSheet> createState() => _AppPickerSheetState();
}

class _AppPickerSheetState extends State<_AppPickerSheet> {
  List<InstalledApp> _apps = [];
  List<InstalledApp> _filtered = [];
  bool _loading = true;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApps();
    _search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // FIX 1: clean single _loadApps() — no duplicate setState, no leftover sort
  Future<void> _loadApps() async {
    final apps = await AppFetcher.getInstalledApps();
    setState(() {
      _apps = apps;
      _filtered = apps;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    final query = _search.text.toLowerCase();
    setState(() {
      _filtered = _apps
          .where((app) => app.appName.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1723),
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
          const Text(
            'Select an App to Block',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF3E2D52),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      // FIX 2: no cast — InstalledApp already has icon built in
                      final app = _filtered[index];
                      return ListTile(
                        leading: Image.memory(app.icon, width: 40, height: 40),
                        title: Text(
                          app.appName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          app.packageName,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                        onTap: () => Navigator.of(context).pop(app),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} // ← FIX 3: closing brace for _AppPickerSheetState
  // ← FIX 3: closing brace for _AppPickerSheet (was missing entirely)

// ── Blocked Apps List ─────────────────────────────────────────────────────────

class _BlockedAppsList extends StatelessWidget {
  final List<InstalledApp> apps;
  final VoidCallback onAdd;
  final void Function(InstalledApp) onRemove;

  const _BlockedAppsList({
    required this.apps,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return ListTile(
            leading: Image.memory(app.icon, width: 40, height: 40),
            title: Text(
              app.appName,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.redAccent),
              onPressed: () => onRemove(app),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        backgroundColor: const Color(0xFFB887F3),
        child: const Icon(Icons.add, color: Colors.black),
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
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 24),
              Text(
                'No $tab yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Block $tab that distract you to start being productive',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}