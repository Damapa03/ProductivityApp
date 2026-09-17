import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/features/daily_tasks/daily_tasks_screen.dart';
import 'package:productyivity_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _harness() {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const DailyTasksScreen(ownerId: 'ana@flowly.com'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('muestra las columnas por defecto en orden', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Search'), findsOneWidget);
    expect(find.text('TODO'), findsOneWidget);
    expect(find.text('Doing'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('permite añadir una tarea a una columna', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Añadir tarea').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar café'), findsOneWidget);
  });
}