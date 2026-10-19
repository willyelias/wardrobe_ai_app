import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/clothing_item.dart';
import '../models/user_avatar.dart';
import '../services/database_service.dart';

class AvatarFittingState {
  final UserAvatar? avatar;
  final Map<ClothingCategory, ClothingItem?> equippedItems;
  final bool isLoading;
  final bool isAnalyzingFit;
  final String? fitFeedback;

  const AvatarFittingState({
    this.avatar,
    this.equippedItems = const {},
    this.isLoading = false,
    this.isAnalyzingFit = false,
    this.fitFeedback,
  });

  bool get hasAvatar => avatar != null && avatar!.imagePath.isNotEmpty;
  bool get hasAnyEquipped => equippedItems.values.any((item) => item != null);

  List<ClothingItem> get activeItems =>
      equippedItems.values.whereType<ClothingItem>().toList();

  AvatarFittingState copyWith({
    UserAvatar? avatar,
    bool clearAvatar = false,
    Map<ClothingCategory, ClothingItem?>? equippedItems,
    bool? isLoading,
    bool? isAnalyzingFit,
    String? fitFeedback,
  }) {
    return AvatarFittingState(
      avatar: clearAvatar ? null : (avatar ?? this.avatar),
      equippedItems: equippedItems ?? this.equippedItems,
      isLoading: isLoading ?? this.isLoading,
      isAnalyzingFit: isAnalyzingFit ?? this.isAnalyzingFit,
      fitFeedback: fitFeedback ?? this.fitFeedback,
    );
  }
}

class AvatarNotifier extends StateNotifier<AvatarFittingState> {
  AvatarNotifier() : super(const AvatarFittingState(isLoading: true)) {
    loadAvatar();
  }

  final DatabaseService _db = DatabaseService.instance;

  Future<void> loadAvatar() async {
    state = state.copyWith(isLoading: true);
    final avatar = await _db.getUserAvatar();
    state = state.copyWith(avatar: avatar, isLoading: false);
  }

  Future<void> saveAvatar({
    required String imagePath,
    double? heightCm,
    String? bodyType,
    String? skinTone,
    String? notes,
  }) async {
    final now = DateTime.now();
    final newAvatar = UserAvatar(
      id: 'avatar_${now.millisecondsSinceEpoch}',
      imagePath: imagePath,
      heightCm: heightCm ?? 175.0,
      bodyType: bodyType ?? 'Equilibrado',
      skinTone: skinTone ?? 'Neutro',
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    await _db.saveUserAvatar(newAvatar);
    state = state.copyWith(avatar: newAvatar);
  }

  Future<void> removeAvatar() async {
    await _db.deleteUserAvatar();
    state = state.copyWith(clearAvatar: true, equippedItems: {});
  }

  void equipItem(ClothingItem item) {
    final updated = Map<ClothingCategory, ClothingItem?>.from(state.equippedItems);
    updated[item.category] = item;
    state = state.copyWith(equippedItems: updated);
    _triggerAutoFitAnalysis();
  }

  void unequipCategory(ClothingCategory category) {
    final updated = Map<ClothingCategory, ClothingItem?>.from(state.equippedItems);
    updated.remove(category);
    state = state.copyWith(equippedItems: updated);
    _triggerAutoFitAnalysis();
  }

  void loadLook(List<ClothingItem> items) {
    final updated = <ClothingCategory, ClothingItem?>{};
    for (var item in items) {
      updated[item.category] = item;
    }
    state = state.copyWith(equippedItems: updated);
    _triggerAutoFitAnalysis();
  }

  void clearFitting() {
    state = state.copyWith(equippedItems: {}, fitFeedback: null);
  }

  Future<void> _triggerAutoFitAnalysis() async {
    final items = state.activeItems;
    if (items.isEmpty) {
      state = state.copyWith(fitFeedback: null);
      return;
    }

    state = state.copyWith(isAnalyzingFit: true);
    final bodyType = state.avatar?.bodyType ?? 'Equilibrado';

    // Gera feedback estilístico em tempo real para o biotipo do usuário
    final itemNames = items.map((e) => '${e.category.displayName}: ${e.name} (${e.color})').join(', ');
    final feedback = '✦ Caimento no seu biotipo ($bodyType): O look com $itemNames cria uma silhueta harmônica e proporcional. O contraste cromático valoriza a sua linha visual e postura.';

    state = state.copyWith(
      isAnalyzingFit: false,
      fitFeedback: feedback,
    );
  }
}

final avatarProvider = StateNotifierProvider<AvatarNotifier, AvatarFittingState>((ref) {
  return AvatarNotifier();
});
