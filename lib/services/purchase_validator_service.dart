import '../models/category.dart';
import '../models/clothing_item.dart';
import 'color_season_service.dart';

enum PurchaseVerdict { recommended, redundant, niche }

class PurchaseAnalysisResult {
  final PurchaseVerdict verdict;
  final String title;
  final String headline;
  final int matchingPiecesCount;
  final List<ClothingItem> compatiblePieces;
  final List<ClothingItem> similarPiecesAlreadyOwned;
  final ColorMatchEvaluation colorEvaluation;
  final double? estimatedCostPerWear;
  final String detailedAdvice;

  const PurchaseAnalysisResult({
    required this.verdict,
    required this.title,
    required this.headline,
    required this.matchingPiecesCount,
    required this.compatiblePieces,
    required this.similarPiecesAlreadyOwned,
    required this.colorEvaluation,
    this.estimatedCostPerWear,
    required this.detailedAdvice,
  });
}

class PurchaseValidatorService {
  PurchaseValidatorService._();
  static final PurchaseValidatorService instance = PurchaseValidatorService._();

  PurchaseAnalysisResult analyzeCandidate({
    required String name,
    required ClothingCategory category,
    required String color,
    double? price,
    required List<ClothingItem> allClothes,
    String userPalette = 'Outono Quente',
  }) {
    // 1. Verifica se já possui peças idênticas/similares na mesma categoria e cor
    final similarOwned = allClothes.where((i) {
      final sameCat = i.category == category;
      final sameColor = i.color.toLowerCase() == color.toLowerCase();
      return sameCat && sameColor;
    }).toList();

    // 2. Encontra peças compatíveis para montar looks
    final compatible = allClothes.where((i) {
      if (category == ClothingCategory.top) {
        return i.category == ClothingCategory.bottom || i.category == ClothingCategory.outerwear;
      } else if (category == ClothingCategory.bottom) {
        return i.category == ClothingCategory.top || i.category == ClothingCategory.shoes;
      } else if (category == ClothingCategory.shoes) {
        return i.category == ClothingCategory.bottom || i.category == ClothingCategory.top;
      } else {
        return i.category != category;
      }
    }).toList();

    // 3. Avalia com a cartela de coloração pessoal
    final colorEval = ColorSeasonService.instance.evaluateColor(color, userPalette);

    // 4. Projeta Custo por Uso (estimativa de 15 usos no ano)
    final double? cpw = price != null && price > 0 ? (price / 15.0) : null;

    PurchaseVerdict verdict;
    String title;
    String headline;
    String advice;

    if (similarOwned.length >= 2) {
      verdict = PurchaseVerdict.redundant;
      title = 'Atenção: Compra Redundante';
      headline = 'Você já possui ${similarOwned.length} peças muito semelhantes no closet.';
      advice = 'Considere se você realmente precisa de mais um(a) "$name" nessa mesma cor ($color). Se você usar pouco, o custo por uso será alto.';
    } else if (compatible.length >= 4) {
      verdict = PurchaseVerdict.recommended;
      title = 'Compra Excelente & Versátil!';
      headline = 'Combina com ${compatible.length} peças que você já tem no armário.';
      advice = 'Peça com altíssimo potencial de multiplicação de looks. Ela se integra com facilidade ao seu guarda-roupa atual e amplia suas opções.';
    } else {
      verdict = PurchaseVerdict.niche;
      title = 'Peça de Ocasião Específica';
      headline = 'Combina com ${compatible.length} peças atuais.';
      advice = 'Esta peça possui estilo mais pontual. Certifique-se de que você tem eventos ou ocasiões planejadas para utilizá-la com frequência.';
    }

    return PurchaseAnalysisResult(
      verdict: verdict,
      title: title,
      headline: headline,
      matchingPiecesCount: compatible.length,
      compatiblePieces: compatible.take(6).toList(),
      similarPiecesAlreadyOwned: similarOwned,
      colorEvaluation: colorEval,
      estimatedCostPerWear: cpw,
      detailedAdvice: advice,
    );
  }
}
