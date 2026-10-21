import 'package:flutter/material.dart';

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
