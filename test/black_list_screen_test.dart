import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:productyivity_app/features/black_list/black_list_screen.dart';
import 'package:productyivity_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _harness({String ownerId = 'ana@flowly.com'}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlackListScreen(ownerId: ownerId),
  );
}

/// Campo de escritura libre de la lista negra.
final Finder _editor = find.byKey(const Key('black-list-editor'));

/// Espera a que el autoguardado (250 ms) escriba el texto en local.
Future<void> _flushSave(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('muestra la fecha de hoy y el título «Lista negra»', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final formatted = DateFormat('EEEE, d MMMM', 'es').format(DateTime.now());
    final dateText = formatted[0].toUpperCase() + formatted.substring(1);
    expect(find.text(dateText), findsOneWidget);
    expect(find.text('Lista negra'), findsOneWidget);
  });

  testWidgets('sin texto muestra la pista «Empieza a escribir…»', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Empieza a escribir…'), findsOneWidget);
    expect(tester.widget<TextField>(_editor).controller!.text, isEmpty);
  });

  testWidgets('escribir añade líneas al apunte sin botones externos', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.enterText(_editor, 'Comprar pan\nLlamar a Ana');
    await _flushSave(tester);

    final field = tester.widget<TextField>(_editor);
    expect(field.controller!.text, 'Comprar pan\nLlamar a Ana');
    // No hay botones externos: solo el campo de escritura.
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('el texto persiste al recrear la pantalla (reinicio)', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.enterText(_editor, 'Comprar pan\nLlamar a Ana');
    await _flushSave(tester);

    // Simula reiniciar la app: se reconstruye la pantalla desde cero.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(_editor).controller!.text,
      'Comprar pan\nLlamar a Ana',
    );
  });

  testWidgets('cada usuario tiene su propio texto guardado', (tester) async {
    await tester.pumpWidget(_harness(ownerId: 'ana@flowly.com'));
    await tester.pumpAndSettle();

    await tester.enterText(_editor, 'Nota de Ana');
    await _flushSave(tester);

    // El apunte de Ana no aparece para Bob.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_harness(ownerId: 'bob@flowly.com'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(_editor).controller!.text, isEmpty);
  });
}