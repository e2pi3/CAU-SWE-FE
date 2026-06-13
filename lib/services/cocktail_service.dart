// lib/services/cocktail_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';

class CocktailRandomItem {
  final String id;
  final String name;
  final String nameKo;
  final String category;
  final String imageUrl;

  const CocktailRandomItem({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.category,
    required this.imageUrl,
  });

  factory CocktailRandomItem.fromJson(Map<String, dynamic> json) {
    return CocktailRandomItem(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKo: json['name_ko'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
    );
  }
}

class CocktailViewItem {
  final int rank;
  final String id;
  final String name;
  final String nameKo;
  final String category;
  final String imageUrl;
  final int viewCount;

  const CocktailViewItem({
    required this.rank,
    required this.id,
    required this.name,
    required this.nameKo,
    required this.category,
    required this.imageUrl,
    required this.viewCount,
  });

  factory CocktailViewItem.fromJson(Map<String, dynamic> json) {
    return CocktailViewItem(
      rank: json['rank'] as int,
      id: json['id'] as String,
      name: json['name'] as String,
      nameKo: json['name_ko'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      viewCount: json['view'] as int,
    );
  }
}

class CocktailRatingItem {
  final String id;
  final String name;
  final String nameKo;
  final String category;
  final String imageUrl;
  final double avgRating;

  const CocktailRatingItem({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.category,
    required this.imageUrl,
    required this.avgRating,
  });

  factory CocktailRatingItem.fromJson(Map<String, dynamic> json) {
    return CocktailRatingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKo: json['name_ko'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CocktailService {
  static Future<List<CocktailRandomItem>> getRandomCocktails({int count = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/cocktails/random?count=$count'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        return data.map((e) => CocktailRandomItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<CocktailViewItem>> getViewsRanking({int limit = 10, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/cocktails/ranking/views?limit=$limit&offset=$offset'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final cocktails = data['cocktails'] as List;
        return cocktails.map((e) => CocktailViewItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<CocktailRatingItem>> getRatingRanking({int limit = 10, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/cocktails/ranking/rating?limit=$limit&offset=$offset'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final cocktails = data['cocktails'] as List;
        return cocktails.map((e) => CocktailRatingItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }
}
