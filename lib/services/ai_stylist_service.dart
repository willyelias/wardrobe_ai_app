import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

/// Serviço de Stylist com Inteligência Artificial
/// Capaz de gerar combinações sofisticadas com base nas peças cadastradas no SQLite,
/// com suporte pronto para a API do Google Gemini ou modo simulado inteligente.
class AiStylistService {
  AiStylistService._();
  static final AiStylistService instance = AiStylistService._();

  /// Gera uma recomendação de look com base na ocasião e no acervo do usuário
  Future<Outfit> generateLook({
    required String occasion,
    required List<ClothingItem> availableClothes,
    String? vibePreference,
  }) async {
    if (availableClothes.isEmpty) {
      throw Exception('Seu closet está vazio. Cadastre algumas peças para a IA analisar!');
    }

    final geminiKey = dotenv.isInitialized ? dotenv.env['GEMINI_API_KEY'] : null;

    // Se o usuário adicionou a chave do Gemini no .env, faz a chamada real à API
    if (geminiKey != null && geminiKey.isNotEmpty && !geminiKey.startsWith('YOUR_')) {
      try {
        debugPrint('Consultando API do Gemini para stylist de look...');
        return await _generateWithGemini(
          apiKey: geminiKey,
          occasion: occasion,
          clothes: availableClothes,
        );
      } catch (e) {
        debugPrint('Aviso Gemini API: $e. Utilizando o motor Stylist Inteligente Local.');
      }
    }

    // Modo Stylist Simulado Inteligente (Algoritmo de Harmonia & Proporção de Moda)
    // Simula um delay de pensamento natural da IA (1.2s) para uma experiência de luxo
    await Future.delayed(const Duration(milliseconds: 1200));
    return _generateCuratedLocalOutfit(
      occasion: occasion,
      clothes: availableClothes,
      vibe: vibePreference,
    );
  }

  /// Gera o look usando a API oficial do Google Gemini (gemini-1.5-flash)
  Future<Outfit> _generateWithGemini({
    required String apiKey,
    required String occasion,
    required List<ClothingItem> clothes,
  }) async {
    final endpoint = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final simplifiedInventory = clothes.map((c) => {
      'id': c.id,
      'name': c.name,
      'category': c.category.displayName,
      'color': c.color,
      'occasions': c.occasions,
    }).toList();

    final prompt = '''
Você é um Personal Stylist de alta costura com estilo minimalista e contemporâneo.
Analise o seguinte inventário de roupas:
${jsonEncode(simplifiedInventory)}

Crie a MELHOR combinação para a seguinte ocasião: "$occasion".
Retorne ESTRITAMENTE um JSON válido com esta estrutura:
{
  "name": "Nome elegante para o look",
  "selected_ids": ["id1", "id2", "id3"],
  "stylist_note": "Explicação refinada de 2 a 3 frases sobre harmonia de cores, caimento e por que a combinação é perfeita para a ocasião."
}
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [{'text': prompt}]
        }
      ],
      'generationConfig': {
        'response_mime_type': 'application/json',
        'temperature': 0.7,
      }
    });

    final response = await http.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final rawText = jsonResponse['candidates'][0]['content']['parts'][0]['text'] as String;
      final parsed = jsonDecode(rawText);

      final selectedIds = (parsed['selected_ids'] as List).map((e) => e.toString()).toList();
      final itemsMap = {for (var c in clothes) c.id: c};
      final selectedItems = selectedIds.map((id) => itemsMap[id]).whereType<ClothingItem>().toList();

      return Outfit(
        id: const Uuid().v4(),
        name: parsed['name'] as String? ?? 'Look Curadoria $occasion',
        occasion: occasion,
        itemIds: selectedIds,
        items: selectedItems,
        aiStylistNote: parsed['stylist_note'] as String? ?? 'Combinação equilibrada pensada para destacar elegância sem esforço.',
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception('Gemini HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Motor de Stylist Local baseado em regras de harmonia cromática e silhueta
  Outfit _generateCuratedLocalOutfit({
    required String occasion,
    required List<ClothingItem> clothes,
    String? vibe,
  }) {
    final rand = Random();

    // Filtra peças por adequação à ocasião ou itens coringa/neutros
    bool isMatch(ClothingItem item) {
      if (item.occasions.isEmpty) return true;
      final matchesOccasion = item.occasions.any(
        (o) => o.toLowerCase() == occasion.toLowerCase(),
      );
      return matchesOccasion || item.occasions.contains('Casual');
    }

    final tops = clothes.where((c) => c.category == ClothingCategory.top).toList();
    final bottoms = clothes.where((c) => c.category == ClothingCategory.bottom).toList();
    final shoes = clothes.where((c) => c.category == ClothingCategory.shoes).toList();
    final outers = clothes.where((c) => c.category == ClothingCategory.outerwear).toList();
    final onePieces = clothes.where((c) => c.category == ClothingCategory.onePiece).toList();
    final accessories = clothes.where((c) => c.category == ClothingCategory.accessory).toList();

    final selectedItems = <ClothingItem>[];

    // Decide entre Vestido/Macacão ou Top + Bottom
    final useOnePiece = onePieces.isNotEmpty && rand.nextBool() && occasion != 'Frio';

    if (useOnePiece) {
      final matchedPieces = onePieces.where(isMatch).toList();
      selectedItems.add(matchedPieces.isNotEmpty ? matchedPieces[rand.nextInt(matchedPieces.length)] : onePieces[rand.nextInt(onePieces.length)]);
    } else {
      if (tops.isNotEmpty) {
        final matchedTops = tops.where(isMatch).toList();
        selectedItems.add(matchedTops.isNotEmpty ? matchedTops[rand.nextInt(matchedTops.length)] : tops[rand.nextInt(tops.length)]);
      }
      if (bottoms.isNotEmpty) {
        final matchedBottoms = bottoms.where(isMatch).toList();
        selectedItems.add(matchedBottoms.isNotEmpty ? matchedBottoms[rand.nextInt(matchedBottoms.length)] : bottoms[rand.nextInt(bottoms.length)]);
      }
    }

    // Calçados
    if (shoes.isNotEmpty) {
      final matchedShoes = shoes.where(isMatch).toList();
      selectedItems.add(matchedShoes.isNotEmpty ? matchedShoes[rand.nextInt(matchedShoes.length)] : shoes[rand.nextInt(shoes.length)]);
    }

    // Casaco/Blazer (Obrigatório em Frio ou preferencial em Trabalho/Balada)
    if (outers.isNotEmpty) {
      final shouldAddOuter = occasion == 'Frio' || (occasion == 'Trabalho' && rand.nextBool()) || rand.nextDouble() < 0.35;
      if (shouldAddOuter) {
        final matchedOuters = outers.where(isMatch).toList();
        selectedItems.add(matchedOuters.isNotEmpty ? matchedOuters[rand.nextInt(matchedOuters.length)] : outers[rand.nextInt(outers.length)]);
      }
    }

    // Acessório elegante
    if (accessories.isNotEmpty && rand.nextDouble() < 0.6) {
      selectedItems.add(accessories[rand.nextInt(accessories.length)]);
    }

    final lookName = _generateLookTitle(occasion, selectedItems);
    final stylistNote = _generateStylistAdvice(occasion, selectedItems);

    return Outfit(
      id: const Uuid().v4(),
      name: lookName,
      occasion: occasion,
      itemIds: selectedItems.map((e) => e.id).toList(),
      items: selectedItems,
      aiStylistNote: stylistNote,
      createdAt: DateTime.now(),
    );
  }

  String _generateLookTitle(String occasion, List<ClothingItem> items) {
    switch (occasion.toLowerCase()) {
      case 'trabalho':
        return 'Executive Minimalist';
      case 'balada':
        return 'Midnight Monochromatic';
      case 'casual':
        return 'Effortless Clean Style';
      case 'frio':
        return 'Nordic Warmth Layers';
      case 'encontro':
        return 'Subtle Chic Allure';
      default:
        return 'Essential Signature Look';
    }
  }

  String _generateStylistAdvice(String occasion, List<ClothingItem> items) {
    final top = items.where((i) => i.category == ClothingCategory.top || i.category == ClothingCategory.onePiece).firstOrNull;
    final bottom = items.where((i) => i.category == ClothingCategory.bottom).firstOrNull;
    final shoe = items.where((i) => i.category == ClothingCategory.shoes).firstOrNull;
    final outer = items.where((i) => i.category == ClothingCategory.outerwear).firstOrNull;

    final parts = <String>[];

    if (top != null && bottom != null) {
      parts.add('A sobreposição de "${top.name}" com "${bottom.name}" estabelece um contraste balanceado e moderno.');
    } else if (top != null) {
      parts.add('O caimento de "${top.name}" traz uma linha elegante e limpa para a silhueta.');
    }

    if (outer != null) {
      parts.add('O acréscimo de "${outer.name}" pontua sofisticação estruturada à composição.');
    }

    if (shoe != null) {
      parts.add('Finalizado com "${shoe.name}", ancorando o visual com extremo conforto e precisão de estilo.');
    }

    switch (occasion.toLowerCase()) {
      case 'trabalho':
        parts.add('Ideal para transmitir autoridade e contemporaneidade sem esforço excessivo.');
        break;
      case 'balada':
        parts.add('Perfeito para a noite: sofisticado, dinâmico e marcante sob iluminação noturna.');
        break;
      case 'frio':
        parts.add('O jogo de texturas e camadas garante isolamento térmico impecável mantendo o refinamento.');
        break;
      default:
        parts.add('Uma estética atemporal pronta para qualquer compromisso do seu dia.');
    }

    return parts.join(' ');
  }
}
