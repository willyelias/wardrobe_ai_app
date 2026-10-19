import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/category.dart';
import '../../models/clothing_item.dart';
import '../../models/outfit.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/clothing_image_view.dart';
import '../calendar/schedule_look_dialog.dart';
import '../shop/shop_similar_dialog.dart';

class VirtualFittingScreen extends ConsumerStatefulWidget {
  const VirtualFittingScreen({super.key});

  @override
  ConsumerState<VirtualFittingScreen> createState() => _VirtualFittingScreenState();
}

class _VirtualFittingScreenState extends ConsumerState<VirtualFittingScreen> {
  final ImagePicker _picker = ImagePicker();
  ClothingCategory _selectedCategory = ClothingCategory.top;

  Future<void> _pickAvatarPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 2400,
        imageQuality: 88,
      );
      if (picked != null) {
        await ref.read(avatarProvider.notifier).saveAvatar(
              imagePath: picked.path,
              bodyType: 'Equilibrado',
              heightCm: 175.0,
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao capturar foto: $e')),
        );
      }
    }
  }

  void _showAvatarOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Foto do Seu Avatar de Corpo Inteiro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para melhor precisão no provador virtual, tire uma foto de pé, com boa iluminação e roupa ajustada.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryBlack),
              title: const Text('Tirar Foto Agora (Câmera)'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.pureWhite,
              onTap: () {
                Navigator.pop(context);
                _pickAvatarPhoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primaryBlack),
              title: const Text('Escolher da Galeria'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.pureWhite,
              onTap: () {
                Navigator.pop(context);
                _pickAvatarPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarState = ref.watch(avatarProvider);
    final wardrobe = ref.watch(wardrobeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Provador Virtual',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (avatarState.hasAvatar) ...[
            IconButton(
              tooltip: 'Limpar peças do provador',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.read(avatarProvider.notifier).clearFitting(),
            ),
            IconButton(
              tooltip: 'Alterar foto do avatar',
              icon: const Icon(Icons.camera_enhance_outlined),
              onPressed: _showAvatarOptionsSheet,
            ),
          ],
        ],
      ),
      body: avatarState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : !avatarState.hasAvatar
              ? _buildEmptyAvatarState()
              : _buildFittingRoomBody(avatarState, wardrobe.allClothes),
    );
  }

  Widget _buildEmptyAvatarState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.accessibility_new_rounded,
                size: 60,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Crie seu Avatar Digital',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tire uma foto de corpo inteiro para que a IA crie seu manequim digital e vista qualquer combinação de roupas no seu corpo real.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _pickAvatarPhoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text(
                  'Tirar Foto de Corpo Inteiro',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _pickAvatarPhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, color: AppColors.primaryBlack),
                label: const Text(
                  'Escolher Foto da Galeria',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlack,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFittingRoomBody(AvatarFittingState avatarState, List<ClothingItem> allItems) {
    final avatar = avatarState.avatar!;
    final categoryItems = allItems.where((i) => i.category == _selectedCategory).toList();

    return Column(
      children: [
        // Upper Canvas: Body Avatar + Interactive Overlaid Garment Pins
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full body avatar image
                  _buildAvatarImage(avatar.imagePath),

                  // Soft aesthetic gradient vignette
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),

                  // Interactive Garment Overlays / Fitted Tags
                  ..._buildFittedGarmentPins(avatarState),

                  // Bottom Overlay Controls
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 14, color: Colors.greenAccent),
                              const SizedBox(width: 6),
                              Text(
                                '${avatarState.activeItems.length} peças vestidas',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (avatarState.hasAnyEquipped)
                          ElevatedButton.icon(
                            onPressed: () {
                              final outfit = Outfit(
                                id: 'fitting_${DateTime.now().millisecondsSinceEpoch}',
                                name: 'Look do Provador Virtual',
                                occasion: 'Personalizado',
                                itemIds: avatarState.activeItems.map((i) => i.id).toList(),
                                items: avatarState.activeItems,
                                aiStylistNote: avatarState.fitFeedback ??
                                    'Montado no provador virtual com avatar personalizado.',
                                createdAt: DateTime.now(),
                              );
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (ctx) => ScheduleLookDialog(outfit: outfit),
                              );
                            },
                            icon: const Icon(Icons.calendar_today_rounded, size: 14),
                            label: const Text('Agendar Look'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryBlack,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // AI Fit analysis comment if available
        if (avatarState.fitFeedback != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: AppColors.accentBronze),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      avatarState.fitFeedback!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Bottom Selector: Categories
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ClothingCategory.values.map((cat) {
              final isSelected = _selectedCategory == cat;
              final isEquipped = avatarState.equippedItems[cat] != null;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: isEquipped
                      ? const Icon(Icons.check, size: 14, color: AppColors.pureWhite)
                      : null,
                  label: Text(cat.displayName),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() => _selectedCategory = cat);
                  },
                  backgroundColor: AppColors.pureWhite,
                  selectedColor: AppColors.primaryBlack,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.primaryBlack,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryBlack : AppColors.cardBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // Bottom Carousel: Clothes to try on
        Expanded(
          flex: 3,
          child: categoryItems.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma peça cadastrada em ${_selectedCategory.displayName}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: categoryItems.length,
                  itemBuilder: (context, index) {
                    final item = categoryItems[index];
                    final isEquipped =
                        avatarState.equippedItems[item.category]?.id == item.id;

                    return GestureDetector(
                      onTap: () {
                        if (isEquipped) {
                          ref.read(avatarProvider.notifier).unequipCategory(item.category);
                        } else {
                          ref.read(avatarProvider.notifier).equipItem(item);
                        }
                      },
                      child: Container(
                        width: 105,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isEquipped ? AppColors.primaryBlack : AppColors.cardBorder,
                            width: isEquipped ? 2.2 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: ClothingImageView(
                                        imagePath: item.imagePath,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  if (isEquipped)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryBlack,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    // High-fashion default avatar silhouette if file not yet uploaded
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 140,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }

  List<Widget> _buildFittedGarmentPins(AvatarFittingState avatarState) {
    final widgets = <Widget>[];

    // Define standard visual fitting anchors on body
    final positions = {
      ClothingCategory.top: const Alignment(0.75, -0.35),
      ClothingCategory.bottom: const Alignment(-0.75, 0.20),
      ClothingCategory.shoes: const Alignment(0.75, 0.70),
      ClothingCategory.outerwear: const Alignment(-0.75, -0.65),
      ClothingCategory.accessory: const Alignment(0.75, -0.75),
    };

    avatarState.equippedItems.forEach((cat, item) {
      if (item == null) return;
      final alignment = positions[cat] ?? Alignment.center;

      widgets.add(
        Align(
          alignment: alignment,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: ClothingImageView(imagePath: item.imagePath, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    Text(
                      item.category.displayName,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                // Shop similar button
                GestureDetector(
                  onTap: () => ShopSimilarDialog.show(context, item),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.shopping_bag_outlined, size: 16, color: AppColors.accentBronze),
                  ),
                ),
                // Remove item button
                GestureDetector(
                  onTap: () => ref.read(avatarProvider.notifier).unequipCategory(cat),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    return widgets;
  }
}
