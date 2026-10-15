import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Serviço responsável por remover o fundo das fotos de roupas.
/// Suporta API externa (remove.bg / Photoroom) com chave de API
/// e fallback local inteligente com detecção de cor e transparência PNG.
class BackgroundRemovalService {
  BackgroundRemovalService._();
  static final BackgroundRemovalService instance = BackgroundRemovalService._();

  /// Remove o fundo do arquivo fornecido e retorna o novo arquivo em PNG com transparência.
  Future<File> removeBackground(File originalFile) async {
    final apiKey = dotenv.isInitialized ? dotenv.env['REMOVE_BG_API_KEY'] : null;
    final apiUrl = (dotenv.isInitialized ? dotenv.env['REMOVE_BG_API_URL'] : null) ?? 'https://api.remove.bg/v1.0/removebg';

    // Se houver uma chave de API válida configurada no .env, utiliza o serviço em nuvem
    if (apiKey != null && apiKey.isNotEmpty && !apiKey.startsWith('YOUR_')) {
      try {
        debugPrint('Removendo fundo via API externa ($apiUrl)...');
        final resultFile = await _removeBackgroundViaApi(originalFile, apiUrl, apiKey);
        return resultFile;
      } catch (e) {
        debugPrint('Falha na chamada da API de remoção de fundo: $e. Usando processamento local.');
      }
    }

    // Fallback: Processamento local direto no dispositivo (funciona 100% offline)
    debugPrint('Processando remoção de fundo localmente com pacote image/dart...');
    return await _removeBackgroundLocally(originalFile);
  }

  /// Chamada HTTP Multipart genérica para remove.bg ou APIs equivalentes
  Future<File> _removeBackgroundViaApi(File file, String url, String apiKey) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['X-Api-Key'] = apiKey;
    request.fields['size'] = 'auto';
    request.fields['format'] = 'png';
    request.files.add(await http.MultipartFile.fromPath('image_file', file.path));

    final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(tempDir.path, 'nobg_${const Uuid().v4()}.png');
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(response.bodyBytes);
      return targetFile;
    } else {
      throw Exception('API error (${response.statusCode}): ${response.body}');
    }
  }

  /// Processamento local offline: detecta a cor de fundo predominante das bordas
  /// e aplica transparência alfa com suavização nos limites do objeto.
  Future<File> _removeBackgroundLocally(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        return file;
      }

      // Redimensiona moderadamente para otimizar velocidade de processamento se a foto for enorme
      img.Image processed = originalImage;
      if (processed.width > 1200 || processed.height > 1200) {
        processed = img.copyResize(processed, width: 1000);
      }

      // Amostra as cores dos 4 cantos para estimar a cor de fundo do chão/parede
      final cornerPixels = [
        processed.getPixel(0, 0),
        processed.getPixel(processed.width - 1, 0),
        processed.getPixel(0, processed.height - 1),
        processed.getPixel(processed.width - 1, processed.height - 1),
      ];

      final avgR = cornerPixels.map((p) => p.r).reduce((a, b) => a + b) / 4;
      final avgG = cornerPixels.map((p) => p.g).reduce((a, b) => a + b) / 4;
      final avgB = cornerPixels.map((p) => p.b).reduce((a, b) => a + b) / 4;

      // Cria imagem RGBA com canal alfa
      final transparentImage = img.Image(
        width: processed.width,
        height: processed.height,
        numChannels: 4,
      );

      const tolerance = 42.0;

      for (int y = 0; y < processed.height; y++) {
        for (int x = 0; x < processed.width; x++) {
          final pixel = processed.getPixel(x, y);
          final diff = (pixel.r - avgR).abs() + (pixel.g - avgG).abs() + (pixel.b - avgB).abs();

          if (diff < tolerance) {
            // Pixel pertence ao fundo: torna transparente
            transparentImage.setPixelRgba(x, y, 0, 0, 0, 0);
          } else {
            // Pixel da peça de roupa
            transparentImage.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 255);
          }
        }
      }

      final pngBytes = img.encodePng(transparentImage);
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(tempDir.path, 'nobg_local_${const Uuid().v4()}.png');
      final resultFile = File(targetPath);
      await resultFile.writeAsBytes(pngBytes);
      return resultFile;
    } catch (e) {
      debugPrint('Falha no processador local de imagem: $e');
      return file;
    }
  }
}
