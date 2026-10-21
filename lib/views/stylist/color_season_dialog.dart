import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/color_season_provider.dart';
import '../../services/color_season_service.dart';
import '../../theme/app_colors.dart';

class ColorSeasonDialog extends ConsumerStatefulWidget {
  const ColorSeasonDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ColorSeasonDialog(),
    );
  }

  @override
  ConsumerState<ColorSeasonDialog> createState() => _ColorSeasonDialogState();
}

class _ColorSeasonDialogState extends ConsumerState<ColorSeasonDialog> {
  int _selectedUndertone = 1; // 1 = Quente (Dourado/Oliva), 0 = Frio (Rosado/Azulado)
  int _selectedIntensity = 0; // 0 = Suave/Opaco, 1 = Intenso/Brilhante

  Widget _buildOptionTile({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primaryBlack : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seasonState = ref.watch(colorSeasonProvider);
    final activeSeason = seasonState.currentSeason;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.palette_outlined, size: 18, color: AppColors.accentBronze),
                          const SizedBox(width: 8),
                          Text(
                            'COLORAÇÃO PESSOAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Descubra sua Cartela de Cores',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Active season highlight banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            activeSeason.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Cartela Ativa',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeSeason.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Swatches
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: activeSeason.sampleColors.map((color) {
                          return Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        activeSeason.description,
                        style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Diagnostic Quiz
                const Text(
                  'Teste Rápido de Temperatura & Contraste',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),

                // Question 1: Undertone
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Suas veias no pulso e sua reação ao sol:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      _buildOptionTile(
                        title: 'Veias esverdeadas / Pego bronzeado com facilidade (Quente)',
                        isSelected: _selectedUndertone == 1,
                        onTap: () {
                          setState(() => _selectedUndertone = 1);
                          _updateCalculatedSeason();
                        },
                      ),
                      _buildOptionTile(
                        title: 'Veias azuladas ou arroxeadas / Queimo antes de bronzear (Frio)',
                        isSelected: _selectedUndertone == 0,
                        onTap: () {
                          setState(() => _selectedUndertone = 0);
                          _updateCalculatedSeason();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Question 2: Intensity
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2. O contraste entre sua pele, olhos e cabelos:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      _buildOptionTile(
                        title: 'Contraste suave / Tons que se mesclam com naturalidade (Suave)',
                        isSelected: _selectedIntensity == 0,
                        onTap: () {
                          setState(() => _selectedIntensity = 0);
                          _updateCalculatedSeason();
                        },
                      ),
                      _buildOptionTile(
                        title: 'Contraste marcante / Olhos e cabelos bem definidos (Intenso/Brilhante)',
                        isSelected: _selectedIntensity == 1,
                        onTap: () {
                          setState(() => _selectedIntensity = 1);
                          _updateCalculatedSeason();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // All 4 seasons selector chips
                const Text(
                  'Ou escolha manualmente sua cartela:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),

                ...ColorSeasonService.allSeasons.map((season) {
                  final isSelected = season.name == activeSeason.name;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        ref.read(colorSeasonProvider.notifier).selectSeason(season.name);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber.shade50 : AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? Colors.amber.shade700 : AppColors.cardBorder,
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              season.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 14,
                                color: isSelected ? Colors.amber.shade900 : AppColors.primaryBlack,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: season.sampleColors.take(4).map((c) {
                                return Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                                );
                              }).toList(),
                            ),
                            const SizedBox(width: 8),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, size: 18, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateCalculatedSeason() {
    final calculated = ColorSeasonService.instance.determineSeason(
      undertoneScore: _selectedUndertone,
      intensityScore: _selectedIntensity,
    );
    ref.read(colorSeasonProvider.notifier).selectSeason(calculated);
  }
}
