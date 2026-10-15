import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wardrobe_ai_app/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App renders main scaffold and 3 navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WardrobeAiApp(),
      ),
    );

    await tester.pump();

    // Verifica se as três abas estão visíveis
    expect(find.text('Closet'), findsWidgets);
    expect(find.text('IA Stylist'), findsOneWidget);
    expect(find.text('Calendário'), findsOneWidget);
  });
}
