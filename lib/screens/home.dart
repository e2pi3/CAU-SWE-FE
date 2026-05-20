// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'search.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cocktailer'),
      ),
      body: const Center(
        child: Text(
          '구현 예정',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        child: const Icon(Icons.search),
      ),
    );
  }
}
