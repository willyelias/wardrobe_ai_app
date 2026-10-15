import 'dart:convert';
import 'clothing_item.dart';

/// Modelo de Look completo (combinação de peças com curadoria da IA)
class Outfit {
  final String id;
  final String name;
  final String occasion;
  final List<String> itemIds;
  final List<ClothingItem> items;
  final String aiStylistNote;
  final bool isFavorite;
  final DateTime createdAt;

  const Outfit({
    required this.id,
    required this.name,
    required this.occasion,
    required this.itemIds,
    this.items = const [],
    required this.aiStylistNote,
    this.isFavorite = false,
    required this.createdAt,
  });

  Outfit copyWith({
    String? id,
    String? name,
    String? occasion,
    List<String>? itemIds,
    List<ClothingItem>? items,
    String? aiStylistNote,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      occasion: occasion ?? this.occasion,
      itemIds: itemIds ?? this.itemIds,
      items: items ?? this.items,
      aiStylistNote: aiStylistNote ?? this.aiStylistNote,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'occasion': occasion,
      'itemIds': jsonEncode(itemIds),
      'aiStylistNote': aiStylistNote,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Outfit.fromMap(Map<String, dynamic> map, {List<ClothingItem> items = const []}) {
    List<String> parsedIds = [];
    if (map['itemIds'] != null) {
      try {
        final decoded = jsonDecode(map['itemIds'] as String);
        if (decoded is List) {
          parsedIds = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedIds = [];
      }
    }

    return Outfit(
      id: map['id'] as String,
      name: map['name'] as String,
      occasion: map['occasion'] as String,
      itemIds: parsedIds,
      items: items,
      aiStylistNote: (map['aiStylistNote'] as String?) ?? '',
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
