import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/color_season_provider.dart';
import '../../providers/stylist_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/weather_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/apple_card.dart';
import '../../widgets/custom_chip.dart';
import 'color_season_dialog.dart';
import 'look_detail_card.dart';

/// Aba IA Stylist: Gerador de Looks Inteligentes Ilimitados com Curadoria Pessoal
class StylistScreen extends ConsumerWidget {
  const StylistScreen({super.key});

  final List<String> _occasions = const [
    'Trabalho',
    'Balada',
    'Casual',
    'Frio',
    'Encontro',
    'Esporte',
  ];

  final List<String> _vibes = const [
    'Minimalista',
    'Elegante',
    'Moderno',
    'Confortável',
    'Marcante',
  ];

  void _onGenerate(BuildContext context, WidgetRef ref) async {
    final wardrobe = ref.read(wardrobeProvider).allClothes;
    if (wardrobe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seu closet está vazio! Adicione peças na Aba Closet para gerar looks.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final weather = ref.read(weatherProvider).valueOrNull;
    final colorPalette = ref.read(colorSeasonProvider).currentSeason.name;

    // Executa a geração de IA sem restrição ou anúncios, adaptada ao clima e cartela
    await ref.read(stylistProvider.notifier).generateOutfit(
      wardrobe,
      weather: weather,
      colorPalette: colorPalette,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stylistState = ref.watch(stylistProvider);
    final weatherAsync = ref.watch(weatherProvider);
    final colorSeasonState = ref.watch(colorSeasonProvider);
    final activeColorSeason = colorSeasonState.currentSeason;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('IA Stylist'),
        actions: [
          // Badge de Looks Ilimitados
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    size: 14,
                    color: AppColors.goldAccent,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Looks Ilimitados',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de Clima em Tempo Real + Cartela de Coloração Pessoal
            AppleCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Ícone e Temperatura do Clima
                      weatherAsync.when(
                        data: (w) => Row(
                          children: [
                            Text(w.icon, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${w.temperature.toStringAsFixed(0)}°C • ${w.condition}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  w.cityName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        loading: () => const Row(
                          children: [
                            CupertinoActivityIndicator(radius: 8),
                            SizedBox(width: 8),
                            Text('Obtendo clima...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                        error: (_, __) => const Row(
                          children: [
                            Text('🌤️', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text('Clima ameno', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Botão de Cartela de Cores
                      InkWell(
                        onTap: () => ColorSeasonDialog.show(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: activeColorSeason.palette.first.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: activeColorSeason.palette.first.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.face_retouching_natural_rounded, size: 14, color: activeColorSeason.palette.first),
                              const SizedBox(width: 5),
                              Text(
                                'Cartela: ${activeColorSeason.name}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.brown.shade800,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.chevron_right, size: 14, color: Colors.brown.shade800),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Dica de Styling Climático
                  weatherAsync.when(
                    data: (w) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wb_sunny_outlined, size: 14, color: AppColors.accentBronze),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                w.stylingAdvice,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Seção de Seleção de Ocasião
            const Text(
              'Escolha a Ocasião',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _occasions.map((occ) {
                  final isSel = stylistState.selectedOccasion == occ;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CustomChip(
                      label: occ,
                      isSelected: isSel,
                      onTap: () => ref.read(stylistProvider.notifier).setOccasion(occ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Filtro de Estilo / Vibe
            const Text(
              'Estilo / Vibe (Opcional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _vibes.map((vibe) {
                  final isSel = stylistState.selectedVibe == vibe;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CustomChip(
                      label: vibe,
                      isSelected: isSel,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      onTap: () {
                        ref.read(stylistProvider.notifier).setVibe(isSel ? null : vibe);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Botão Principal de Geração com IA
            ElevatedButton.icon(
              onPressed: stylistState.isGenerating ? null : () => _onGenerate(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: stylistState.isGenerating
                  ? const CupertinoActivityIndicator(color: Colors.white, radius: 10)
                  : const Icon(CupertinoIcons.sparkles, size: 20, color: AppColors.goldAccent),
              label: Text(
                stylistState.isGenerating
                    ? 'IA Analisando Guarda-Roupa...'
                    : 'Gerar Look Inteligente',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),

            // Mensagem de Erro (se houver)
            if (stylistState.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD2D2)),
                ),
                child: Text(
                  stylistState.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),

            // Look Sugerido Atual (Moodboard)
            if (stylistState.currentOutfit != null) ...[
              LookDetailCard(outfit: stylistState.currentOutfit!),
              const SizedBox(height: 16),

              // Card Informativo de Tendências da Moda (Substitui anúncios)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lightbulb_outline_rounded, color: Colors.amber.shade800, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dica de Styling',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Toque em qualquer peça do look acima para buscar modelos semelhantes ou preços nas maiores lojas online.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
