import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_ai_app/models/category.dart';
import 'package:wardrobe_ai_app/models/clothing_item.dart';
import 'package:wardrobe_ai_app/models/calendar_log.dart';
import 'package:wardrobe_ai_app/services/ai_stylist_service.dart';

void main() {
  group('Wardrobe Data Models Test', () {
    test('ClothingItem converts to/from Map correctly', () {
      final now = DateTime.now();
      final item = ClothingItem(
        id: 'test_1',
        name: 'Camisa Branca',
        category: ClothingCategory.top,
        color: 'Branco',
        imagePath: '/path/to/img.png',
        occasions: const ['Trabalho', 'Casual'],
        createdAt: now,
      );

      final map = item.toMap();
      final reconstructed = ClothingItem.fromMap(map);

      expect(reconstructed.id, equals('test_1'));
      expect(reconstructed.name, equals('Camisa Branca'));
      expect(reconstructed.category, equals(ClothingCategory.top));
      expect(reconstructed.occasions, contains('Trabalho'));
    });

    test('CalendarLog normalizes date without time', () {
      final dt = DateTime(2026, 10, 15, 14, 30, 45);
      final normalized = CalendarLog.normalizeDate(dt);

      expect(normalized.year, equals(2026));
      expect(normalized.month, equals(10));
      expect(normalized.day, equals(15));
      expect(normalized.hour, equals(0));
      expect(normalized.minute, equals(0));
    });

    test('AiStylistService local generator creates balanced look for occasion', () async {
      final now = DateTime.now();
      final items = [
        ClothingItem(
          id: '1',
          name: 'Camisa Linho',
          category: ClothingCategory.top,
          color: 'Branco',
          imagePath: 'path1',
          occasions: const ['Trabalho'],
          createdAt: now,
        ),
        ClothingItem(
          id: '2',
          name: 'Calça Alfaiataria',
          category: ClothingCategory.bottom,
          color: 'Preto',
          imagePath: 'path2',
          occasions: const ['Trabalho'],
          createdAt: now,
        ),
        ClothingItem(
          id: '3',
          name: 'Sapato Derby',
          category: ClothingCategory.shoes,
          color: 'Preto',
          imagePath: 'path3',
          occasions: const ['Trabalho'],
          createdAt: now,
        ),
      ];

      final outfit = await AiStylistService.instance.generateLook(
        occasion: 'Trabalho',
        availableClothes: items,
      );

      expect(outfit.itemIds.length, greaterThanOrEqualTo(2));
      expect(outfit.aiStylistNote.isNotEmpty, isTrue);
      expect(outfit.occasion, equals('Trabalho'));
    });
  });
}
