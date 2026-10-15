import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/ai_stylist_service.dart';
import '../services/database_service.dart';
import 'quota_provider.dart';

class StylistState {
  final bool isGenerating;
  final String selectedOccasion;
  final String? selectedVibe;
  final Outfit? currentOutfit;
  final List<Outfit> savedOutfits;
  final String? errorMessage;

  const StylistState({
    this.isGenerating = false,
    this.selectedOccasion = 'Trabalho',
    this.selectedVibe,
    this.currentOutfit,
    this.savedOutfits = const [],
    this.errorMessage,
  });

  StylistState copyWith({
    bool? isGenerating,
    String? selectedOccasion,
    String? selectedVibe,
    Outfit? currentOutfit,
    bool clearCurrentOutfit = false,
    List<Outfit>? savedOutfits,
    String? errorMessage,
  }) {
    return StylistState(
      isGenerating: isGenerating ?? this.isGenerating,
      selectedOccasion: selectedOccasion ?? this.selectedOccasion,
      selectedVibe: selectedVibe ?? this.selectedVibe,
      currentOutfit: clearCurrentOutfit ? null : (currentOutfit ?? this.currentOutfit),
      savedOutfits: savedOutfits ?? this.savedOutfits,
      errorMessage: errorMessage,
    );
  }
}

class StylistNotifier extends StateNotifier<StylistState> {
  final Ref _ref;
  StylistNotifier(this._ref) : super(const StylistState()) {
    loadSavedOutfits();
  }

  final AiStylistService _stylistService = AiStylistService.instance;
  final DatabaseService _db = DatabaseService.instance;

  Future<void> loadSavedOutfits() async {
    try {
      final list = await _db.getOutfits();
      state = state.copyWith(
        savedOutfits: list,
        currentOutfit: state.currentOutfit ?? list.firstOrNull,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao carregar looks: $e');
    }
  }

  void setOccasion(String occasion) {
    state = state.copyWith(selectedOccasion: occasion);
  }

  void setVibe(String? vibe) {
    state = state.copyWith(selectedVibe: vibe);
  }

  /// Gera um novo look através da IA consumindo a cota diária
  Future<bool> generateOutfit(List<ClothingItem> wardrobe) async {
    final quotaState = _ref.read(quotaProvider);
    if (!quotaState.canGenerate) {
      state = state.copyWith(
        errorMessage: 'Limite diário de IA atingido. Assista a um vídeo rápido para liberar!',
      );
      return false;
    }

    state = state.copyWith(isGenerating: true, errorMessage: null);

    try {
      final outfit = await _stylistService.generateLook(
        occasion: state.selectedOccasion,
        availableClothes: wardrobe,
        vibePreference: state.selectedVibe,
      );

      // Consome cota de geração
      await _ref.read(quotaProvider.notifier).consume();

      // Salva automaticamente o look gerado no banco de dados SQLite
      await _db.insertOutfit(outfit);

      final updatedSaved = [outfit, ...state.savedOutfits];
      state = state.copyWith(
        isGenerating: false,
        currentOutfit: outfit,
        savedOutfits: updatedSaved,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> saveCurrentOutfit() async {
    if (state.currentOutfit == null) return;
    try {
      final updated = state.currentOutfit!.copyWith(isFavorite: true);
      await _db.insertOutfit(updated);
      await loadSavedOutfits();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao salvar look: $e');
    }
  }

  Future<void> deleteOutfit(String id) async {
    try {
      await _db.deleteOutfit(id);
      final updated = state.savedOutfits.where((o) => o.id != id).toList();
      state = state.copyWith(
        savedOutfits: updated,
        currentOutfit: state.currentOutfit?.id == id ? updated.firstOrNull : state.currentOutfit,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao excluir look: $e');
    }
  }
}

final stylistProvider = StateNotifierProvider<StylistNotifier, StylistState>((ref) {
  return StylistNotifier(ref);
});
