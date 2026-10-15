import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/clothing_image_view.dart';
import '../../widgets/custom_chip.dart';

/// Modal de detalhes e gerenciamento de uma peça individual
class ItemDetailDialog extends ConsumerWidget {
  final ClothingItem item;

  const ItemDetailDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de arraste Apple
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Foto da Peça com cantos arredondados
          Center(
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.softShadow,
              ),
              child: ClothingImageView(
                item: item,
                borderRadius: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Título e Categoria
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  item.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: item.isFavorite ? AppColors.error : AppColors.textSecondary,
                ),
                onPressed: () {
                  ref.read(wardrobeProvider.notifier).toggleFavorite(item);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            '${item.category.displayName} • Cor: ${item.color} • Estação: ${item.season}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Ocasiões
          if (item.occasions.isNotEmpty) ...[
            const Text(
              'Ocasiões recomendadas:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.occasions.map((o) {
                return CustomChip(
                  label: o,
                  isSelected: true,
                  onTap: () {},
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Botão Excluir Peça
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: Color(0xFFFFD2D0)),
            ),
            icon: const Icon(CupertinoIcons.trash, size: 18),
            label: const Text('Excluir do Guarda-Roupa'),
            onPressed: () async {
              final confirmed = await showCupertinoDialog<bool>(
                context: context,
                builder: (ctx) => CupertinoAlertDialog(
                  title: const Text('Excluir Peça'),
                  content: Text('Tem certeza que deseja remover "${item.name}" do seu closet?'),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: const Text('Cancelar'),
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: const Text('Excluir'),
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await ref.read(wardrobeProvider.notifier).deleteItem(item.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
