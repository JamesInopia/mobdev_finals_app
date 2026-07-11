import 'package:flutter/material.dart';

class EmptyCardBody extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final VoidCallback onActionPressed;

  const EmptyCardBody({
    super.key,
    required this.message,
    required this.buttonLabel,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 40, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.add, color: Colors.white70),
              label: Text(
                buttonLabel,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}