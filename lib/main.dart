import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/ad_manager.dart';
import 'theme/app_theme.dart';
import 'views/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa formatação de datas em Português
  try {
    await initializeDateFormatting('pt_BR', null);
  } catch (_) {}

  // Configura barra de status e navegação do sistema no estilo minimalista
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Carrega variáveis de ambiente do arquivo .env (se existir)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Aviso: Arquivo .env não encontrado ou vazio. Usando configurações padrão.');
  }

  // Inicializa o SDK do Google Mobile Ads (AdMob)
  await AdManager.instance.initialize();

  runApp(
    const ProviderScope(
      child: WardrobeAiApp(),
    ),
  );
}

class WardrobeAiApp extends StatelessWidget {
  const WardrobeAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wardrobe AI - Virtual Stylist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScaffold(),
    );
  }
}
