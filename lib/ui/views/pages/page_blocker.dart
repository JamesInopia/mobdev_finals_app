// all blocker content
// all blocker content
import 'package:flutter/material.dart';

class BlockerPage extends StatelessWidget {
  const BlockerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 40,
              child: const TabBar(
                tabs: [
                  Tab(text: 'Apps'),
                  Tab(text: 'Sites'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  Center(
                    child: Text(
                      'Apps',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Sites',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
