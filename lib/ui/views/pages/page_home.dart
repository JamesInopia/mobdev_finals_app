// all home content
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Home Page Content',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
