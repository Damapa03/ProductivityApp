import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:productyivity_app/app/theme/colors.dart';
import 'package:productyivity_app/features/daily_schedule/daily_schedule_screen.dart';
import 'package:productyivity_app/features/daily_schedule/day_timeline.dart';
import 'package:productyivity_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _harness() {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const DailyScheduleScreen(ownerId: 'ana@flowly.com'),
  );
}

/// Toca el centro visible de la línea de tiempo para abrir el diálogo.
Future<void> _tapTimeline(WidgetTester tester) async {
  final timeline = find.byKey(const Key('day-timeline'));
  await tester.tapAt(tester.getCenter(timeline));
  await tester.pumpAndSettle();
}

/// Crea una franja tocando la línea de tiempo y confirmando el diálogo.
Future<void> _createEvent(WidgetTester tester, String title) async {
  await _tapTimeline(tester);
  await tester.enterText(find.byType(TextField), title);
  await tester.tap(find.text('Confirmar'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('muestra la fecha de hoy y el título «Plan de hoy»', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final formatted = DateFormat('EEEE, d MMMM', 'es').format(DateTime.now());
    final dateText = formatted[0].toUpperCase() + formatted.substring(1);
    expect(find.text(dateText), findsOneWidget);
    expect(find.text('Plan de hoy'), findsOneWidget);
  });

  testWidgets('muestra las 24 horas del día en formato 24 h', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    for (var h = 0; h < 24; h++) {
      final label = '${h.toString().padLeft(2, '0')}:00';
      expect(find.text(label), findsOneWidget, reason: 'falta la hora $label');
    }
  });

  testWidgets('la línea de tiempo se desplaza hacia la hora actual', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final position = tester
        .state<ScrollableState>(
          find.descendant(
            of: find.byType(DayTimeline),
            matching: find.byType(Scrollable),
          ),
        )
        .position;

    final now = DateTime.now();
    final target = (now.hour - 2) * DayTimeline.hourHeight;
    final expected = target
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    expect(position.pixels, expected);
  });

  testWidgets('el selector muestra Día y Semana y Semana no cambia la vista', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Día'), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);

    Color textColor(String label) =>
        tester.widget<Text>(find.text(label)).style!.color!;
    expect(textColor('Día'), const Color(0xFFF3F4EF));
    expect(textColor('Semana'), AppColors.inkSoft);

    // «Semana» está presente pero sin funcionalidad: tocarla no cambia nada.
    await tester.tap(find.text('Semana'));
    await tester.pumpAndSettle();

    expect(textColor('Día'), const Color(0xFFF3F4EF));
    expect(find.text('Plan de hoy'), findsOneWidget);
    expect(find.text('Próximamente'), findsNothing);
  });

  testWidgets('tocar la línea de tiempo abre el diálogo y crea una franja', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Ninguna franja todavía.
    expect(find.text('Deep work'), findsNothing);

    await _tapTimeline(tester);
    expect(find.text('Nueva tarea'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Deep work');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    // La franja se muestra en la línea de tiempo con su nombre.
    expect(find.text('Deep work'), findsOneWidget);
  });

  testWidgets('edita una franja desde su bloque', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await _createEvent(tester, 'Deep work');

    await tester.tap(find.text('Deep work'));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    // El diálogo llega pre-rellenado con el nombre actual.
    await tester.enterText(find.byType(TextField), 'Deep work 2');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Deep work 2'), findsOneWidget);
    expect(find.text('Deep work'), findsNothing);
  });

  testWidgets('elimina una franja desde su bloque', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await _createEvent(tester, 'Standup');

    await tester.tap(find.text('Standup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    // Confirmación del borrado.
    expect(find.text('Eliminar tarea'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Standup'), findsNothing);
  });

  testWidgets('no elimina la franja si se cancela la confirmación', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await _createEvent(tester, 'Gym');

    await tester.tap(find.text('Gym'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Gym'), findsOneWidget);
  });
}