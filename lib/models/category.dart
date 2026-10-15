import 'package:flutter/cupertino.dart';

/// Categorias de roupas suportadas pelo Closet Inteligente
enum ClothingCategory {
  top,        // Camisas, Camisetas, Tops
  bottom,     // Calças, Bermudas, Saias
  shoes,      // Sapatos, Tênis, Sandálias
  outerwear,  // Casacos, Jaquetas, Blazers
  onePiece,   // Vestidos, Macacões
  accessory,  // Bolsas, Cintos, Relógios, Chapéus
}

extension ClothingCategoryExtension on ClothingCategory {
  String get displayName {
    switch (this) {
      case ClothingCategory.top:
        return 'Superior';
      case ClothingCategory.bottom:
        return 'Inferior';
      case ClothingCategory.shoes:
        return 'Calçados';
      case ClothingCategory.outerwear:
        return 'Casacos';
      case ClothingCategory.onePiece:
        return 'Peça Única';
      case ClothingCategory.accessory:
        return 'Acessórios';
    }
  }

  IconData get icon {
    switch (this) {
      case ClothingCategory.top:
        return CupertinoIcons.tag;
      case ClothingCategory.bottom:
        return CupertinoIcons.square_stack_3d_down_right;
      case ClothingCategory.shoes:
        return CupertinoIcons.sparkles;
      case ClothingCategory.outerwear:
        return CupertinoIcons.layers_alt;
      case ClothingCategory.onePiece:
        return CupertinoIcons.person;
      case ClothingCategory.accessory:
        return CupertinoIcons.eyeglasses;
    }
  }

  String toDbString() => name;

  static ClothingCategory fromDbString(String str) {
    return ClothingCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == str.toLowerCase(),
      orElse: () => ClothingCategory.top,
    );
  }
}
