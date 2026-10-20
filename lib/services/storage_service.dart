import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Serviço responsável por persistir arquivos de imagem no armazenamento local do dispositivo
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  /// Salva uma imagem temporária (da câmera/galeria) no diretório permanente do app
  Future<String> saveImagePermanently(File sourceFile) async {
    if (kIsWeb) {
      return sourceFile.path;
    }
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final wardrobeDir = Directory(p.join(appDir.path, 'wardrobe_images'));
      if (!await wardrobeDir.exists()) {
        await wardrobeDir.create(recursive: true);
      }

      final ext = p.extension(sourceFile.path).isNotEmpty
          ? p.extension(sourceFile.path)
          : '.png';
      final fileName = 'piece_${const Uuid().v4()}$ext';
      final targetPath = p.join(wardrobeDir.path, fileName);

      final savedFile = await sourceFile.copy(targetPath);
      return savedFile.path;
    } catch (e) {
      debugPrint('Erro ao salvar imagem localmente: $e');
      return sourceFile.path;
    }
  }

  /// Remove arquivo de imagem do disco quando uma peça é deletada
  Future<void> deleteImage(String path) async {
    if (kIsWeb) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Aviso ao deletar imagem $path: $e');
    }
  }
}
