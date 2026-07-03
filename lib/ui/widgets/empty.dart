import 'package:flutter/material.dart';

class EmptyNoData extends StatelessWidget {
  final String tab;
  final VoidCallback? onActionPressed; // Added to handle different click rules

  const EmptyNoData({
    super.key,
    required this.tab,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Removed Scaffold to prevent visual breaking inside smaller Cards
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24), // Tighter padding for card fitting
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size:
                  60, // Sized down slightly to sit nicely inside a card gallery
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              'No $tab yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Block $tab that distract you to start being productive',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onActionPressed, // Dynamic callback
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5A4B6E), // Contrast color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
