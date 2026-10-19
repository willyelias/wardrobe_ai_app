import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/clothing_item.dart';
import '../theme/app_colors.dart';

/// Exibe a imagem da roupa com suporte para arquivos locais transparentes
/// e ilustrações estilizadas para peças de demonstração.
class ClothingImageView extends StatelessWidget {
  final ClothingItem? item;
  final String? imagePath;
  final ClothingCategory? category;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const ClothingImageView({
    super.key,
    this.item,
    this.imagePath,
    this.category,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 14,
  });

  String get _effectiveImagePath => item?.imagePath ?? imagePath ?? '';
  ClothingCategory get _effectiveCategory => item?.category ?? category ?? ClothingCategory.top;

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
    final path = _effectiveImagePath;

    if (path.isEmpty) {
      return _buildSampleIllustration();
    }

    // Caso seja uma peça de demonstração (seed inicial)
    if (path.startsWith('sample_')) {
      return _buildSampleIllustration();
    }

    // Caso seja foto real salva no dispositivo ou rede
    if (kIsWeb || path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildSampleIllustration(),
      );
    }

    final file = File(path);
    if (!file.existsSync()) {
      return _buildSampleIllustration();
    }

    return Image.file(
      file,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildSampleIllustration(),
    );
  }

  Widget _buildSampleIllustration() {
    IconData icon;
    Color iconColor;

    switch (_effectiveCategory) {
      case ClothingCategory.top:
        icon = CupertinoIcons.tag;
        iconColor = const Color(0xFF4A6572);
        break;
      case ClothingCategory.bottom:
        icon = CupertinoIcons.square_stack_3d_down_right;
        iconColor = const Color(0xFF34495E);
        break;
      case ClothingCategory.shoes:
        icon = CupertinoIcons.bolt_horizontal_circle;
        iconColor = const Color(0xFF2C3E50);
        break;
      case ClothingCategory.outerwear:
        icon = CupertinoIcons.shield;
        iconColor = const Color(0xFF16A085);
        break;
      case ClothingCategory.onePiece:
        icon = CupertinoIcons.person;
        iconColor = const Color(0xFFE67E22);
        break;
      case ClothingCategory.accessory:
        icon = CupertinoIcons.circle_grid_hex;
        iconColor = const Color(0xFF8E44AD);
        break;
    }

    return Center(
      child: Icon(
        icon,
        size: (width != null && width! < 60) ? 22 : 36,
        color: iconColor.withValues(alpha: 0.65),
      ),
    );
  }
}
