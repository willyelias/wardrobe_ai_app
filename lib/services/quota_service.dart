import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço responsável pelo controle de cota diária de gerações da IA Stylist
class QuotaService {
  QuotaService._();
  static final QuotaService instance = QuotaService._();

  static const String _prefPrefix = 'ai_gen_quota_';
  static const String _bonusKey = 'ai_gen_bonus_';

  int get maxDailyFreeGenerations {
    final configured = dotenv.isInitialized ? dotenv.env['DAILY_FREE_AI_GENERATIONS'] : null;
    return int.tryParse(configured ?? '') ?? 3;
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '$_prefPrefix${now.year}_${now.month}_${now.day}';
  }

  String _getTodayBonusKey() {
    final now = DateTime.now();
    return '$_bonusKey${now.year}_${now.month}_${now.day}';
  }

  /// Retorna quantas gerações gratuitas foram usadas hoje
  Future<int> getUsedGenerationsToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getTodayKey()) ?? 0;
  }

  /// Retorna quantos bônus (vídeos assistidos) foram obtidos hoje
  Future<int> getBonusGenerationsToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getTodayBonusKey()) ?? 0;
  }

  /// Modo Ilimitado Ativo (Sem limitação de looks)
  bool get isUnlimited => true;

  /// Retorna o número de gerações restantes disponíveis para hoje
  Future<int> getRemainingGenerationsToday() async {
    return 999;
  }

  /// Verifica se o usuário tem cota disponível
  Future<bool> canGenerate() async {
    return true; // Sempre permitido no modo ilimitado
  }

  /// Consome 1 geração do saldo do usuário
  Future<void> consumeGeneration() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
    debugPrint('Cota consumida. Total usado hoje: ${current + 1}');
  }

  /// Concede +1 geração bônus após o usuário assistir a um Rewarded Ad
  Future<void> grantBonusGeneration() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayBonusKey();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
    debugPrint('Bônus de geração concedido via anúncio! Bônus acumulados hoje: ${current + 1}');
  }
}
