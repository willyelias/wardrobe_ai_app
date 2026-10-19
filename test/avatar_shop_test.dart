import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_ai_app/models/category.dart';
import 'package:wardrobe_ai_app/models/clothing_item.dart';
import 'package:wardrobe_ai_app/models/user_avatar.dart';
import 'package:wardrobe_ai_app/models/user_profile.dart';
import 'package:wardrobe_ai_app/services/quota_service.dart';
import 'package:wardrobe_ai_app/services/shop_search_service.dart';

void main() {
  group('Novas funcionalidades do guarda-roupa virtual', () {
    test('UserAvatar instancia e serializa corretamente', () {
      final now = DateTime.now();
      final avatar = UserAvatar(
        id: 'avatar_test',
        imagePath: '/path/to/avatar.jpg',
        heightCm: 178.0,
        bodyType: 'Atlético',
        skinTone: 'Claro',
        createdAt: now,
        updatedAt: now,
      );

      final map = avatar.toMap();
      final reconstructed = UserAvatar.fromMap(map);

      expect(reconstructed.id, 'avatar_test');
      expect(reconstructed.heightCm, 178.0);
      expect(reconstructed.bodyType, 'Atlético');
    });

    test('UserProfile modo convidado e Google Sign-in', () {
      final guest = UserProfile.guest();
      expect(guest.isLoggedIn, false);
      expect(guest.authMethod, AuthMethod.guest);

      final user = UserProfile(
        id: 'usr_1',
        displayName: 'Willy Alves',
        email: 'willy@test.com',
        authMethod: AuthMethod.google,
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );

      expect(user.isLoggedIn, true);
      expect(user.authMethod, AuthMethod.google);
    });

    test('ShopSearchService gera itens similares em lojas para uma peça', () {
      final item = ClothingItem(
        id: 'shirt_1',
        name: 'Camisa Linho Branca',
        category: ClothingCategory.top,
        color: 'Branco',
        imagePath: 'sample_shirt',
        occasions: const ['Casual', 'Trabalho'],
        season: 'Verão',
        createdAt: DateTime.now(),
      );

      final similars = ShopSearchService.instance.getSimilarShopItems(item);
      expect(similars.isNotEmpty, true);
      expect(similars.any((s) => s.storeName == 'Zara'), true);
      expect(similars.any((s) => s.storeName == 'Lojas Renner'), true);
    });

    test('QuotaService opera em modo ilimitado sem anúncios', () async {
      expect(QuotaService.instance.isUnlimited, true);
      final canGen = await QuotaService.instance.canGenerate();
      expect(canGen, true);
    });
  });
}
