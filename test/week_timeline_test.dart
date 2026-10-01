import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/app/theme/colors.dart';
import 'package:productyivity_app/features/daily_schedule/week_timeline.dart';
import 'package:productyivity_app/l10n/app_localizations.dart';
import 'package:productyivity_app/models/schedule_event.dart';

/// Lunes de una semana de referencia.
final DateTime _monday = DateTime(2026, 9, 28);

ScheduleEvent _event(
  String id, {
  required int day,
  int hour = 10,
  int minute = 0,
  int endHour = 11,
  int endMinute = 0,
}) {
  final start = DateTime(2026, 9, 28).add(Duration(days: day, hours: hour, minutes: minute));
  final end = DateTime(2026, 9, 28).add(Duration(days: day, hours: endHour, minutes: endMinute));
  return ScheduleEvent(id: id, title: id, start: start, end: end);
}

Widget _harness({
  List<ScheduleEvent> events = const [],
  DateTime? weekStart,
  ValueChanged<DateTime>? onCreateEvent,
  ValueChanged<ScheduleEvent>? onTapEvent,
}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: WeekTimeline(
        controller: ScrollController(),
        weekStart: weekStart ?? _monday,
        events: events,
        onCreateEvent: onCreateEvent ?? (_) {},
        onTapEvent: onTapEvent ?? (_) {},
      ),
    ),
  );
}

/// Bloque (Positioned) de la franja [id] en la rejilla.
Positioned _block(WidgetTester tester, String id) =>
    tester.widget<Positioned>(find.byKey(ValueKey('event-block-$id')));

/// Ancho con el que se ha dibujado una columna de día.
///
/// La rejilla reparte el espacio disponible entre los siete días, así que el
/// ancho no es una constante: los tests lo leen de la propia columna ya
/// pintada en vez de fijarlo, y así siguen siendo válidos con cualquier
/// superficie de prueba.
double _dayWidth(WidgetTester tester) =>
    tester.getSize(find.byKey(WeekTimeline.dayColumnKey(0))).width;

/// Toca la celda de [dayIndex] (lunes = 0) en la fila de la hora [hour], con
/// [offsetInHour] píxeles dentro de la fila.
Future<void> _tapCell(
  WidgetTester tester,
  int dayIndex,
  int hour, {
  double offsetInHour = 5,
}) async {
  final column = find.byKey(WeekTimeline.dayColumnKey(dayIndex));
  final topLeft = tester.getTopLeft(column);
  await tester.tapAt(
    topLeft +
        Offset(
          _dayWidth(tester) / 2,
          WeekTimeline.hourHeight * hour + offsetInHour,
        ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('WeekTimeline — weekIndexFor', () {
    test('la semana en curso sitúa la columna de hoy', () {
      // Miércoles 30 de septiembre de 2026 → columna 2 (lunes = 0).
      expect(todayIndexIn(_monday, DateTime(2026, 9, 30)), 2);
      expect(todayIndexIn(_monday, _monday), 0);
      expect(todayIndexIn(_monday, DateTime(2026, 10, 4)), 6);
    });

    test('otra semana no tiene columna de hoy', () {
      final previous = _monday.subtract(const Duration(days: 7));
      final next = _monday.add(const Duration(days: 7));
      // Cualquier día, pasado o futuro.
      expect(todayIndexIn(previous, DateTime(2026, 10, 1)), -1);
      expect(todayIndexIn(next, DateTime(2026, 10, 1)), -1);
    });

    test('funciona al cruzar el año', () {
      // Semana que empieza en diciembre y termina en enero: la columna de hoy
      // se cuenta sobre los días de enero, no sobre los del lunes.
      final week = DateTime(2026, 12, 28);
      expect(todayIndexIn(week, DateTime(2027, 1, 3)), 6);
      expect(todayIndexIn(week, DateTime(2026, 12, 31)), 3);
    });

    test('ignora la hora del día', () {
      expect(
        todayIndexIn(_monday, DateTime(2026, 9, 30, 23, 59)),
        todayIndexIn(_monday, DateTime(2026, 9, 30)),
      );
    });
  });

  group('WeekTimeline — reparto del ancho', () {
    test('reparte el ancho disponible entre los siete días', () {
      // Con hueco para las etiquetas de hora y sin topar con el máximo, las
      // columnas comen exactamente el espacio sobrante.
      expect(WeekTimeline.dayWidthFor(375), closeTo(48.14, 0.01));
      expect(
        WeekTimeline.gridWidthFor(WeekTimeline.dayWidthFor(375)),
        closeTo(375, 0.01),
      );
    });

    test('por debajo del ancho mínimo la rejilla se desborda', () {
      // Pantalla estrecha: las columnas se quedan en el mínimo legible aunque
      // no quepan, y el ancho total supera la pantalla.
      expect(WeekTimeline.dayWidthFor(200), WeekTimeline.minDayWidth);
      expect(WeekTimeline.gridWidthFor(WeekTimeline.minDayWidth), greaterThan(200));
      expect(WeekTimeline.needsHorizontalScroll(200), isTrue);
    });

    test('sin techo: se estira hasta el ancho disponible', () {
      expect(WeekTimeline.dayWidthFor(1600), closeTo(223.14, 0.01));
      expect(
        WeekTimeline.gridWidthFor(WeekTimeline.dayWidthFor(1600)),
        closeTo(1600, 0.01),
      );
      // Y no hace falta desplazar en horizontal.
      expect(WeekTimeline.needsHorizontalScroll(1600), isFalse);
    });

    testWidgets('la rejilla ocupa todo el ancho de la pantalla', (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // Etiquetas de hora + siete columnas = ancho completo, y solo se
      // desplaza el eje vertical de las horas.
      final lastColumn = find.byKey(WeekTimeline.dayColumnKey(6));
      final gridRight = tester.getTopLeft(lastColumn).dx +
          tester.getSize(lastColumn).width;
      expect(gridRight, closeTo(390, 0.5));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('en pantalla ancha las columnas se estiran y no hay scroll', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(_dayWidth(tester), closeTo(223.14, 0.5));
      final lastColumn = find.byKey(WeekTimeline.dayColumnKey(6));
      expect(
        tester.getTopLeft(lastColumn).dx + tester.getSize(lastColumn).width,
        closeTo(1600, 0.5),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('por debajo del mínimo aparece el scroll horizontal', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // Las columnas no bajan del mínimo y la rejilla no cabe. Hay un
      // desplazamiento vertical (las horas) y dos horizontales: el de la
      // cabecera de días y el de las columnas, para que ambas se muevan juntas.
      expect(_dayWidth(tester), WeekTimeline.minDayWidth);
      final scrollViews = tester
          .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .toList();
      expect(scrollViews, hasLength(3));
      expect(
        scrollViews.where((s) => s.scrollDirection == Axis.vertical),
        hasLength(1),
      );
      expect(
        scrollViews.where((s) => s.scrollDirection == Axis.horizontal),
        hasLength(2),
      );
    });

    testWidgets('la cabecera de días queda fija sobre el scroll de horas', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      final header = find.byKey(const ValueKey('week-day-header-28'));
      expect(header, findsOneWidget);
      final headerTop = tester.getTopLeft(header).dy;

      // Se baja hasta el final del recorrido: los nombres de los días siguen
      // en pantalla, en el mismo sitio.
      await tester.drag(find.byKey(const Key('week-timeline')), const Offset(0, -4000));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('week-day-header-28')), findsOneWidget);
      expect(find.byKey(const ValueKey('week-day-header-4')), findsOneWidget);
      expect(tester.getTopLeft(header).dy, closeTo(headerTop, 0.5));
    });
  });

  group('WeekTimeline — rejilla', () {
    testWidgets('dibuja los siete días con sigla y número', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // Lunes a domingo, con la fecha de cada uno.
      for (final (name, day) in [
        ('Lun', 28),
        ('Mar', 29),
        ('Mié', 30),
        ('Jue', 1),
        ('Vie', 2),
        ('Sáb', 3),
        ('Dom', 4),
      ]) {
        expect(find.text(name), findsOneWidget, reason: 'falta la sigla $name');
        expect(
          find.descendant(
            of: find.byKey(ValueKey('week-day-header-$day')),
            matching: find.text('$day'),
          ),
          findsOneWidget,
          reason: 'falta el número $day',
        );
      }
    });

    testWidgets('muestra las 24 horas en formato 24 h', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      for (var h = 0; h < 24; h++) {
        final label = '${h.toString().padLeft(2, '0')}:00';
        expect(find.text(label), findsOneWidget, reason: 'falta la hora $label');
      }
    });

    testWidgets('resalta la cabecera del día actual', (tester) async {
      // Se muestra la semana real para que el día de hoy esté en la rejilla.
      await tester.pumpWidget(
        _harness(weekStart: WeekTimeline.startOfWeek(DateTime.now())),
      );
      await tester.pumpAndSettle();

      final today = DateTime.now();
      final header = tester.widget<Container>(
        find.byKey(ValueKey('week-day-header-${today.day}')),
      );
      expect((header.decoration! as BoxDecoration).color, AppColors.pinePale);
    });

    testWidgets('la línea de la hora actual va solo en la columna de hoy', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      final line = tester.widget<Positioned>(
        find.byKey(const Key('week-now-line')),
      );
      final todayIndex = DateTime.now().weekday - DateTime.monday;
      expect(
        line.left,
        WeekTimeline.hourLabelWidth + todayIndex * _dayWidth(tester),
      );
    });

    testWidgets('una semana que no es la de hoy no resalta ni marca la hora', (
      tester,
    ) async {
      // Semana siguiente: hoy no está en la rejilla, así que no se puede
      // resaltar ninguna cabecera ni dibujar la línea de la hora actual (si se
      // hiciera, caería sobre una columna que no es hoy).
      await tester.pumpWidget(
        _harness(weekStart: _monday.add(const Duration(days: 7))),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('week-now-line')), findsNothing);
      for (var day = 0; day < WeekTimeline.daysCount; day++) {
        final header = tester.widget<Container>(
          find.byKey(ValueKey('week-day-header-${day + 5}')),
        );
        expect(
          (header.decoration! as BoxDecoration).color,
          isNot(AppColors.pinePale),
          reason: 'no debería resaltarse ningún día',
        );
      }
    });

    testWidgets('los días que ya han pasado no llevan tinte de fondo', (
      tester,
    ) async {
      // Semana anterior: sus siete días ya han pasado y ninguno se marca.
      await tester.pumpWidget(
        _harness(weekStart: _monday.subtract(const Duration(days: 7))),
      );
      await tester.pumpAndSettle();

      for (var day = 21; day <= 27; day++) {
        final header = tester.widget<Container>(
          find.byKey(ValueKey('week-day-header-$day')),
        );
        expect(
          (header.decoration! as BoxDecoration).color,
          isNull,
          reason: 'el día $day no debería llevar fondo',
        );
      }
    });

    testWidgets('cada columna lleva su línea separadora con la de al lado', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      Color? leftBorderOf(int dayIndex) {
        final cell = tester.widget<Container>(
          find
              .descendant(
                of: find.byKey(WeekTimeline.dayColumnKey(dayIndex)),
                matching: find.byType(Container),
              )
              .first,
        );
        final border = (cell.decoration! as BoxDecoration).border;
        return border is Border ? border.left.color : null;
      }

      // Del lunes al domingo hay una línea vertical entre cada par de días.
      for (var dayIndex = 0; dayIndex < WeekTimeline.daysCount; dayIndex++) {
        expect(
          leftBorderOf(dayIndex),
          AppColors.lineFaint,
          reason: 'falta la línea del día $dayIndex',
        );
      }
      // Y la cabecera usa la misma línea, para que el separador sea continuo.
      final header = tester.widget<Container>(
        find.byKey(ValueKey('week-day-header-29')),
      );
      expect(
        ((header.decoration! as BoxDecoration).border as Border).left.color,
        AppColors.lineFaint,
      );
    });

    testWidgets('coloca cada franja en la columna de su día', (tester) async {
      await tester.pumpWidget(
        _harness(
          events: [
            _event('lunes', day: 0),
            _event('miercoles', day: 2),
            _event('domingo', day: 6),
          ],
        ),
      );
      await tester.pumpAndSettle();

      double leftOf(String id) => _block(tester, id).left!;
      final dayWidth = _dayWidth(tester);
      final slotWidth = dayWidth - 2 * WeekTimeline.blockInset;

      // Columna del día: etiquetas de hora + día × ancho, más el margen.
      expect(
        leftOf('lunes'),
        WeekTimeline.hourLabelWidth + WeekTimeline.blockInset,
      );
      expect(
        leftOf('miercoles'),
        WeekTimeline.hourLabelWidth +
            2 * dayWidth +
            WeekTimeline.blockInset,
      );
      expect(
        leftOf('domingo'),
        WeekTimeline.hourLabelWidth +
            6 * dayWidth +
            WeekTimeline.blockInset,
      );
      // Sin solapes, cada bloque ocupa su columna entera menos el margen.
      expect(_block(tester, 'lunes').width, slotWidth - 1);
    });

    testWidgets('sitúa el bloque por su hora de inicio y duración', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          events: [_event('deep', day: 2, hour: 10, minute: 30, endHour: 12, endMinute: 30)],
        ),
      );
      await tester.pumpAndSettle();

      final block = _block(tester, 'deep');
      expect(block.top, WeekTimeline.hourHeight * 10.5);
      expect(block.height, WeekTimeline.hourHeight * 2);
    });

    testWidgets('reparte en subcolumnas las franjas que se pisan', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          events: [
            _event('a', day: 1, hour: 9, endHour: 10),
            _event('b', day: 1, hour: 9, endHour: 10),
            _event('suelta', day: 1, hour: 12, endHour: 13),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final column = _dayWidth(tester) - 2 * WeekTimeline.blockInset;
      final full = column - 1;
      // Dos subcolumnas: la mitad del ancho útil de la columna, menos el
      // separador de 1 px.
      final half = column / 2 - 1;

      // Las dos que coinciden se reparten la columna; la otra va a lo ancho.
      expect(_block(tester, 'a').width, closeTo(half, 0.5));
      expect(_block(tester, 'b').width, closeTo(half, 0.5));
      // La segunda arranca una subcolumna más a la derecha (dejando 1 px de
      // separador).
      final slotWidth = column / 2;
      expect(
        _block(tester, 'b').left,
        _block(tester, 'a').left! + slotWidth,
      );
      expect(_block(tester, 'suelta').width, closeTo(full, 0.01));
    });

    testWidgets('una franja de madrugada no se sale del día', (tester) async {
      await tester.pumpWidget(
        _harness(
          events: [
            _event('noche', day: 0, hour: 23, minute: 30, endHour: 23, endMinute: 45),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final block = _block(tester, 'noche');
      // Se dibuja a su hora y no invade la fila siguiente.
      expect(block.top, WeekTimeline.hourHeight * 23.5);
      expect(
        block.top! + block.height!,
        lessThanOrEqualTo(WeekTimeline.totalHeight),
      );
    });

    testWidgets('no dibuja franjas de días que no están en la semana', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          events: [
            _event('dentro', day: 3),
            // Lunes siguiente: fuera de la semana.
            ScheduleEvent(
              id: 'fuera',
              title: 'fuera',
              start: DateTime(2026, 10, 5, 10),
              end: DateTime(2026, 10, 5, 11),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('event-block-dentro')), findsOneWidget);
      expect(find.byKey(const ValueKey('event-block-fuera')), findsNothing);
    });

    testWidgets('tocar un hueco pide crear una franja con esa fecha y hora', (
      tester,
    ) async {
      DateTime? tapped;
      await tester.pumpWidget(
        _harness(
          onCreateEvent: (start) => tapped = start,
          events: [_event('miercoles', day: 2, hour: 9, endHour: 10)],
        ),
      );
      await tester.pumpAndSettle();

      // Miércoles (índice 2) a las 10:00: el toque va a la hora.
      await _tapCell(tester, 2, 10, offsetInHour: 2);
      expect(tapped, DateTime(2026, 9, 30, 10));

      // Sábado (índice 5), y el toque se redondea al cuarto de hora más
      // cercano, como en la vista diaria.
      await _tapCell(tester, 5, 8, offsetInHour: 9);
      expect(tapped, DateTime(2026, 10, 3, 8, 15));
    });

    testWidgets('tocar una franja notifica ese evento', (tester) async {
      ScheduleEvent? tapped;
      await tester.pumpWidget(
        _harness(
          events: [_event('revision', day: 3, hour: 8, endHour: 9)],
          onTapEvent: (event) => tapped = event,
        ),
      );
      await tester.pumpAndSettle();

      await _tapCell(tester, 3, 8);
      expect(tapped?.id, 'revision');
    });
  });

  group('layoutDayColumns', () {
    test('el mismo intervalo se reparte en dos', () {
      final events = [
        _event('a', day: 0, hour: 9, endHour: 10),
        _event('b', day: 0, hour: 9, endHour: 10),
      ];
      final layout = layoutDayColumns(events);
      expect(layout['a'], (column: 0, columns: 2));
      expect(layout['b'], (column: 1, columns: 2));
    });

    test('tres franjas que se pisan ocupan tres subcolumnas', () {
      final events = [
        _event('a', day: 0, hour: 9, endHour: 11),
        _event('b', day: 0, hour: 9, minute: 30, endHour: 10, endMinute: 30),
        _event('c', day: 0, hour: 10, endHour: 12),
      ];
      final layout = layoutDayColumns(events);
      expect(layout['a'], (column: 0, columns: 3));
      expect(layout['b'], (column: 1, columns: 3));
      expect(layout['c'], (column: 2, columns: 3));
    });

    test('la franja que empieza al terminar otra reutiliza su subcolumna', () {
      // «9–10» y «10–11» no se pisan, así que la segunda vuelve a ocupar el
      // ancho entero; «9:30–10:30» se queda con la mitad mientras dura.
      final events = [
        _event('a', day: 0, hour: 9, endHour: 10),
        _event('b', day: 0, hour: 9, minute: 30, endHour: 10, endMinute: 30),
        _event('c', day: 0, hour: 10, endHour: 11),
      ];
      final layout = layoutDayColumns(events);
      expect(layout['a'], (column: 0, columns: 2));
      expect(layout['b'], (column: 1, columns: 2));
      expect(layout['c'], (column: 0, columns: 2));
    });

    test('intervalos que solo se tocan no se solapan', () {
      final events = [
        _event('a', day: 0, hour: 9, endHour: 10),
        _event('b', day: 0, hour: 10, endHour: 11),
      ];
      final layout = layoutDayColumns(events);
      expect(layout['a'], (column: 0, columns: 1));
      expect(layout['b'], (column: 0, columns: 1));
    });

    test('sin franjas no hay reparto', () {
      expect(layoutDayColumns(const []), isEmpty);
    });
  });

  group('WeekTimeline.startOfWeek', () {
    test('devuelve el lunes a las 00:00', () {
      expect(
        WeekTimeline.startOfWeek(DateTime(2026, 10, 1, 15, 30)),
        DateTime(2026, 9, 28),
      );
    });

    test('un lunes es su propio inicio de semana', () {
      expect(
        WeekTimeline.startOfWeek(DateTime(2026, 9, 28, 8)),
        DateTime(2026, 9, 28),
      );
    });

    test('el domingo pertenece a la semana que empieza ese lunes', () {
      expect(
        WeekTimeline.startOfWeek(DateTime(2026, 10, 4, 23, 59)),
        DateTime(2026, 9, 28),
      );
    });

    test('la primera semana del año empieza en diciembre del año anterior', () {
      // El 1 de enero de 2027 es viernes: su semana empieza el lunes 28 de
      // diciembre de 2026.
      expect(
        WeekTimeline.startOfWeek(DateTime(2027, 1, 1, 9)),
        DateTime(2026, 12, 28),
      );
    });

    test('la última semana del año termina en enero del año siguiente', () {
      final weekStart = WeekTimeline.startOfWeek(DateTime(2026, 12, 31));
      expect(weekStart, DateTime(2026, 12, 28));
      expect(
        weekStart.add(const Duration(days: WeekTimeline.daysCount - 1)),
        DateTime(2027, 1, 3),
      );
    });
  });

  group('WeekTimeline.rangeLabel', () {
    Future<String> label(WidgetTester tester, DateTime weekStart) async {
      late String result;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              result = WeekTimeline.rangeLabel(context, weekStart);
              return const SizedBox();
            },
          ),
        ),
      );
      return result;
    }

    testWidgets('escribe el rango con mayúscula inicial y un solo mes', (
      tester,
    ) async {
      // Semana del 21 al 27 de septiembre: los dos días son del mismo mes.
      expect(await label(tester, DateTime(2026, 9, 21)), '21 – 27 sept');
    });

    testWidgets('repite el mes cuando la semana lo cruza', (tester) async {
      // Del lunes 28 de septiembre al domingo 4 de octubre.
      expect(await label(tester, DateTime(2026, 9, 28)), '28 sept – 4 oct');
    });

    testWidgets('el rango también funciona al cruzar el año', (tester) async {
      // Del lunes 28 de diciembre de 2026 al domingo 3 de enero de 2027.
      expect(await label(tester, DateTime(2026, 12, 28)), '28 dic – 3 ene');
    });
  });
}
