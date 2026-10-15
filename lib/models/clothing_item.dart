import 'dart:convert';
import 'category.dart';

/// Modelo de uma peça de roupa individual no Closet
class ClothingItem {
  final String id;
  final String name;
  final ClothingCategory category;
  final String color;
  final String imagePath;
  final List<String> occasions;
  final String season;
  final bool isFavorite;
  final DateTime createdAt;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.imagePath,
    required this.occasions,
    this.season = 'Todas',
    this.isFavorite = false,
    required this.createdAt,
  });

  ClothingItem copyWith({
    String? id,
    String? name,
    ClothingCategory? category,
    String? color,
    String? imagePath,
    List<String>? occasions,
    String? season,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      occasions: occasions ?? this.occasions,
      season: season ?? this.season,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.toDbString(),
      'color': color,
      'imagePath': imagePath,
      'occasions': jsonEncode(occasions),
      'season': season,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    List<String> parsedOccasions = [];
    if (map['occasions'] != null) {
      try {
        final decoded = jsonDecode(map['occasions'] as String);
        if (decoded is List) {
          parsedOccasions = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedOccasions = [];
      }
    }

    return ClothingItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: ClothingCategoryExtension.fromDbString(map['category'] as String),
      color: (map['color'] as String?) ?? 'Neutra',
      imagePath: map['imagePath'] as String,
      occasions: parsedOccasions,
      season: (map['season'] as String?) ?? 'Todas',
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
