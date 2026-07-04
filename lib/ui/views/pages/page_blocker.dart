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
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
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
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBG),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton("APPS", 0, screenWidth, screenHeight),
              _buildTabButton("SITES", 1, screenWidth, screenHeight),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EmptyNoData(tab: "Apps", onActionPressed: () {}),
          _buildDynamicLinkCardBody(),
        ],
      ),
    );
  }

  // 🔧 Helper: Tab button builder
  Widget _buildTabButton(
      String label, int index, double screenWidth, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _tabController.index == index
              ? AppColors.accent1
              : AppColors.accent2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          minimumSize: Size(screenWidth * 0.35, screenHeight * 0.06),
        ),
        onPressed: () => _tabController.animateTo(index),
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
        ),
      ),
    );
  }

  // 🔧 Helper: Dynamic websites list
  Widget _buildDynamicLinkCardBody() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _storageService.getLinks(), // ✅ now in scope
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyNoData(
            tab: 'Websites',
            onActionPressed: () {},
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

  // 🔧 Helper: Row for each blocked site
  Widget _buildCustomLinkRow(Map<String, dynamic> linkData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF5A4B6E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
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
          const Icon(Icons.access_time, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            TimeFormatterUtil.formatElapsedTime(
                linkData['elapsed'] as Duration),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
