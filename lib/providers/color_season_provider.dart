import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/color_season_service.dart';
import 'auth_provider.dart';

class ColorSeasonState {
  final ColorSeason currentSeason;
  final bool isAnalyzing;

  const ColorSeasonState({
    required this.currentSeason,
    this.isAnalyzing = false,
  });

  ColorSeasonState copyWith({
    ColorSeason? currentSeason,
    bool? isAnalyzing,
  }) {
    return ColorSeasonState(
      currentSeason: currentSeason ?? this.currentSeason,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }
}

class ColorSeasonNotifier extends StateNotifier<ColorSeasonState> {
  ColorSeasonNotifier(this.ref)
      : super(ColorSeasonState(
          currentSeason: ColorSeasonService.instance.getSeasonByName('Outono Quente'),
        )) {
    _initFromUser();
  }

  final Ref ref;

  void _initFromUser() {
    final user = ref.read(authProvider).user;
    if (user.colorPalette != null && user.colorPalette!.isNotEmpty) {
      final season = ColorSeasonService.instance.getSeasonByName(user.colorPalette);
      state = state.copyWith(currentSeason: season);
    }
  }

  void selectSeason(String seasonName) {
    final season = ColorSeasonService.instance.getSeasonByName(seasonName);
    state = state.copyWith(currentSeason: season);

    // Salva no perfil do usuário
    final authNotifier = ref.read(authProvider.notifier);
    final currentUser = ref.read(authProvider).user;
    final updated = currentUser.copyWith(colorPalette: season.name);
    // Persiste atualização
    authNotifier.signInWithGoogle(name: updated.displayName, email: updated.email);
  }
}

final colorSeasonProvider = StateNotifierProvider<ColorSeasonNotifier, ColorSeasonState>((ref) {
  return ColorSeasonNotifier(ref);
});
