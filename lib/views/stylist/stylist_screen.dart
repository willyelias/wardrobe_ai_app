import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quota_provider.dart';
import '../../providers/stylist_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_chip.dart';
import 'look_detail_card.dart';
import 'native_ad_fashion_card.dart';
import 'rewarded_ad_dialog.dart';

/// Aba 2: IA Stylist (Gerador de Looks Inteligentes com Monetização AdMob)
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

    final quota = ref.read(quotaProvider);
    if (!quota.canGenerate) {
      // Exibe modal para assistir a um vídeo de recompensa (Rewarded Ad)
      showDialog(
        context: context,
        builder: (ctx) => RewardedAdDialog(
          onRewardSuccess: () {
            ref.read(stylistProvider.notifier).generateOutfit(wardrobe);
          },
        ),
      );
      return;
    }

    // Executa a geração de IA
    await ref.read(stylistProvider.notifier).generateOutfit(wardrobe);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stylistState = ref.watch(stylistProvider);
    final quotaState = ref.watch(quotaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('IA Stylist'),
        actions: [
          // Contador de Cota Diária Elegante
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: quotaState.canGenerate ? AppColors.surfaceSubtle : const Color(0xFFFFE5E5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: quotaState.canGenerate ? AppColors.border : const Color(0xFFFFB3B3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    size: 14,
                    color: quotaState.canGenerate ? AppColors.goldAccent : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${quotaState.remaining} restantes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: quotaState.canGenerate ? AppColors.textPrimary : AppColors.error,
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
              const SizedBox(height: 8),

              // Espaço de Anúncio Nativo Minimalista (Monetização)
              const NativeAdFashionCard(),
            ],
          ],
        ),
      ),
    );
  }
}
