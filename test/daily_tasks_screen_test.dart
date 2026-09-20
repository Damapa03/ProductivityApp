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

  testWidgets('permite editar una tarea desde su menú', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Crear la tarea.
    await tester.tap(find.text('+ Añadir tarea').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(find.text('Preparar café'), findsOneWidget);

    // Editar desde el menú de la tarjeta.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Preparar café con leche');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar café con leche'), findsOneWidget);
    expect(find.text('Preparar café'), findsNothing);
  });

  testWidgets('permite eliminar una tarea desde su menú', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Crear la tarea.
    await tester.tap(find.text('+ Añadir tarea').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(find.text('Preparar café'), findsOneWidget);

    // Eliminar desde el menú de la tarjeta.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    // Confirmar el borrado.
    expect(find.text('Eliminar tarea'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar café'), findsNothing);
  });

  testWidgets('no elimina la tarea si se cancela el diálogo', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Crear la tarea.
    await tester.tap(find.text('+ Añadir tarea').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Preparar café');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // Abrir el diálogo de borrado y cancelar.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar café'), findsOneWidget);
  });
}