import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:productyivity_app/data/black_list_repository.dart';
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

  testWidgets('escribir añade líneas con viñeta sin botones externos', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.enterText(_editor, 'Comprar pan\nLlamar a Ana');
    await _flushSave(tester);

    final field = tester.widget<TextField>(_editor);
    // El campo pinta cada línea con su viñeta visible.
    expect(field.controller!.text, '• Comprar pan\n• Llamar a Ana');
    expect(find.textContaining('• Comprar pan'), findsOneWidget);
    expect(find.textContaining('• Llamar a Ana'), findsOneWidget);
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

    // En local se guarda el texto plano sin viñetas; la pantalla las vuelve a
    // pintar al restaurar.
    expect(
      tester.widget<TextField>(_editor).controller!.text,
      '• Comprar pan\n• Llamar a Ana',
    );
  });

  testWidgets('la viñeta se mantiene tras más escritura y salto de línea', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Primera línea corta (equivalentemente, ir escribiendo de a poco).
    await tester.enterText(_editor, 'Café');
    final field = tester.widget<TextField>(_editor);
    expect(field.controller!.text, '• Café');

    // Al escribir más sobre la misma línea la viñeta no se duplica.
    await tester.enterText(_editor, 'Café y té');
    expect(field.controller!.text, '• Café y té');

    // Un salto de línea abre una nueva línea con su propia viñeta.
    await tester.enterText(_editor, 'Café y té\nLlamar a mamá');
    expect(field.controller!.text, '• Café y té\n• Llamar a mamá');

    // Al volver a cargar la pantalla las viñetas se repintan desde el texto
    // plano guardado (sin «•»).
    await _flushSave(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(_editor).controller!.text,
      '• Café y té\n• Llamar a mamá',
    );
  });

  testWidgets('una línea vacía se borra sin que la viñeta reaparezca', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    String text() => tester.widget<TextField>(_editor).controller!.text;

    await tester.enterText(_editor, 'Nota');
    expect(text(), '• Nota');

    // Enter: abre una línea nueva, sin viñeta hasta que se escriba en ella.
    await tester.enterText(_editor, 'Nota\n');
    expect(text(), '• Nota\n');

    // Escribir en la línea nueva le da su viñeta.
    await tester.enterText(_editor, 'Nota\nLlamar');
    expect(text(), '• Nota\n• Llamar');

    // Al vaciar la línea se lleva la viñeta: no quedan viñetas huérfanas
    // (antes el texto se llenaba de «• •» que no se podían borrar).
    await tester.enterText(_editor, 'Nota\nLlam');
    expect(text(), '• Nota\n• Llam');
    await tester.enterText(_editor, 'Nota\nLla');
    await tester.enterText(_editor, 'Nota\nLl');
    await tester.enterText(_editor, 'Nota\nL');
    expect(text(), '• Nota\n• L');
    await tester.enterText(_editor, 'Nota\n');
    expect(text(), '• Nota\n');

    // Y una pulsación más elimina la línea entera.
    await tester.enterText(_editor, 'Nota');
    expect(text(), '• Nota');

    // En local queda el texto plano, sin viñetas.
    await _flushSave(tester);
    expect(await LocalBlackListRepository().load('ana@flowly.com'), 'Nota');
  });

  testWidgets('el cursor va tras la viñeta de su línea y las vacías no la recuperan', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final controller = tester.widget<TextField>(_editor).controller!;

    // Sin foco, el framework ignora la actualización: hay que enfocar antes
    // para que el campo reciba el texto (como al escribir a mano).
    await tester.tap(_editor);
    await tester.pumpAndSettle();

    // Escribir con el cursor en mitad de la línea (como al tocar el texto).
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'llamar a Ana',
        selection: TextSelection.collapsed(offset: 6),
      ),
    );
    await tester.pump();

    expect(controller.text, '• llamar a Ana');
    // El cursor conserva su posición relativa, ya tras la viñeta.
    expect(controller.selection.baseOffset, 8); // '• ' + 6

    // Escribir en una línea nueva le añade su viñeta.
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'llamar a Ana\nluego comprar pan',
        selection: TextSelection.collapsed(offset: 30),
      ),
    );
    await tester.pump();

    expect(controller.text, '• llamar a Ana\n• luego comprar pan');
    expect(controller.selection.baseOffset, controller.text.length);

    // Vaciar la línea se lleva su viñeta y el cursor se queda en esa línea.
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'llamar a Ana\n',
        selection: TextSelection.collapsed(offset: 13),
      ),
    );
    await tester.pump();

    expect(controller.text, '• llamar a Ana\n');
    expect(controller.selection.baseOffset, controller.text.length);

    // Borra el espacio de una viñeta suelta: la línea queda vacía de verdad,
    // sin que la viñeta reaparezca ni se acumulen («• •»).
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'llamar a Ana\n•',
        selection: TextSelection.collapsed(offset: 14),
      ),
    );
    await tester.pump();

    expect(controller.text, '• llamar a Ana\n');
    expect(controller.selection.baseOffset, controller.text.length);
  });

  testWidgets('el campo no pinta fondo propio (ni con foco ni sin él)', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Sin relleno se ve el papel de la pantalla en ambos estados.
    final decoration = tester.widget<TextField>(_editor).decoration!;
    expect(decoration.filled, isFalse);
    expect(decoration.enabledBorder, InputBorder.none);
    expect(decoration.focusedBorder, InputBorder.none);

    // Con el foco puesto el relleno sigue sin pintarse.
    await tester.tap(_editor);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(_editor).decoration!.filled, isFalse);
  });

  testWidgets('cada usuario tiene su propio texto guardado', (tester) async {
    await tester.pumpWidget(_harness(ownerId: 'ana@flowly.com'));
    await tester.pumpAndSettle();

    await tester.enterText(_editor, 'Nota de Ana');
    await _flushSave(tester);

    // Una sola línea también gana su viñeta.
    expect(
      tester.widget<TextField>(_editor).controller!.text,
      '• Nota de Ana',
    );

    // El apunte de Ana no aparece para Bob.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_harness(ownerId: 'bob@flowly.com'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(_editor).controller!.text, isEmpty);
  });
}