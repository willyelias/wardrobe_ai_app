import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/category.dart';
import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/apple_card.dart';
import '../../widgets/clothing_image_view.dart';
import '../../widgets/custom_chip.dart';
import '../../widgets/empty_state.dart';
import 'add_item_sheet.dart';
import 'item_detail_dialog.dart';
import 'purchase_validator_dialog.dart';
import '../profile/profile_sheet.dart';

/// Aba 1: Closet Virtual (Inventário e Câmera com Remoção de Fundo)
class ClosetScreen extends ConsumerStatefulWidget {
  const ClosetScreen({super.key});

  @override
  ConsumerState<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends ConsumerState<ClosetScreen> {
  bool _showOnlyForgotten = false;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1600,
      );

      if (picked != null && context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => AddItemSheet(initialImageFile: File(picked.path)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir câmera ou galeria: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddPhotoSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Adicionar Peça ao Closet'),
        message: const Text('Tire uma foto clara da sua roupa ou escolha da sua biblioteca'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _pickImage(context, ImageSource.camera);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera, size: 20),
                SizedBox(width: 8),
                Text('Tirar Foto com a Câmera'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _pickImage(context, ImageSource.gallery);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo, size: 20),
                SizedBox(width: 8),
                Text('Escolher da Galeria'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeState = ref.watch(wardrobeProvider);
    var clothes = wardrobeState.filteredClothes;

    if (_showOnlyForgotten) {
      clothes = clothes.where((i) => i.isForgotten).toList();
    }

    final forgottenCount = wardrobeState.allClothes.where((i) => i.isForgotten).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Closet'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${clothes.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_outlined),
            tooltip: 'Devo Comprar? (Validador)',
            onPressed: () => PurchaseValidatorDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_outlined),
            tooltip: 'Conta & Nuvem',
            onPressed: () => ProfileSheet.show(context),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.slider_horizontal_3),
            tooltip: 'Recarregar',
            onPressed: () => ref.read(wardrobeProvider.notifier).loadClothes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPhotoSheet(context),
        icon: const Icon(CupertinoIcons.camera_fill, size: 20),
        label: const Text(
          'Nova Peça',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner de Alerta de Peças Esquecidas (se houver e não estiver filtrando)
          if (forgottenCount > 0 && !_showOnlyForgotten)
            InkWell(
              onTap: () => setState(() => _showOnlyForgotten = true),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm, size: 20, color: Color(0xFFEA580C)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Você tem $forgottenCount peças esquecidas (+30 dias sem uso)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9A3412),
                        ),
                      ),
                    ),
                    const Text(
                      'Ver',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFFEA580C)),
                  ],
                ),
              ),
            ),

          // Filtros Horizontais de Categoria + Filtro de Esquecidas
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CustomChip(
                    label: 'Todas',
                    isSelected: wardrobeState.selectedCategory == null && !_showOnlyForgotten,
                    onTap: () {
                      setState(() => _showOnlyForgotten = false);
                      ref.read(wardrobeProvider.notifier).selectCategory(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  CustomChip(
                    label: 'Esquecidas ($forgottenCount)',
                    icon: Icons.alarm,
                    isSelected: _showOnlyForgotten,
                    onTap: () {
                      setState(() => _showOnlyForgotten = !_showOnlyForgotten);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...ClothingCategory.values.map((cat) {
                    final isSel = wardrobeState.selectedCategory == cat && !_showOnlyForgotten;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CustomChip(
                        label: cat.displayName,
                        icon: cat.icon,
                        isSelected: isSel,
                        onTap: () {
                          setState(() => _showOnlyForgotten = false);
                          ref.read(wardrobeProvider.notifier).selectCategory(cat);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Conteúdo: Grid de Peças ou Estado Vazio
          Expanded(
            child: wardrobeState.isLoading
                ? const Center(child: CupertinoActivityIndicator(radius: 16))
                : clothes.isEmpty
                    ? EmptyState(
                        icon: _showOnlyForgotten ? Icons.alarm_off : CupertinoIcons.tag,
                        title: _showOnlyForgotten ? 'Nenhuma peça esquecida!' : 'Nenhuma peça encontrada',
                        description: _showOnlyForgotten
                            ? 'Parabéns! Você está aproveitando bem todas as roupas do seu armário.'
                            : 'Adicione suas primeiras peças usando a câmera ou escolha outra categoria.',
                        actionLabel: _showOnlyForgotten ? 'Ver Todas as Peças' : 'Fotografar Roupa',
                        onAction: _showOnlyForgotten
                            ? () => setState(() => _showOnlyForgotten = false)
                            : () => _showAddPhotoSheet(context),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.70,
                        ),
                        itemCount: clothes.length,
                        itemBuilder: (context, index) {
                          final item = clothes[index];
                          return _buildClothingCard(context, ref, item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildClothingCard(BuildContext context, WidgetRef ref, ClothingItem item) {
    return AppleCard(
      padding: EdgeInsets.zero,
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => ItemDetailDialog(item: item),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem da Peça com badges
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClothingImageView(
                    item: item,
                    borderRadius: 18,
                    fit: BoxFit.contain,
                  ),
                ),
                if (item.isFavorite)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppColors.softShadow,
                      ),
                      child: const Icon(
                        CupertinoIcons.heart_fill,
                        color: AppColors.error,
                        size: 14,
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category.displayName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                if (item.isForgotten)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFFCC80)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.alarm, size: 10, color: Color(0xFFE65100)),
                          SizedBox(width: 3),
                          Text(
                            'Esquecida',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Informações de texto
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      item.color,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (item.costPerWear != null)
                      Text(
                        'R\$ ${item.costPerWear!.toStringAsFixed(0)}/uso',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B7A3D),
                        ),
                      )
                    else if (item.wearCount > 0)
                      Text(
                        '${item.wearCount}x usado',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
