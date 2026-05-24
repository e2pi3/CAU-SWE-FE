import 'package:flutter/material.dart';

class IngredientInfoScreen extends StatelessWidget {
  final String id;

  const IngredientInfoScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('재료 정보'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('재료 ID: $id (임시 페이지)'),
      ),
    );
  }
}
