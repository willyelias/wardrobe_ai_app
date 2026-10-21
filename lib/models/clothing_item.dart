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
  final double? purchasePrice;
  final int wearCount;
  final DateTime? lastWornDate;
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
    this.purchasePrice,
    this.wearCount = 0,
    this.lastWornDate,
    required this.createdAt,
  });

  /// Custo por uso (Cost-per-Wear)
  double? get costPerWear {
    if (purchasePrice == null || purchasePrice! <= 0) return null;
    final uses = wearCount <= 0 ? 1 : wearCount;
    return purchasePrice! / uses;
  }

  /// Verifica se é uma peça "esquecida" (+30 dias sem uso ou nunca usada)
  bool get isForgotten {
    final now = DateTime.now();
    if (lastWornDate != null) {
      return now.difference(lastWornDate!).inDays >= 30;
    }
    return now.difference(createdAt).inDays >= 14 && wearCount == 0;
  }

  ClothingItem copyWith({
    String? id,
    String? name,
    ClothingCategory? category,
    String? color,
    String? imagePath,
    List<String>? occasions,
    String? season,
    bool? isFavorite,
    double? purchasePrice,
    int? wearCount,
    DateTime? lastWornDate,
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
      purchasePrice: purchasePrice ?? this.purchasePrice,
      wearCount: wearCount ?? this.wearCount,
      lastWornDate: lastWornDate ?? this.lastWornDate,
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
      'purchasePrice': purchasePrice,
      'wearCount': wearCount,
      'lastWornDate': lastWornDate?.toIso8601String(),
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
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble(),
      wearCount: (map['wearCount'] as num?)?.toInt() ?? 0,
      lastWornDate: map['lastWornDate'] != null
          ? DateTime.tryParse(map['lastWornDate'] as String)
          : null,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
