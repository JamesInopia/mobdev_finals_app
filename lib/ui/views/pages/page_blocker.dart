// all blocker content
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BlockerPage extends StatefulWidget {
  const BlockerPage({super.key});

  @override
  State<BlockerPage> createState() => _BlockerPageState();
}

class _BlockerPageState extends State<BlockerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {}); // rebuild when tab changes
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
                )
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          EmptyNoData(tab: "Apps"),
          EmptyNoData(tab: "Sites"),
        ],
      ),
    );
  }
}

class EmptyNoData extends StatelessWidget {
  final String tab;

  const EmptyNoData({
    super.key,
    required this.tab,
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
                onPressed: () {},
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
