// all home content
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const _cards = [
  {'type': 'Blocked Applications', 'content': 'List of blocked apps goes here'},
  {'type': 'Blocked Websites', 'content': 'List of blocked websites goes here'},
  {
    'type': 'Apps in Timeout',
    'content': '' // empty → show EmptyNoData
  },
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
    ));
  }
}

class HorizontalGallery extends StatefulWidget {
  const HorizontalGallery({super.key});

  @override
  State<HorizontalGallery> createState() => _HorizontalGalleryState();
}

class _HorizontalGalleryState extends State<HorizontalGallery> {
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
                          // Removed Divider to eliminate line between header and body
                          Expanded(
                            child: (card['content'] as String).isEmpty
                                ? const EmptyNoData()
                                : Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(card['content'] as String),
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
}

class EmptyNoData extends StatelessWidget {
  const EmptyNoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'No data yet',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'When you add items, they will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }
}
