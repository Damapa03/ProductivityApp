import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:productyivity_app/app/theme/colors.dart';
import 'package:productyivity_app/data/schedule_repository.dart';
import 'package:productyivity_app/features/daily_schedule/daily_schedule_screen.dart';
import 'package:productyivity_app/features/daily_schedule/day_timeline.dart';
import 'package:productyivity_app/l10n/app_localizations.dart';
import 'package:productyivity_app/models/daily_schedule.dart';
import 'package:productyivity_app/models/schedule_event.dart';
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

/// Bloque (Positioned) de la franja con [id] en la línea de tiempo.
Positioned _block(WidgetTester tester, String id) => tester.widget<Positioned>(
  find.byKey(ValueKey('event-block-$id')),
);

/// Posición del bloque de la franja [id] entre los `Positioned` del Stack de
/// la línea de tiempo: el orden equivale al orden de pintado (más tarde =
/// encima).
int _blockIndex(WidgetTester tester, String id) {
  final timelineStack = find.ancestor(
    of: find.byKey(ValueKey('event-block-$id')),
    matching: find.byType(Stack),
  );
  final positioned = find.descendant(
    of: timelineStack,
    matching: find.byType(Positioned),
  );
  final elements = positioned.evaluate().toList();
  return elements.indexWhere(
    (element) =>
        (element.widget as Positioned).key == ValueKey('event-block-$id'),
  );
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

  testWidgets('muestra la línea de la hora actual', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final line = tester.widget<Positioned>(find.byKey(const Key('now-line')));
    final now = DateTime.now();
    final expected = DayTimeline.offsetFor(now).clamp(0.0, DayTimeline.totalHeight);
    expect(line.height, 2);
    expect(line.top, closeTo(expected, 1.0));
  });

  testWidgets(
    'las franjas de la misma hora se reparten el ancho en franjas verticales',
    (tester) async {
      final now = DateTime.now();
      final day = DateTime(now.year, now.month, now.day);
      final repo = LocalScheduleRepository();
      await repo.save(
        'ana@flowly.com',
        DailySchedule(ownerId: 'ana@flowly.com', events: [
          ScheduleEvent(
            id: 'a',
            title: 'Tarea A',
            start: day.add(const Duration(hours: 10)),
            end: day.add(const Duration(hours: 11)),
          ),
          ScheduleEvent(
            id: 'b',
            title: 'Tarea B',
            start: day.add(const Duration(hours: 10)),
            end: day.add(const Duration(hours: 11)),
          ),
        ]),
      );

      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Tarea A'), findsOneWidget);
      expect(find.text('Tarea B'), findsOneWidget);

      final a = tester.widget<Positioned>(find.byKey(const Key('event-block-a')));
      final b = tester.widget<Positioned>(find.byKey(const Key('event-block-b')));
      // Mismo intervalo exacto: misma posición vertical, misma altura y el
      // ancho repartido a mitades compartiendo la misma banda.
      expect(a.top, b.top);
      expect(a.height, b.height);
      expect(a.width!, closeTo(b.width!, 0.001));
      expect(b.left, closeTo(a.left! + a.width!, 0.001));
      expect(a.width, lessThan(600));
    },
  );

  testWidgets('la franja contenida se dibuja encima aunque se cree primero', (
    tester,
  ) async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final repo = LocalScheduleRepository();
    // Creadas en orden inverso al de pintado: la contenida (6–7) antes que la
    // que la contiene (5–9). El apilado no debe depender del orden.
    await repo.save(
      'ana@flowly.com',
      DailySchedule(ownerId: 'ana@flowly.com', events: [
        ScheduleEvent(
          id: 'corta',
          title: 'Reunión corta',
          start: day.add(const Duration(hours: 6)),
          end: day.add(const Duration(hours: 7)),
        ),
        ScheduleEvent(
          id: 'larga',
          title: 'Bloque largo',
          start: day.add(const Duration(hours: 5)),
          end: day.add(const Duration(hours: 9)),
        ),
      ]),
    );

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Bloque largo'), findsOneWidget);
    expect(find.text('Reunión corta'), findsOneWidget);

    final larga = _block(tester, 'larga');
    final corta = _block(tester, 'corta');
    // No coinciden exactamente en hora: ambas ocupan el ancho completo.
    expect(larga.left, corta.left);
    expect(larga.width, corta.width);
    // La corta (6–7) cae dentro del tramo de la larga (5–9)…
    expect(corta.top!, greaterThan(larga.top!));
    expect(
      corta.top! + corta.height!,
      lessThanOrEqualTo(larga.top! + larga.height!),
    );
    // …y aunque se creó antes, se dibuja después (por encima).
    expect(_blockIndex(tester, 'corta'), greaterThan(_blockIndex(tester, 'larga')));
  });

  testWidgets('el anidamiento se apila por contención sin importar el orden', (
    tester,
  ) async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final repo = LocalScheduleRepository();
    // Creadas desordenadas: tarea2 (5–8), tarea1 (4–9) y tarea3 (6–7).
    await repo.save(
      'ana@flowly.com',
      DailySchedule(ownerId: 'ana@flowly.com', events: [
        ScheduleEvent(
          id: 'tarea2',
          title: 'Tarea 2',
          start: day.add(const Duration(hours: 5)),
          end: day.add(const Duration(hours: 8)),
        ),
        ScheduleEvent(
          id: 'tarea1',
          title: 'Tarea 1',
          start: day.add(const Duration(hours: 4)),
          end: day.add(const Duration(hours: 9)),
        ),
        ScheduleEvent(
          id: 'tarea3',
          title: 'Tarea 3',
          start: day.add(const Duration(hours: 6)),
          end: day.add(const Duration(hours: 7)),
        ),
      ]),
    );

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Tarea 1'), findsOneWidget);
    expect(find.text('Tarea 2'), findsOneWidget);
    expect(find.text('Tarea 3'), findsOneWidget);

    final t1 = _block(tester, 'tarea1');
    final t2 = _block(tester, 'tarea2');
    final t3 = _block(tester, 'tarea3');
    // Ninguna coincide exactamente en hora: ancho completo para las tres.
    expect(t1.width, t2.width);
    expect(t2.width, t3.width);
    expect(t1.left, t2.left);
    expect(t2.left, t3.left);
    // Cada interior queda dentro del tramo de la que lo contiene.
    bool inside(Positioned inner, Positioned outer) =>
        inner.top! >= outer.top! &&
        inner.top! + inner.height! <= outer.top! + outer.height!;
    expect(inside(t2, t1), isTrue, reason: 'tarea2 debe estar dentro de tarea1');
    expect(inside(t3, t1), isTrue, reason: 'tarea3 debe estar dentro de tarea1');
    expect(inside(t3, t2), isTrue, reason: 'tarea3 debe estar dentro de tarea2');
    // Orden de pintado: tarea1 al fondo, tarea2 delante y tarea3 encima de las
    // dos anteriores, independientemente del orden de creación.
    expect(_blockIndex(tester, 'tarea1'), lessThan(_blockIndex(tester, 'tarea2')));
    expect(_blockIndex(tester, 'tarea2'), lessThan(_blockIndex(tester, 'tarea3')));
  });
}