import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../models/clothing_item.dart';
import '../../models/outfit.dart';
import '../../providers/stylist_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/apple_card.dart';
import '../../widgets/clothing_image_view.dart';
import '../calendar/schedule_look_dialog.dart';

/// Card estilo Moodboard de Revista com as peças montadas pela IA
class LookDetailCard extends ConsumerWidget {
  final Outfit outfit;

  const LookDetailCard({super.key, required this.outfit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppleCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do Look
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        outfit.occasion.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      outfit.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  outfit.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: outfit.isFavorite ? AppColors.error : AppColors.textSecondary,
                ),
                onPressed: () {
                  ref.read(stylistProvider.notifier).saveCurrentOutfit();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Look salvo nos seus favoritos!'),
                      backgroundColor: AppColors.primary,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Moodboard das Peças Combinadas (Grid Flat Lay de Alta Moda)
          if (outfit.items.isNotEmpty)
            _buildMoodboardGrid(outfit.items)
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Peças associadas a esta combinação',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Análise e Dica do Personal Stylist (IA)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.sparkles,
                  color: AppColors.goldAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Curadoria do Stylist',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        outfit.aiStylistNote,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Ação: Agendar Look no Calendário
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => ScheduleLookDialog(outfit: outfit),
              );
            },
            icon: const Icon(CupertinoIcons.calendar_today, size: 18),
            label: const Text('Agendar no Calendário'),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodboardGrid(List<ClothingItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: ClothingImageView(
                  item: item,
                  borderRadius: 12,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                item.category.displayName,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
