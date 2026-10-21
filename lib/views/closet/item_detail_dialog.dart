import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../models/clothing_item.dart';
import '../../providers/color_season_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../services/color_season_service.dart';
import '../shop/shop_similar_dialog.dart';
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
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
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Foto da Peça com cantos arredondados
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
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
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 6),

                  Text(
                    '${item.category.displayName} • Cor: ${item.color} • Estação: ${item.season}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Alerta de Peça Esquecida
                  if (item.isForgotten) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFCC80)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.alarm, size: 18, color: Color(0xFFE65100)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Peça Esquecida: Não é usada há mais de 30 dias! Experimente incluí-la em um look hoje.',
                              style: TextStyle(fontSize: 12, color: Color(0xFFBF360C), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Métricas de Uso & Custo por Uso (CPW)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Usos Totais', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text('${item.wearCount}x', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryBlack)),
                          ],
                        ),
                        Container(height: 24, width: 1, color: AppColors.border),
                        Column(
                          children: [
                            const Text('Preço Pago', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text(
                              item.purchasePrice != null ? 'R\$ ${item.purchasePrice!.toStringAsFixed(2)}' : 'Não inf.',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryBlack),
                            ),
                          ],
                        ),
                        Container(height: 24, width: 1, color: AppColors.border),
                        Column(
                          children: [
                            const Text('Custo/Uso (CPW)', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text(
                              item.costPerWear != null ? 'R\$ ${item.costPerWear!.toStringAsFixed(2)}' : '-',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1B7A3D)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Coloração Pessoal Tag
                  Builder(builder: (context) {
                    final activePalette = ref.watch(colorSeasonProvider).currentSeason.name;
                    final colorEval = ColorSeasonService.instance.evaluateColor(item.color, activePalette);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorEval.isDirectMatch
                            ? const Color(0xFFE8F8EE)
                            : (colorEval.isUniversal ? const Color(0xFFF0F4F8) : const Color(0xFFFFF7ED)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 16,
                            color: colorEval.isDirectMatch
                                ? const Color(0xFF1B7A3D)
                                : (colorEval.isUniversal ? const Color(0xFF334E68) : const Color(0xFFB45309)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cartela $activePalette: ${colorEval.isDirectMatch ? 'Harmonia Perfeita' : (colorEval.isUniversal ? 'Cor Neutra Universal' : 'Fora da Cartela Principal')}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorEval.isDirectMatch
                                    ? const Color(0xFF1B7A3D)
                                    : (colorEval.isUniversal ? const Color(0xFF334E68) : const Color(0xFFB45309)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

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
                    const SizedBox(height: 16),
                  ],

                  // Ações Rápidas: Buscar em Lojas & Provar no Avatar
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlack,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                          label: const Text(
                            'Buscar em Lojas',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            ShopSimilarDialog.show(context, item);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlack,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.accessibility_new_rounded, size: 18),
                          label: const Text(
                            'Provar no Avatar',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            ref.read(avatarProvider.notifier).equipItem(item);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"${item.name}" adicionada ao seu Provador Virtual!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

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
            ),
          ),
        ],
      ),
    );
  }
}
