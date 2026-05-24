import 'package:flutter/material.dart';
import '../widgets/detail_app_bar.dart';

class IngredientInfoScreen extends StatelessWidget {
  final String id;

  const IngredientInfoScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailAppBar('재료 정보'),
      body: Center(
        child: Text('재료 ID: $id (임시 페이지)'),
      ),
    );
  }
}
