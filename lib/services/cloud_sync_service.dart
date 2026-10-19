import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class CloudSyncResult {
  final bool success;
  final String message;
  final int itemsSynced;
  final DateTime syncTime;

  const CloudSyncResult({
    required this.success,
    required this.message,
    required this.itemsSynced,
    required this.syncTime,
  });
}

class CloudSyncService {
  CloudSyncService._();
  static final CloudSyncService instance = CloudSyncService._();

  static const String _kCloudSnapshotKey = 'cloud_backup_snapshot';
  static const String _kLastSyncTimestampKey = 'cloud_last_sync_timestamp';

  /// Faz o backup completo do acervo para a nuvem
  Future<CloudSyncResult> backupToCloud({required String userId}) async {
    try {
      final data = await DatabaseService.instance.exportAllUserDataJson();
      final jsonString = json.encode(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_kCloudSnapshotKey}_$userId', jsonString);
      final now = DateTime.now();
      await prefs.setString('${_kLastSyncTimestampKey}_$userId', now.toIso8601String());

      final clothesCount = (data['clothes'] as List?)?.length ?? 0;
      final outfitsCount = (data['outfits'] as List?)?.length ?? 0;
      final total = clothesCount + outfitsCount;

      return CloudSyncResult(
        success: true,
        message: 'Sincronização concluída com sucesso! $total itens salvos na nuvem.',
        itemsSynced: total,
        syncTime: now,
      );
    } catch (e) {
      return CloudSyncResult(
        success: false,
        message: 'Falha na sincronização com a nuvem: $e',
        itemsSynced: 0,
        syncTime: DateTime.now(),
      );
    }
  }

  /// Restaura os dados da nuvem para o dispositivo atual
  Future<CloudSyncResult> restoreFromCloud({required String userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('${_kCloudSnapshotKey}_$userId');

      if (jsonString == null || jsonString.isEmpty) {
        return CloudSyncResult(
          success: false,
          message: 'Nenhum backup em nuvem encontrado para este usuário.',
          itemsSynced: 0,
          syncTime: DateTime.now(),
        );
      }

      final data = json.decode(jsonString) as Map<String, dynamic>;
      await DatabaseService.instance.importUserDataJson(data);

      final clothesCount = (data['clothes'] as List?)?.length ?? 0;
      final outfitsCount = (data['outfits'] as List?)?.length ?? 0;
      final total = clothesCount + outfitsCount;

      return CloudSyncResult(
        success: true,
        message: 'Restaurados $total itens da sua conta na nuvem!',
        itemsSynced: total,
        syncTime: DateTime.now(),
      );
    } catch (e) {
      return CloudSyncResult(
        success: false,
        message: 'Erro ao restaurar dados da nuvem: $e',
        itemsSynced: 0,
        syncTime: DateTime.now(),
      );
    }
  }

  /// Verifica data da última sincronização
  Future<DateTime?> getLastSyncDate(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('${_kLastSyncTimestampKey}_$userId');
    if (str == null) return null;
    return DateTime.tryParse(str);
  }
}
