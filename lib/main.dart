import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'views/main_scaffold.dart';
import 'views/onboarding/onboarding_screen.dart';

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

  // Verifica se o usuário já completou o Onboarding de primeira abertura
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(
    ProviderScope(
      child: WardrobeAiApp(showOnboarding: !onboardingCompleted),
    ),
  );
}

class WardrobeAiApp extends StatelessWidget {
  final bool showOnboarding;

  const WardrobeAiApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wardrobe AI - Virtual Stylist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: showOnboarding ? const OnboardingScreen() : const MainScaffold(),
    );
  }
}
