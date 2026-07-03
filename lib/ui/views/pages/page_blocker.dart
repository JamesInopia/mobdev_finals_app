// all blocker content
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:mobdev_finals_app/ui/widgets/empty.dart';
import 'package:mobdev_finals_app/services/storage_service.dart';
import 'package:mobdev_finals_app/utilities/timeformat_utilities.dart';

class BlockerPage extends StatefulWidget {
  const BlockerPage({super.key});

  @override
  State<BlockerPage> createState() => _BlockerPageState();
}

class _BlockerPageState extends State<BlockerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LinkStorageService _storageService = LinkStorageService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: 0); // Explicitly start at 0

    _tabController.addListener(() {
      // FIX: Only trigger state changes if the index path has finished animating
      if (!_tabController.indexIsChanging) {
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Need a Break?',
          style:
              TextStyle(color: AppColors.text1, fontSize: screenWidth * 0.05),
        ),
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
                    child: Text(
                      'APPS',
                      style: TextStyle(
                          color: Colors.white, fontSize: screenWidth * 0.04),
                    ),
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
                    child: Text(
                      'SITES',
                      style: TextStyle(
                          color: Colors.white, fontSize: screenWidth * 0.04),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // FIX: Added the placeholder callback block to the fallback widgets
          EmptyNoData(
            tab: "Apps",
            onActionPressed: () {},
          ),
          _buildDynamicLinkCardBody(),
        ],
      ),
    );
  }

// Helper 2: Asynchronously fetches SharedPreferences tracking data
  Widget _buildDynamicLinkCardBody() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future:
          _storageService.getLinks(), // UPDATED: Using storage service instance
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        // UPDATED: Passing required parameters to EmptyNoData
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyNoData(
            tab: 'Websites',
            onActionPressed: () {
              // Left blank intentionally for now: Button does nothing on BlockerPage
            },
          );
        }

        final linksList = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: linksList.length,
          itemBuilder: (context, index) {
            final item = linksList[index];
            return _buildCustomLinkRow(item);
          },
        );
      },
    );
  }

// Helper 3: Generates individual rows matching your visual layout exact rules
  Widget _buildCustomLinkRow(Map<String, dynamic> linkData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF5A4B6E), // Matched dark lavender tone from image
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // A: Truncate link with ellipsis automatically if it hits width bounds
          Expanded(
            child: Text(
              linkData['url'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                decoration: TextDecoration.underline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // B: Timer icon followed by formatted maximum discrete string metric
          const Icon(
            Icons.access_time, // Open outline clock matching visual asset
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            // UPDATED: Using the static utility method
            TimeFormatterUtil.formatElapsedTime(
                linkData['elapsed'] as Duration),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
