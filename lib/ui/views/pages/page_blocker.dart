import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isGridView = false;

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
      await _syncBlockedApps();
    }
  }

  // Called by _BlockedAppsList when the user confirms unblocking selected apps
  Future<void> _unblockApps(List<InstalledApp> toRemove) async {
    final packageNames = toRemove.map((a) => a.packageName).toSet();
    setState(() =>
        _blockedApps.removeWhere((a) => packageNames.contains(a.packageName)));
    await _syncBlockedApps();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1723),
      appBar: AppBar(
        title: Text(
          'Need a Break?',
          style: TextStyle(
            color: AppColors.text1,
            fontSize: screenWidth * 0.05,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBG),
        ),
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
                  isGridView: _isGridView,
                  onToggleView: () =>
                      setState(() => _isGridView = !_isGridView),
                  onRemove: (app) async {
                    setState(() => _blockedApps
                        .removeWhere((a) => a.packageName == app.packageName));
                    await _syncBlockedApps();
                  },
                  onUnblockMultiple: _unblockApps,
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
                      final app = _filtered[index];
                      return ListTile(
                        tileColor: const Color(0xFF1C1723),
                        leading: Image.memory(app.icon, width: 40, height: 40),
                        title: Text(app.appName,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(app.packageName,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                        onTap: () => Navigator.of(context).pop(app),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Blocked Apps List ─────────────────────────────────────────────────────────
// Converted to StatefulWidget to manage selection state internally

class _BlockedAppsList extends StatefulWidget {
  final List<InstalledApp> apps;
  final VoidCallback onAdd;
  final VoidCallback onToggleView;
  final bool isGridView;
  final void Function(InstalledApp) onRemove;
  final Future<void> Function(List<InstalledApp>) onUnblockMultiple;

  const _BlockedAppsList({
    required this.apps,
    required this.onAdd,
    required this.onToggleView,
    required this.isGridView,
    required this.onRemove,
    required this.onUnblockMultiple,
  });

  @override
  State<_BlockedAppsList> createState() => _BlockedAppsListState();
}

class _BlockedAppsListState extends State<_BlockedAppsList> {
  // Stores package names of currently selected apps
  final Set<String> _selectedPackages = {};

  // Whether selection mode is active
  bool _isSelecting = false;

  void _toggleSelectionMode() {
    setState(() {
      _isSelecting = !_isSelecting;
      // Clear selection when exiting selection mode
      if (!_isSelecting) _selectedPackages.clear();
    });
  }

  void _toggleAppSelection(InstalledApp app) {
    setState(() {
      if (_selectedPackages.contains(app.packageName)) {
        _selectedPackages.remove(app.packageName);
      } else {
        _selectedPackages.add(app.packageName);
      }
    });
  }

  // Confirm and unblock all selected apps
  void _confirmUnblock() async {
    final toRemove = widget.apps
        .where((a) => _selectedPackages.contains(a.packageName))
        .toList();

    // Show confirmation dialog before unblocking
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF261F32),
        title: const Text(
          'Unblock Apps',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Unblock ${toRemove.length} app${toRemove.length == 1 ? '' : 's'}? '
          'They will be fully removed from the blocker.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Unblock',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.onUnblockMultiple(toRemove);
      setState(() {
        _selectedPackages.clear();
        _isSelecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C1723),
      child: Stack(
        children: [
          // Main content — list or grid
          widget.isGridView ? _buildGrid() : _buildList(),

          // Bottom unblock bar — only visible when apps are selected
          if (_isSelecting && _selectedPackages.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF261F32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _confirmUnblock,
                    icon: const Icon(Icons.lock_open),
                    label: Text(
                      'Unblock ${_selectedPackages.length} '
                      'App${_selectedPackages.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // FAB column — top to bottom: select, toggle view, add
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Select / cancel selection mode button
                FloatingActionButton.small(
                  heroTag: 'select_mode',
                  onPressed: _toggleSelectionMode,
                  backgroundColor:
                      _isSelecting ? Colors.redAccent : AppColors.accent2,
                  child: Icon(
                    _isSelecting ? Icons.close : Icons.checklist,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // Toggle list/grid view
                FloatingActionButton.small(
                  heroTag: 'toggle_view',
                  onPressed: widget.onToggleView,
                  backgroundColor: AppColors.accent2,
                  child: Icon(
                    widget.isGridView ? Icons.list : Icons.grid_view,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // Add new app to block
                FloatingActionButton(
                  heroTag: 'add_app',
                  onPressed: widget.onAdd,
                  backgroundColor: AppColors.accent1,
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── List view ──
  Widget _buildList() {
    return ListView.builder(
      // Extra bottom padding when unblock bar is showing
      padding: EdgeInsets.only(
          bottom: _isSelecting && _selectedPackages.isNotEmpty ? 120 : 100),
      itemCount: widget.apps.length,
      itemBuilder: (context, index) {
        final app = widget.apps[index];
        final isSelected = _selectedPackages.contains(app.packageName);

        return ListTile(
          // Highlight selected tiles
          tileColor: isSelected
              ? AppColors.accent2.withOpacity(0.3)
              : const Color(0xFF1C1723),
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(app.icon, width: 44, height: 44),
              ),
              // Checkmark overlay when selected
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent1.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 24),
                  ),
                ),
            ],
          ),
          title: Text(
            app.appName,
            style: TextStyle(
              color: isSelected ? AppColors.accent1 : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            app.packageName,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          // In selection mode tapping selects, otherwise show remove button
          trailing: _isSelecting
              ? null
              : IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.redAccent),
                  onPressed: () => widget.onRemove(app),
                ),
          onTap: _isSelecting ? () => _toggleAppSelection(app) : null,
        );
      },
    );
  }

  // ── Grid view — 4 columns ──
  Widget _buildGrid() {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
          12, 12, 12, _isSelecting && _selectedPackages.isNotEmpty ? 120 : 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: widget.apps.length,
      itemBuilder: (context, index) {
        final app = widget.apps[index];
        final isSelected = _selectedPackages.contains(app.packageName);

        return GestureDetector(
          onTap: _isSelecting ? () => _toggleAppSelection(app) : null,
          child: _GridAppItem(
            app: app,
            isSelected: isSelected,
            isSelecting: _isSelecting,
            onRemove: widget.onRemove,
          ),
        );
      },
    );
  }
}

// ── Grid Item ─────────────────────────────────────────────────────────────────

class _GridAppItem extends StatelessWidget {
  final InstalledApp app;
  final bool isSelected;
  final bool isSelecting;
  final void Function(InstalledApp) onRemove;

  const _GridAppItem({
    required this.app,
    required this.isSelected,
    required this.isSelecting,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    app.icon,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                // Checkmark overlay when selected in selection mode
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent1.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 28),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              app.appName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppColors.accent1 : Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),

        // Remove badge — hidden during selection mode
        if (!isSelecting)
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: () => onRemove(app),
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
      ],
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
    return Container(
      color: const Color(0xFF1C1723),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 80, color: Colors.white24),
              const SizedBox(height: 24),
              Text(
                'No $tab blocked yet',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Block $tab that distract you to start being productive',
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
      ),
    );
  }
}
