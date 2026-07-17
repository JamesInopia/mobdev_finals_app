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
    'type': 'Apps scheduled for blocking',
    'content': 'Some apps are blocked until tomorrow'
  },
];

class HomePage extends StatefulWidget {
  final void Function(int)? onNavigateToTab;
  const HomePage({super.key, this.onNavigateToTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Map<String, String> _selectedGreeting;
  final List<Map<String, String>> _greetings = [
    {'bold': "Hello there! ", 'body': "Let's have a look at your progress!"},
    {'bold': "Welcome back! ", 'body': "Want to see how far you've come?"},
    {'bold': "Hey there! ", 'body': "Here's how your doing as of late!"},
    {'bold': "Good to see you! ", 'body': "Let's what your stats look like."},
  ];

  @override
  void initState() {
    super.initState();
    _greetings.shuffle();
    _selectedGreeting = _greetings.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 32.0, left: 20.0, right: 20.0, bottom: 20.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _selectedGreeting['bold'],
                      style: const TextStyle(
                        fontFamily: 'RobotoFlex',
                        fontWeight: FontWeight.w900,
                        color: AppColors.text1,
                        fontSize: 30,
                      ),
                    ),
                    const TextSpan(text: '\n'),
                    // Part B: Clean Urbanist text body
                    TextSpan(
                      text: _selectedGreeting['body'],
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.normal,
                        color: AppColors.text1,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: HorizontalGallery(onNavigateToTab: widget.onNavigateToTab),
            ),
          ],
        ),
      ),
    );
  }
}

// ── This is where your gallery code lives completely unmodified ──
class HorizontalGallery extends StatefulWidget {
  final void Function(int)? onNavigateToTab;
  const HorizontalGallery({super.key, this.onNavigateToTab});

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

  Stream<List<Map<String, dynamic>>> _getLinksStream() async* {
    while (true) {
      try {
        final links = await _storageService.getLinks();
        yield links;
      } catch (e) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 1));
    }
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
                  color: AppColors.container,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppColors.containerStroke,
                      width: 1.5,
                    ),
                  ),
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
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.text1,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'RobotoFlex',
                                  ),
                            ),
                          ),
                          Expanded(
                            child: card['content'] == 'DYNAMIC_STORAGE_LINK'
                                ? _buildDynamicLinkCardBody()
                                : _buildStaticCardBody(
                                    card['content'] as String,
                                    card['type'] as String,
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

  Widget _buildStaticCardBody(String content, String tabName) {
    if (content.isEmpty) {
      return EmptyCardBody(
        message: 'No $tabName blocked yet',
        buttonLabel: 'Go to Blocker',
        onActionPressed: () => widget.onNavigateToTab?.call(1),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(content),
    );
  }

  Widget _buildDynamicLinkCardBody() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getLinksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyCardBody(
            message: 'No websites blocked yet',
            buttonLabel: 'Go to Blocker',
            onActionPressed: () => widget.onNavigateToTab?.call(1),
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

  Widget _buildCustomLinkRow(Map<String, dynamic> linkData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.containerItem,
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
