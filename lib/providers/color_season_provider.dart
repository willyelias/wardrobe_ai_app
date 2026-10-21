import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/color_season_service.dart';
import 'auth_provider.dart';

class ColorSeasonState {
  final ColorSeason currentSeason;
  final bool isAnalyzing;
  final ColorAnalysisResult? lastAnalysis;
  final File? selfieFile;

  const ColorSeasonState({
    required this.currentSeason,
    this.isAnalyzing = false,
    this.lastAnalysis,
    this.selfieFile,
  });

  ColorSeasonState copyWith({
    ColorSeason? currentSeason,
    bool? isAnalyzing,
    ColorAnalysisResult? lastAnalysis,
    File? selfieFile,
  }) {
    return ColorSeasonState(
      currentSeason: currentSeason ?? this.currentSeason,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      lastAnalysis: lastAnalysis ?? this.lastAnalysis,
      selfieFile: selfieFile ?? this.selfieFile,
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

  Future<ColorAnalysisResult> runPhotoAnalysis(File photoFile) async {
    state = state.copyWith(isAnalyzing: true);

    // Executa análise científica de pixels da face
    final result = await ColorSeasonService.instance.analyzeFacePhoto(photoFile);

    state = state.copyWith(
      currentSeason: result.season,
      lastAnalysis: result,
      selfieFile: photoFile,
      isAnalyzing: false,
    );

    // Salva no perfil do usuário de forma persistente
    await ref.read(authProvider.notifier).updateColorPalette(result.season.name);

    return result;
  }

  void selectSeason(String seasonName) {
    final season = ColorSeasonService.instance.getSeasonByName(seasonName);
    state = state.copyWith(currentSeason: season);

    // Persiste atualização no perfil
    ref.read(authProvider.notifier).updateColorPalette(season.name);
  }
}

final colorSeasonProvider = StateNotifierProvider<ColorSeasonNotifier, ColorSeasonState>((ref) {
  return ColorSeasonNotifier(ref);
});
