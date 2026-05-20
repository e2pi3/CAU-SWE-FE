// lib/main.dart
// 앱 진입점입니다


import 'package:flutter/material.dart';
import 'screens/search.dart';

void main() {
  runApp(const Cocktailer());
}

class Cocktailer extends StatelessWidget {
  const Cocktailer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cocktailer',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),

      home: const SearchScreen(), //바로 검색창으로 이동
    );
  }
}