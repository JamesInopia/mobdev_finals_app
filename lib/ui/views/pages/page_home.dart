// all home content
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:mobdev_finals_app/ui/widgets/empty.dart';
import 'package:mobdev_finals_app/services/storage_service.dart';
import 'package:mobdev_finals_app/utilities/timeformat_utilities.dart';
import 'package:mobdev_finals_app/ui/views/pages/page_blocker.dart';

const _cards = [
  {'type': 'Blocked Applications', 'content': 'List of blocked apps goes here'},
  {'type': 'Blocked Websites', 'content': 'DYNAMIC_STORAGE_LINK'},
  {'type': 'Apps in Timeout', 'content': ''},
  {
    'type': 'Apps blocked for this period',
    'content': 'Some apps are blocked until tomorrow'
  },
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.appBG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Hello, [username]!',
                  style: TextStyle(color: Colors.white)),
            ),
            const Text("Let's take a look at your progress!",
                style: TextStyle(color: Colors.white)),
            const Expanded(child: HorizontalGallery()),
          ],
        ),
      ),
    );
  }
}

class HorizontalGallery extends StatefulWidget {
  const HorizontalGallery({super.key});

  @override
  State<HorizontalGallery> createState() => _HorizontalGalleryState();
}

class _HorizontalGalleryState extends State<HorizontalGallery> {
  final LinkStorageService _storageService = LinkStorageService();
  final _controller = PageController(viewportFraction: 0.85);
  var _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => setState(() => _currentPage = _controller.page ?? 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              final card = _cards[index];
              final diff = (index - _currentPage).abs();
              final scale = (1.0 - (diff * 0.15)).clamp(0.85, 1.0);

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: scale),
                duration: const Duration(milliseconds: 200),
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: child,
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  color: AppColors.secondary2,
                  child: DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                    child: IconTheme(
                      data: const IconThemeData(color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              card['type'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: card['content'] == 'DYNAMIC_STORAGE_LINK'
                                ? _buildDynamicLinkCardBody()
                                : _buildStaticCardBody(
                                    card['content'] as String,
                                    card['type']
                                        as String, // FIX: Properly wrapped inside parameters
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _cards.length,
            (i) {
              final active = (i - _currentPage).abs() < 0.5;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? Theme.of(context).primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Helper 1: Builds standard static text cards or fallback Empty state
  Widget _buildStaticCardBody(String content, String tabName) {
    if (content.isEmpty) {
      return EmptyNoData(
        tab: tabName,
        onActionPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BlockerPage()),
          );
        },
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(content),
    );
  }

  // Helper 2: Asynchronously fetches SharedPreferences tracking data
  Widget _buildDynamicLinkCardBody() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _storageService.getLinks(), // Using service instance
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyNoData(
            tab: 'Websites',
            onActionPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlockerPage()),
              );
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
        color: const Color(0xFF5A4B6E),
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
            Icons.access_time,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
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
