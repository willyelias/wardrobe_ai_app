import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/clothing_item.dart';
import '../theme/app_colors.dart';

/// Exibe a imagem da roupa com suporte para arquivos locais transparentes
/// e ilustrações estilizadas para peças de demonstração.
class ClothingImageView extends StatelessWidget {
  final ClothingItem item;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const ClothingImageView({
    super.key,
    required this.item,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: AppColors.surfaceSubtle,
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    // Caso seja uma peça de demonstração (seed inicial)
    if (item.imagePath.startsWith('sample_')) {
      return _buildSampleIllustration();
    }

    // Caso seja foto real salva no dispositivo
    final file = File(item.imagePath);
    return Image.file(
      file,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildSampleIllustration(),
    );
  }

  Widget _buildSampleIllustration() {
    IconData icon;
    Color iconColor;

    switch (item.category) {
      case ClothingCategory.top:
        icon = CupertinoIcons.tag;
        iconColor = const Color(0xFF4A6572);
        break;
      case ClothingCategory.bottom:
        icon = CupertinoIcons.square_stack_3d_down_right;
        iconColor = const Color(0xFF34495E);
        break;
      case ClothingCategory.shoes:
        icon = CupertinoIcons.sparkles;
        iconColor = const Color(0xFF2C3E50);
        break;
      case ClothingCategory.outerwear:
        icon = CupertinoIcons.layers_alt;
        iconColor = const Color(0xFF1B2631);
        break;
      case ClothingCategory.onePiece:
        icon = CupertinoIcons.person;
        iconColor = const Color(0xFF5D6D7E);
        break;
      case ClothingCategory.accessory:
        icon = CupertinoIcons.eyeglasses;
        iconColor = const Color(0xFF7F8C8D);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: (height != null && height! < 100) ? 28 : 42,
              color: iconColor,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.color,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
