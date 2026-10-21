import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ColorSeason {
  final String name;
  final String subtitle;
  final String description;
  final List<Color> sampleColors;
  final List<String> bestColorNames;
  final List<String> avoidColorNames;

  const ColorSeason({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.sampleColors,
    required this.bestColorNames,
    required this.avoidColorNames,
  });

  List<Color> get palette => sampleColors;
}

class ColorSeasonService {
  ColorSeasonService._();
  static final ColorSeasonService instance = ColorSeasonService._();

  static const List<ColorSeason> allSeasons = [
    ColorSeason(
      name: 'Outono Quente',
      subtitle: 'Tons terrosos, dourados e acolhedores',
      description: 'Valoriza contrastes suaves e temperaturas quentes. Realça pele com fundo dourado ou oliva.',
      sampleColors: [
        Color(0xFFC0392B), // Terracota
        Color(0xFFD35400), // Ferrugem
        Color(0xFFB7950B), // Mostarda
        Color(0xFF1E8449), // Oliva
        Color(0xFF6E2C00), // Marrom Café
        Color(0xFFF5B041), // Ocre
      ],
      bestColorNames: ['Terracota', 'Mostarda', 'Oliva', 'Marrom', 'Bege', 'Cobre', 'Vinho', 'Verde Militar'],
      avoidColorNames: ['Cinza Chumbo', 'Prata', 'Azul Elétrico', 'Rosa Choque'],
    ),
    ColorSeason(
      name: 'Inverno Escuro',
      subtitle: 'Cores profundas, puras e contrastantes',
      description: 'Valoriza contrastes intensos entre pele, olhos e cabelos. Combina perfeitamente com pretos puros e joias.',
      sampleColors: [
        Color(0xFF17202A), // Preto Profundo
        Color(0xFFFFFFFF), // Branco Puro
        Color(0xFF922B21), // Rubi
        Color(0xFF1B4F72), // Azul Marinho
        Color(0xFF117A65), // Esmeralda
        Color(0xFF512E5F), // Púrpura Real
      ],
      bestColorNames: ['Preto', 'Branco', 'Azul Marinho', 'Vinho', 'Esmeralda', 'Cinza Escuro', 'Vermelho'],
      avoidColorNames: ['Laranja Queimado', 'Mostarda', 'Tons Pastéis Apagados'],
    ),
    ColorSeason(
      name: 'Primavera Brilhante',
      subtitle: 'Cores vibrantes, alegres e luminosas',
      description: 'Valoriza claridade e vivacidade. Ilumina peles radiantes com tons quentes e alegres.',
      sampleColors: [
        Color(0xFFE74C3C), // Coral
        Color(0xFF1ABC9C), // Turquesa
        Color(0xFFF1C40F), // Amarelo Ouro
        Color(0xFF2ECC71), // Verde Maçã
        Color(0xFFF39C12), // Pêssego
        Color(0xFFE67E22), // Tangerina
      ],
      bestColorNames: ['Coral', 'Turquesa', 'Amarelo', 'Verde Claro', 'Pêssego', 'Off-White', 'Azul Céu'],
      avoidColorNames: ['Preto Total', 'Cinza Escuro', 'Marrom Opaco'],
    ),
    ColorSeason(
      name: 'Verão Suave',
      subtitle: 'Tons frios, suaves e elegantes',
      description: 'Valoriza sutileza, delicadeza e elegância atemporal. Realça tons frios e rosados.',
      sampleColors: [
        Color(0xFF85929E), // Azul Acinzentado
        Color(0xFFBB8FCE), // Lavanda
        Color(0xFFD5D8DC), // Cinza Mescla
        Color(0xFFE8DAEF), // Rosa Seco
        Color(0xFFA2D9CE), // Menta Suave
        Color(0xFF5499C7), // Azul Jeans
      ],
      bestColorNames: ['Azul Jeans', 'Lavanda', 'Cinza Mescla', 'Rosa Seco', 'Menta', 'Azul Pastel'],
      avoidColorNames: ['Laranja Neon', 'Dourado Amarelado', 'Preto Pesado'],
    ),
  ];

  ColorSeason getSeasonByName(String? name) {
    if (name == null || name.isEmpty) return allSeasons.first;
    return allSeasons.firstWhere(
      (s) => s.name.toLowerCase() == name.toLowerCase(),
      orElse: () => allSeasons.first,
    );
  }

  /// Avalia a harmonia cromática de uma peça com a cartela do usuário
  ColorMatchEvaluation evaluateColor(String colorName, String userPaletteName) {
    final season = getSeasonByName(userPaletteName);
    final lowerColor = colorName.toLowerCase();

    bool isBest = season.bestColorNames.any((b) => lowerColor.contains(b.toLowerCase()) || b.toLowerCase().contains(lowerColor));
    bool isAvoid = season.avoidColorNames.any((a) => lowerColor.contains(a.toLowerCase()) || a.toLowerCase().contains(lowerColor));

    if (isBest) {
      return const ColorMatchEvaluation(
        isHarmonious: true,
        matchType: '✦ Destaque na Sua Cartela',
        comment: 'Essa tonalidade ilumina seu rosto e valoriza o contraste natural do seu biotipo.',
        badgeColor: Color(0xFF27AE60),
      );
    } else if (isAvoid) {
      return const ColorMatchEvaluation(
        isHarmonious: false,
        matchType: '✦ Contraste Oposto',
        comment: 'Cor fora da sua paleta primária. Dica: use com uma terceira peça próxima ao rosto para equilibrar.',
        badgeColor: Color(0xFFE67E22),
      );
    } else {
      return const ColorMatchEvaluation(
        isHarmonious: true,
        matchType: '✦ Neutro Versátil',
        comment: 'Tom neutro que combina com qualquer estação e serve como excelente base para looks.',
        badgeColor: Color(0xFF7F8C8D),
      );
    }
  }

  /// Calcula a cartela a partir de respostas do teste de coloração
  String determineSeason({
    required int undertoneScore, // 0 = Frio, 1 = Quente
    required int intensityScore, // 0 = Suave, 1 = Intenso
  }) {
    if (undertoneScore == 1 && intensityScore == 0) {
      return 'Outono Quente';
    } else if (undertoneScore == 1 && intensityScore == 1) {
      return 'Primavera Brilhante';
    } else if (undertoneScore == 0 && intensityScore == 1) {
      return 'Inverno Escuro';
    } else {
      return 'Verão Suave';
    }
  }

  /// Análise Facial por Foto (Selfie): Extrai tons da pele, contraste e detecta a cartela ideal
  Future<ColorAnalysisResult> analyzeFacePhoto(File photoFile) async {
    try {
      final bytes = await photoFile.readAsBytes();
      final decoded = img.decodeImage(bytes);

      if (decoded != null) {
        final w = decoded.width;
        final h = decoded.height;

        // Amostra região do rosto (bochechas / centro facial: 35% a 65% de largura e 35% a 60% de altura)
        double totalR = 0, totalG = 0, totalB = 0;
        int skinPixelCount = 0;

        final startX = (w * 0.35).toInt();
        final endX = (w * 0.65).toInt();
        final startY = (h * 0.35).toInt();
        final endY = (h * 0.60).toInt();

        for (int y = startY; y < endY; y += 4) {
          for (int x = startX; x < endX; x += 4) {
            final p = decoded.getPixel(x, y);
            totalR += p.r;
            totalG += p.g;
            totalB += p.b;
            skinPixelCount++;
          }
        }

        final avgR = skinPixelCount > 0 ? (totalR / skinPixelCount) : 180.0;
        final avgG = skinPixelCount > 0 ? (totalG / skinPixelCount) : 140.0;
        final avgB = skinPixelCount > 0 ? (totalB / skinPixelCount) : 120.0;

        // Amostra região do cabelo / sobrancelhas (topo central: 30% a 70% de largura, 12% a 25% de altura)
        double hairR = 0, hairG = 0, hairB = 0;
        int hairPixelCount = 0;
        final hairStartY = (h * 0.12).toInt();
        final hairEndY = (h * 0.25).toInt();

        for (int y = hairStartY; y < hairEndY; y += 4) {
          for (int x = startX; x < endX; x += 4) {
            final p = decoded.getPixel(x, y);
            hairR += p.r;
            hairG += p.g;
            hairB += p.b;
            hairPixelCount++;
          }
        }

        final avgHairR = hairPixelCount > 0 ? (hairR / hairPixelCount) : 50.0;
        final avgHairG = hairPixelCount > 0 ? (hairG / hairPixelCount) : 40.0;
        final avgHairB = hairPixelCount > 0 ? (hairB / hairPixelCount) : 35.0;

        // Luminosidade Relativa (Perceived Luminance)
        final skinLum = 0.299 * avgR + 0.587 * avgG + 0.114 * avgB;
        final hairLum = 0.299 * avgHairR + 0.587 * avgHairG + 0.114 * avgHairB;
        final contrastDelta = (skinLum - hairLum).abs();

        // Análise de Subtom: Razão Quente (Vermelho/Amarelo) vs Frio (Azul/Rosa)
        final warmthRatio = (avgR - avgB) / (avgR + avgG + avgB + 1e-5);
        final bool isWarm = warmthRatio > 0.18 || (avgR > avgB * 1.35);

        String contrastLevel;
        if (contrastDelta > 65) {
          contrastLevel = 'Contraste Alto';
        } else if (contrastDelta > 35) {
          contrastLevel = 'Contraste Médio';
        } else {
          contrastLevel = 'Contraste Suave';
        }

        String seasonName;
        String undertoneDesc;
        String metalsAdvice;
        String makeupAdvice;
        String reason;

        if (isWarm) {
          undertoneDesc = 'Quente (Fundo Dourado / Pêssego)';
          metalsAdvice = 'Ouro Amarelo, Ouro Rosé e Cobre';
          if (contrastDelta > 55 || skinLum > 170) {
            seasonName = 'Primavera Brilhante';
            reason = 'Sua pele irradia luminosidade com tons vivos, claros e alegres.';
            makeupAdvice = 'Batons coral, pêssego e sombras champanhe e bronze dourado.';
          } else {
            seasonName = 'Outono Quente';
            reason = 'Sua pele tem excelente harmonia com tons terrosos, mostarda e oliva.';
            makeupAdvice = 'Batons terracota, nude quente, marrom canela e sombras acobreadas.';
          }
        } else {
          undertoneDesc = 'Frio (Fundo Rosado / Azulado)';
          metalsAdvice = 'Prata 925, Ródio e Ouro Branco';
          if (contrastDelta > 50) {
            seasonName = 'Inverno Escuro';
            reason = 'Seu contraste facial é marcante e se destaca com pretos puros, brancos ópticos e cores joia.';
            makeupAdvice = 'Batons vinho, rubi intenso, cereja e delineados bem definidos.';
          } else {
            seasonName = 'Verão Suave';
            reason = 'Sua beleza é valorizada por tons delicados, frios e levemente acinzentados ou pastéis.';
            makeupAdvice = 'Batons rosa seco, malva e sombras lavanda, grafite ou cinza suave.';
          }
        }

        final season = getSeasonByName(seasonName);
        final sampleColor = Color.fromARGB(
          255,
          avgR.round().clamp(0, 255),
          avgG.round().clamp(0, 255),
          avgB.round().clamp(0, 255),
        );

        return ColorAnalysisResult(
          season: season,
          undertone: undertoneDesc,
          contrast: contrastLevel,
          skinSampleColor: sampleColor,
          explanation: reason,
          metalsRecommendation: metalsAdvice,
          makeupAndHairAdvice: makeupAdvice,
          isWarm: isWarm,
        );
      }
    } catch (e) {
      debugPrint('Aviso análise de imagem: $e. Utilizando diagnóstico padrão.');
    }

    final season = getSeasonByName('Outono Quente');
    return ColorAnalysisResult(
      season: season,
      undertone: 'Quente (Fundo Dourado/Oliva)',
      contrast: 'Contraste Médio',
      skinSampleColor: const Color(0xFFD4A373),
      explanation: 'Sua pele harmoniza naturalmente com tons terrosos, mostarda e oliva.',
      metalsRecommendation: 'Ouro Amarelo, Ouro Rosé e Cobre',
      makeupAndHairAdvice: 'Batons nude quente, terracota e marrom canela.',
      isWarm: true,
    );
  }
}

class ColorAnalysisResult {
  final ColorSeason season;
  final String undertone;
  final String contrast;
  final Color skinSampleColor;
  final String explanation;
  final String metalsRecommendation;
  final String makeupAndHairAdvice;
  final bool isWarm;

  const ColorAnalysisResult({
    required this.season,
    required this.undertone,
    required this.contrast,
    required this.skinSampleColor,
    required this.explanation,
    required this.metalsRecommendation,
    required this.makeupAndHairAdvice,
    required this.isWarm,
  });
}

class ColorMatchEvaluation {
  final bool isHarmonious;
  final String matchType;
  final String comment;
  final Color badgeColor;

  const ColorMatchEvaluation({
    required this.isHarmonious,
    required this.matchType,
    required this.comment,
    required this.badgeColor,
  });

  bool get isDirectMatch => isHarmonious && matchType.contains('Destaque');
  bool get isUniversal => isHarmonious && matchType.contains('Neutro');
  String get explanation => comment;
}
