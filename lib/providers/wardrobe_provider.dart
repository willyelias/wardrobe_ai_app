import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/clothing_item.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class WardrobeState {
  final List<ClothingItem> allClothes;
  final ClothingCategory? selectedCategory;
  final bool isLoading;
  final String? error;

  const WardrobeState({
    this.allClothes = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.error,
  });

  List<ClothingItem> get filteredClothes {
    if (selectedCategory == null) return allClothes;
    return allClothes.where((item) => item.category == selectedCategory).toList();
  }

  WardrobeState copyWith({
    List<ClothingItem>? allClothes,
    ClothingCategory? selectedCategory,
    bool clearCategory = false,
    bool? isLoading,
    String? error,
  }) {
    return WardrobeState(
      allClothes: allClothes ?? this.allClothes,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  WardrobeNotifier() : super(const WardrobeState()) {
    loadClothes();
  }

  final DatabaseService _db = DatabaseService.instance;
  final StorageService _storage = StorageService.instance;

  Future<void> loadClothes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _db.getClothes();
      state = state.copyWith(allClothes: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar roupas: $e');
    }
  }

  void selectCategory(ClothingCategory? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  Future<void> addItem(ClothingItem item) async {
    try {
      await _db.insertClothingItem(item);
      final updated = [item, ...state.allClothes];
      state = state.copyWith(allClothes: updated);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao adicionar peça: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final item = state.allClothes.firstWhere((i) => i.id == id);
      await _db.deleteClothingItem(id);
      if (!item.imagePath.startsWith('sample_')) {
        await _storage.deleteImage(item.imagePath);
      }
      final updated = state.allClothes.where((i) => i.id != id).toList();
      state = state.copyWith(allClothes: updated);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao remover peça: $e');
    }
  }

  Future<void> toggleFavorite(ClothingItem item) async {
    try {
      final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
      await _db.updateClothingItem(updatedItem);
      final updatedList = state.allClothes.map((i) {
        return i.id == item.id ? updatedItem : i;
      }).toList();
      state = state.copyWith(allClothes: updatedList);
    } catch (e) {
      state = state.copyWith(error: 'Erro ao favoritar: $e');
    }
  }
}

final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  return WardrobeNotifier();
});
