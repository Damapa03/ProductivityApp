import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:productyivity_app/app/theme/colors.dart';
import 'package:productyivity_app/data/schedule_repository.dart';
import 'package:productyivity_app/features/daily_schedule/daily_schedule_screen.dart';
import 'package:productyivity_app/features/daily_schedule/day_timeline.dart';
import 'package:productyivity_app/features/daily_schedule/week_timeline.dart';
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

/// Identificador de la única franja dibujada, para localizar su bloque sin
/// depender del formato del id que genera la pantalla.
String _onlyBlockId(WidgetTester tester) {
  final ids = find
      .byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('event-block-'),
      )
      .evaluate()
      .map((element) => (element.widget.key! as ValueKey<String>).value)
      .toList();
  expect(ids, hasLength(1), reason: 'se esperaba un único bloque de franja');
  return ids.single.substring('event-block-'.length);
}

/// Mayúscula inicial, como la que pone la cabecera a la fecha.
String _capitalize(String text) => text[0].toUpperCase() + text.substring(1);

/// Contexto bajo el que leer el locale activo, para formatear como la pantalla.
BuildContext _localeContext(WidgetTester tester) =>
    tester.element(find.byType(DailyScheduleScreen));

/// Bloque (Positioned) de la franja con [id] en la línea de tiempo.
Positioned _block(WidgetTester tester, String id) => tester.widget<Positioned>(
  find.byKey(ValueKey('event-block-$id')),
);

/// Ancho con el que se ha dibujado una columna de día de la rejilla semanal.
///
/// Las columnas reparten el ancho disponible, así que los tests leen el ancho
/// real de la columna pintada en lugar de asumir una constante.
double _weekDayWidth(WidgetTester tester) =>
    tester.getSize(find.byKey(WeekTimeline.dayColumnKey(0))).width;

/// Deja la pantalla en la vista semanal.
Future<void> _showWeekView(WidgetTester tester) async {
  await tester.tap(find.text('Semana'));
  await tester.pumpAndSettle();
}

/// Superficie alta para que la rejilla entera quepa sin desplazarse: así las
/// columnas y las filas siempre están en la misma posición, sea cual sea la
/// hora a la que se ejecuten los tests.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Toca la celda del día [dayIndex] (lunes = 0) en la fila de la hora [hour].
Future<void> _tapWeekCell(
  WidgetTester tester,
  int dayIndex,
  int hour, {
  double offsetInHour = 2,
}) async {
  final column = find.byKey(WeekTimeline.dayColumnKey(dayIndex));
  await tester.tapAt(
    tester.getTopLeft(column) +
        Offset(
          tester.getSize(column).width / 2,
          WeekTimeline.hourHeight * hour + offsetInHour,
        ),
  );
  await tester.pumpAndSettle();
}

/// Crea una franja en la rejilla semanal, en la celda indicada.
Future<void> _createWeekEvent(
  WidgetTester tester,
  int dayIndex,
  int hour,
  String title,
) async {
  await _tapWeekCell(tester, dayIndex, hour);
  await tester.enterText(find.byType(TextField), title);
  await tester.tap(find.text('Confirmar'));
  await tester.pumpAndSettle();
  expect(find.text(title), findsOneWidget);
}

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

  testWidgets('la cabecera muestra las flechas de día y semana', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('step-navigator-previous')), findsOneWidget);
    expect(find.byKey(const Key('step-navigator-next')), findsOneWidget);
    // Estando en hoy no hace falta atajo para volver.
    expect(find.byKey(const Key('step-navigator-today')), findsNothing);
  });

  testWidgets('las flechas mueven el día del plan y el título con él', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final today = DateTime.now();
    final todayLabel = DateFormat(
      'EEEE, d MMMM',
      'es',
    ).format(today);
    expect(find.text(_capitalize(todayLabel)), findsOneWidget);

    // Un día hacia delante: la fecha de la cabecera avanza uno.
    await tester.tap(find.byKey(const Key('step-navigator-next')));
    await tester.pumpAndSettle();
    final tomorrow = today.add(const Duration(days: 1));
    expect(
      find.text(
        _capitalize(DateFormat('EEEE, d MMMM', 'es').format(tomorrow)),
      ),
      findsOneWidget,
    );

    // Y una hacia atrás se vuelve a hoy (y el atajo desaparece otra vez).
    await tester.tap(find.byKey(const Key('step-navigator-previous')));
    await tester.pumpAndSettle();
    expect(find.text(_capitalize(todayLabel)), findsOneWidget);
    expect(find.byKey(const Key('step-navigator-today')), findsNothing);
  });

  testWidgets('el botón «Hoy» aparece fuera de hoy y devuelve', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('step-navigator-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('step-navigator-today')), findsOneWidget);

    await tester.tap(find.byKey(const Key('step-navigator-today')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('step-navigator-today')), findsNothing);
    expect(
      find.text(
        _capitalize(DateFormat('EEEE, d MMMM', 'es').format(DateTime.now())),
      ),
      findsOneWidget,
    );
  });

  testWidgets('en Semana las flechas saltan la semana entera', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    final today = DateTime.now();
    String range() => WeekTimeline.rangeLabel(
      _localeContext(tester),
      WeekTimeline.startOfWeek(today),
    );
    expect(find.text(range()), findsOneWidget);

    await tester.tap(find.byKey(const Key('step-navigator-next')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        WeekTimeline.rangeLabel(
          _localeContext(tester),
          WeekTimeline.startOfWeek(today).add(const Duration(days: 7)),
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('la línea de la hora actual solo se ve en el día de hoy', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('now-line')), findsOneWidget);

    await tester.tap(find.byKey(const Key('step-navigator-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('now-line')), findsNothing);
  });

  testWidgets('en otra semana no se resalta ningún día ni se marca la hora', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    expect(find.byKey(const Key('week-now-line')), findsOneWidget);

    await tester.tap(find.byKey(const Key('step-navigator-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('week-now-line')), findsNothing);
  });

  testWidgets('el selector muestra Día y Semana y conmuta entre las vistas', (
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
    expect(find.byType(DayTimeline), findsOneWidget);

    // «Semana» cambia a la rejilla de los siete días.
    await _showWeekView(tester);
    expect(textColor('Semana'), const Color(0xFFF3F4EF));
    expect(textColor('Día'), AppColors.inkSoft);
    expect(find.byType(WeekTimeline), findsOneWidget);
    expect(find.byType(DayTimeline), findsNothing);

    // Y «Día» vuelve a la línea de tiempo de hoy.
    await tester.tap(find.text('Día'));
    await tester.pumpAndSettle();
    expect(find.byType(DayTimeline), findsOneWidget);
    expect(find.byType(WeekTimeline), findsNothing);
    expect(find.text('Plan de hoy'), findsOneWidget);
  });

  testWidgets('en modo Semana el título pasa a «Esta semana» con el rango', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final formatted = DateFormat('EEEE, d MMMM', 'es').format(now);
    final dateText = formatted[0].toUpperCase() + formatted.substring(1);

    await _showWeekView(tester);
    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.text('Plan de hoy'), findsNothing);
    // La línea de arriba deja de ser la fecha de hoy y pasa a ser el rango de
    // la semana: los dos días, del lunes al domingo.
    expect(find.text(dateText), findsNothing);
    final weekStart = WeekTimeline.startOfWeek(now);
    final lastDay = weekStart.add(const Duration(days: WeekTimeline.daysCount - 1));
    expect(
      find.textContaining(RegExp('^\\D*${weekStart.day}\\D*${lastDay.day}\\D*\$')),
      findsOneWidget,
    );

    // Al volver a «Día» reaparecen el título y la fecha de hoy.
    await tester.tap(find.text('Día'));
    await tester.pumpAndSettle();
    expect(find.text('Plan de hoy'), findsOneWidget);
    expect(find.text(dateText), findsOneWidget);
  });

  testWidgets('la rejilla semanal coloca cada franja en el día que empieza', (
    tester,
  ) async {
    _useTallSurface(tester);
    final weekStart = WeekTimeline.startOfWeek(DateTime.now());
    final repo = LocalScheduleRepository();
    await repo.save(
      'ana@flowly.com',
      DailySchedule(ownerId: 'ana@flowly.com', events: [
        // Lunes, miércoles y domingo de esta semana.
        for (final (id, day) in [('lunes', 0), ('miercoles', 2), ('domingo', 6)])
          ScheduleEvent(
            id: id,
            title: 'Tarea $id',
            start: weekStart.add(Duration(days: day, hours: 9)),
            end: weekStart.add(Duration(days: day, hours: 10)),
          ),
        // Lunes siguiente: fuera de la semana, no se dibuja.
        ScheduleEvent(
          id: 'fuera',
          title: 'Tarea fuera',
          start: weekStart.add(const Duration(days: 7, hours: 9)),
          end: weekStart.add(const Duration(days: 7, hours: 10)),
        ),
      ]),
    );

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    expect(find.text('Tarea fuera'), findsNothing);
    // Columna del día = etiquetas de hora + día × ancho, más el margen.
    for (final (id, day) in [
      ('lunes', 0),
      ('miercoles', 2),
      ('domingo', 6),
    ]) {
      expect(find.text('Tarea $id'), findsOneWidget);
      expect(
        _block(tester, id).left,
        WeekTimeline.hourLabelWidth +
            day * _weekDayWidth(tester) +
            WeekTimeline.blockInset,
        reason: '$id debería estar en la columna del día $day',
      );
      // Altura de una hora en la fila de las 09:00.
      expect(_block(tester, id).top, WeekTimeline.hourHeight * 9);
    }
  });

  testWidgets('crea una franja en el día que se toca en la rejilla semanal', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    // Miércoles (índice 2) a las 08:00.
    await _tapWeekCell(tester, 2, 8);
    expect(find.text('Nueva tarea'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Revisión');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Revisión'), findsOneWidget);

    // Se guarda con la fecha del miércoles, no la de hoy.
    final wednesday = WeekTimeline.startOfWeek(DateTime.now())
        .add(const Duration(days: 2));
    final schedule = await LocalScheduleRepository().load('ana@flowly.com');
    final event = schedule!.events.single;
    expect(event.start, DateTime(wednesday.year, wednesday.month, wednesday.day, 8));
    expect(event.end, event.start.add(const Duration(hours: 1)));

    // Y en la vista de un día no aparece, porque es de otro día.
    await tester.tap(find.text('Día'));
    await tester.pumpAndSettle();
    expect(find.text('Revisión'), findsNothing);
  });

  testWidgets('el selector de día solo aparece en la vista semanal', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // En el plan del día no hay nada que escoger: el día lo fija el hueco.
    final todayHour = DateTime.now().hour;
    await tester.tapAt(
      tester.getTopLeft(find.byType(DayTimeline)) +
          Offset(200, DayTimeline.hourHeight * todayHour + 2),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nueva tarea'), findsOneWidget);
    expect(find.byKey(const ValueKey('schedule-day-chip-0')), findsNothing);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // En la rejilla semanal sí aparece, con los siete días.
    await _showWeekView(tester);
    await _tapWeekCell(tester, 0, 9);
    expect(find.byKey(const ValueKey('schedule-day-chip-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('schedule-day-chip-6')), findsOneWidget);
    // Los chips llevan la sigla y el número de cada día, como la cabecera.
    expect(find.text('LUN'), findsOneWidget);
    expect(find.text('DOM'), findsOneWidget);
  });

  testWidgets('crear en la semana permite elegir otro día y lo guarda', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    // Se abre en el lunes (índice 0) a las 09:00 y se pasa al jueves.
    await _tapWeekCell(tester, 0, 9);
    await tester.enterText(find.byType(TextField), 'Citas');
    await tester.tap(find.byKey(const ValueKey('schedule-day-chip-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    final thursday = WeekTimeline.startOfWeek(DateTime.now())
        .add(const Duration(days: 3));
    final schedule = await LocalScheduleRepository().load('ana@flowly.com');
    final event = schedule!.events.single;
    // Conserva la hora del hueco tocado, solo cambia el día.
    expect(event.start, DateTime(thursday.year, thursday.month, thursday.day, 9));
    expect(event.end, event.start.add(const Duration(hours: 1)));

    // Y el bloque se dibuja en la columna del jueves.
    expect(
      _block(tester, event.id).left,
      WeekTimeline.hourLabelWidth +
          3 * _weekDayWidth(tester) +
          WeekTimeline.blockInset,
    );
  });

  testWidgets('elegir día en un duplicado mueve también la hora de fin', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    // 09:00–10:00 en el lunes, movido al sábado: conserva hora y duración.
    await _tapWeekCell(tester, 0, 9);
    await tester.enterText(find.byType(TextField), 'Mercado');
    await tester.tap(find.byKey(const ValueKey('schedule-day-chip-5')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    final saturday = WeekTimeline.startOfWeek(DateTime.now())
        .add(const Duration(days: 5));
    final schedule = await LocalScheduleRepository().load('ana@flowly.com');
    final event = schedule!.events.single;
    expect(event.start, DateTime(saturday.year, saturday.month, saturday.day, 9));
    expect(event.end, DateTime(saturday.year, saturday.month, saturday.day, 10));
  });

  testWidgets('editar desde la semana permite mover la franja a otro día', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    await _createWeekEvent(tester, 1, 14, 'Lectura');

    await tester.tap(find.text('Lectura'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('schedule-day-chip-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    final friday = WeekTimeline.startOfWeek(DateTime.now())
        .add(const Duration(days: 4));
    final schedule = await LocalScheduleRepository().load('ana@flowly.com');
    final event = schedule!.events.single;
    expect(event.start, DateTime(friday.year, friday.month, friday.day, 14));
    expect(
      _block(tester, event.id).left,
      WeekTimeline.hourLabelWidth +
          4 * _weekDayWidth(tester) +
          WeekTimeline.blockInset,
    );
  });

  testWidgets('edita una franja desde su bloque en la rejilla semanal', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    await _createWeekEvent(tester, 1, 9, 'Gym');

    await tester.tap(find.text('Gym'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Gym 2');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Gym 2'), findsOneWidget);
    expect(find.text('Gym'), findsNothing);
  });

  testWidgets('elimina una franja desde su bloque en la rejilla semanal', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    await _createWeekEvent(tester, 3, 9, 'Standup');

    await tester.tap(find.text('Standup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(find.text('Eliminar tarea'), findsOneWidget);

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Standup'), findsNothing);
    final schedule = await LocalScheduleRepository().load('ana@flowly.com');
    expect(schedule!.events, isEmpty);
  });

  testWidgets('una franja creada en Día se ve en la columna de hoy de Semana', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Se crea en la vista de un día, sobre hoy.
    await _createEvent(tester, 'Informe');
    expect(find.text('Informe'), findsOneWidget);

    await _showWeekView(tester);

    // La misma franja aparece en la rejilla, en la columna de hoy.
    expect(find.text('Informe'), findsOneWidget);
    final todayIndex = DateTime.now().weekday - DateTime.monday;
    expect(
      _block(tester, _onlyBlockId(tester)).left,
      WeekTimeline.hourLabelWidth +
          todayIndex * _weekDayWidth(tester) +
          WeekTimeline.blockInset,
    );
  });

  testWidgets('una franja de otro día se ve en Semana pero no en el plan de hoy', (
    tester,
  ) async {
    _useTallSurface(tester);
    // Viernes de la semana en curso, a las 11:00.
    final friday = WeekTimeline.startOfWeek(DateTime.now())
        .add(const Duration(days: 4));
    await LocalScheduleRepository().save(
      'ana@flowly.com',
      DailySchedule(ownerId: 'ana@flowly.com', events: [
        ScheduleEvent(
          id: 'viernes',
          title: 'Demo',
          start: DateTime(friday.year, friday.month, friday.day, 11),
          end: DateTime(friday.year, friday.month, friday.day, 12),
        ),
      ]),
    );

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    // En la rejilla aparece en la columna del viernes.
    expect(find.text('Demo'), findsOneWidget);
    expect(
      _block(tester, 'viernes').left,
      WeekTimeline.hourLabelWidth +
          4 * _weekDayWidth(tester) +
          WeekTimeline.blockInset,
    );

    // El plan de hoy solo muestra las franjas de hoy.
    await tester.tap(find.text('Día'));
    await tester.pumpAndSettle();
    final today = DateTime.now();
    final isToday = today.year == friday.year &&
        today.month == friday.month &&
        today.day == friday.day;
    expect(find.text('Demo'), isToday ? findsOneWidget : findsNothing);
  });

  testWidgets('editar en Semana se refleja al volver a Día', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();
    await _showWeekView(tester);

    await _createWeekEvent(tester, 0, 8, 'Borrador');

    await tester.tap(find.text('Borrador'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Revisado');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Revisado'), findsOneWidget);
    final schedule = await LocalScheduleRepository().load('ana@flowly.com');
    expect(schedule!.events.single.title, 'Revisado');
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