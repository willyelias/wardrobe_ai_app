import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_ai_app/models/category.dart';
import 'package:wardrobe_ai_app/models/clothing_item.dart';
import 'package:wardrobe_ai_app/services/color_season_service.dart';
import 'package:wardrobe_ai_app/services/purchase_validator_service.dart';
import 'package:wardrobe_ai_app/services/smart_packing_service.dart';

void main() {
  group('ClothingItem Metrics & Logic', () {
    test('Calculates costPerWear properly', () {
      final item = ClothingItem(
        id: '1',
        name: 'Camisa Linho',
        category: ClothingCategory.top,
        color: 'Branco',
        imagePath: '/mock/path.png',
        occasions: const ['Casual'],
        purchasePrice: 150.0,
        wearCount: 5,
        createdAt: DateTime.now(),
      );

      expect(item.costPerWear, equals(30.0));
    });

    test('Identifies forgotten clothing item (+30 days without wear)', () {
      final forgottenItem = ClothingItem(
        id: '2',
        name: 'Casaco Pesado',
        category: ClothingCategory.outerwear,
        color: 'Cinza',
        imagePath: '/mock/path.png',
        occasions: const ['Frio'],
        wearCount: 1,
        lastWornDate: DateTime.now().subtract(const Duration(days: 35)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );

      expect(forgottenItem.isForgotten, isTrue);
    });
  });

  group('ColorSeasonService', () {
    final service = ColorSeasonService.instance;

    test('Provides 4 seasonal palettes', () {
      expect(ColorSeasonService.allSeasons.length, equals(4));
    });

    test('Evaluates harmonious and universal colors', () {
      final warmAutumnMatch = service.evaluateColor('Terracota', 'Outono Quente');
      expect(warmAutumnMatch.isHarmonious, isTrue);
      expect(warmAutumnMatch.isDirectMatch, isTrue);

      final neutralMatch = service.evaluateColor('Bege Neutro', 'Inverno Escuro');
      expect(neutralMatch.isHarmonious, isTrue);
    });

    test('Determines season based on quiz scores', () {
      final season = service.determineSeason(undertoneScore: 1, intensityScore: 0);
      expect(season, equals('Outono Quente'));

      final winter = service.determineSeason(undertoneScore: 0, intensityScore: 1);
      expect(winter, equals('Inverno Escuro'));
    });
  });

  group('PurchaseValidatorService', () {
    final service = PurchaseValidatorService.instance;

    final mockCloset = [
      ClothingItem(
        id: 't1',
        name: 'Blazer Preto',
        category: ClothingCategory.outerwear,
        color: 'Preto',
        imagePath: 'path1',
        occasions: const ['Trabalho'],
        createdAt: DateTime.now(),
      ),
      ClothingItem(
        id: 't2',
        name: 'Jaqueta Preta',
        category: ClothingCategory.outerwear,
        color: 'Preto',
        imagePath: 'path2',
        occasions: const ['Casual'],
        createdAt: DateTime.now(),
      ),
      ClothingItem(
        id: 'b1',
        name: 'Calça Alfaiataria',
        category: ClothingCategory.bottom,
        color: 'Cinza',
        imagePath: 'path3',
        occasions: const ['Trabalho'],
        createdAt: DateTime.now(),
      ),
      ClothingItem(
        id: 's1',
        name: 'Sapato Social',
        category: ClothingCategory.shoes,
        color: 'Preto',
        imagePath: 'path4',
        occasions: const ['Trabalho'],
        createdAt: DateTime.now(),
      ),
    ];

    test('Flags redundant purchase when 2+ similar items exist', () {
      final result = service.analyzeCandidate(
        name: 'Sobretudo Preto',
        category: ClothingCategory.outerwear,
        color: 'Preto',
        price: 250.0,
        allClothes: mockCloset,
      );

      expect(result.verdict, equals(PurchaseVerdict.redundant));
      expect(result.similarPiecesAlreadyOwned.length, greaterThanOrEqualTo(2));
      expect(result.estimatedCostPerWear, isNotNull);
    });

    test('Recommends versatile candidate with existing wardrobe matches', () {
      final expandedCloset = [
        ...mockCloset,
        ClothingItem(
          id: 'b2',
          name: 'Jeans Escuro',
          category: ClothingCategory.bottom,
          color: 'Azul',
          imagePath: 'path5',
          occasions: const ['Casual'],
          createdAt: DateTime.now(),
        ),
        ClothingItem(
          id: 'b3',
          name: 'Calça Chino',
          category: ClothingCategory.bottom,
          color: 'Bege',
          imagePath: 'path6',
          occasions: const ['Casual'],
          createdAt: DateTime.now(),
        ),
        ClothingItem(
          id: 'b4',
          name: 'Bermuda Linho',
          category: ClothingCategory.bottom,
          color: 'Branco',
          imagePath: 'path7',
          occasions: const ['Casual'],
          createdAt: DateTime.now(),
        ),
      ];

      final result = service.analyzeCandidate(
        name: 'Camisa Branca',
        category: ClothingCategory.top,
        color: 'Branco',
        price: 120.0,
        allClothes: expandedCloset,
      );

      expect(result.verdict, equals(PurchaseVerdict.recommended));
      expect(result.compatiblePieces.length, greaterThanOrEqualTo(4));
    });
  });

  group('SmartPackingService', () {
    final service = SmartPackingService.instance;

    final mockClothes = [
      ClothingItem(id: '1', name: 'T1', category: ClothingCategory.top, color: 'Branco', imagePath: 'p1', occasions: const ['Casual'], createdAt: DateTime.now()),
      ClothingItem(id: '2', name: 'T2', category: ClothingCategory.top, color: 'Azul', imagePath: 'p2', occasions: const ['Casual'], createdAt: DateTime.now()),
      ClothingItem(id: '3', name: 'T3', category: ClothingCategory.top, color: 'Preto', imagePath: 'p3', occasions: const ['Casual'], createdAt: DateTime.now()),
      ClothingItem(id: '4', name: 'B1', category: ClothingCategory.bottom, color: 'Preto', imagePath: 'p4', occasions: const ['Casual'], createdAt: DateTime.now()),
      ClothingItem(id: '5', name: 'B2', category: ClothingCategory.bottom, color: 'Jeans', imagePath: 'p5', occasions: const ['Casual'], createdAt: DateTime.now()),
      ClothingItem(id: '6', name: 'S1', category: ClothingCategory.shoes, color: 'Branco', imagePath: 'p6', occasions: const ['Casual'], createdAt: DateTime.now()),
      ClothingItem(id: '7', name: 'O1', category: ClothingCategory.outerwear, color: 'Azul', imagePath: 'p7', occasions: const ['Casual'], createdAt: DateTime.now()),
    ];

    test('Generates 5-4-3-2-1 capsule luggage with day-by-day outfits', () {
      final capsule = service.generateCapsule(
        destination: 'Florianópolis',
        days: 4,
        tripTheme: 'Praia',
        allClothes: mockClothes,
      );

      expect(capsule.destination, equals('Florianópolis'));
      expect(capsule.days, equals(4));
      expect(capsule.dailyOutfits.length, equals(4));
      expect(capsule.checklist.isNotEmpty, isTrue);
    });
  });
}
