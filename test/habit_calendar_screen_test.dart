import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:productyivity_app/app/theme/colors.dart';
import 'package:productyivity_app/data/habit_repository.dart';
import 'package:productyivity_app/features/habit_calendar/habit_calendar_screen.dart';
import 'package:productyivity_app/features/habit_calendar/month_grid.dart';
import 'package:productyivity_app/l10n/app_localizations.dart';
import 'package:productyivity_app/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Día fijo en el que se sitúan todos los tests: el 3 de octubre de 2026 fue
/// un viernes, de modo que el mes empieza en miércoles y la lista de hábitos
/// mira a un día pasado y a otro por venir.
final DateTime _today = DateTime(2026, 10, 3);

Widget _harness({String ownerId = 'ana@flowly.com'}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: HabitCalendarScreen(ownerId: ownerId, today: _today),
  );
}

/// Guarda un registro en local antes de abrir la pantalla.
Future<void> _seed(HabitLog log) {
  return LocalHabitRepository().save(log.ownerId, log);
}

/// Registro con los dos hábitos de ejemplo, creados en septiembre para que
/// cuenten en todo el mes de octubre.
HabitLog _log({
  String ownerId = 'ana@flowly.com',
  Set<String> completions = const {},
}) {
  return HabitLog(
    ownerId: ownerId,
    habits: [
      Habit(
        id: 'agua',
        title: 'Beber 2 L de agua',
        createdAt: DateTime(2026, 9, 1),
      ),
      Habit(
        id: 'lectura',
        title: '30 minutos de lectura',
        createdAt: DateTime(2026, 9, 1),
      ),
    ],
    completions: completions,
  );
}

/// Celda del día [day] de octubre de 2026.
Finder _cell(int day) => find.byKey(ValueKey('day-cell-2026-10-$day'));

/// Fondo con el que se pinta la celda de un día.
Color _cellColor(WidgetTester tester, int day) {
  final container = tester.widget<Container>(_cell(day));
  return (container.decoration! as BoxDecoration).color!;
}

/// Anillo que marca el día seleccionado o el de hoy.
Color _cellRing(WidgetTester tester, int day) {
  final ring = tester.widget<DecoratedBox>(
    find.byKey(ValueKey('day-ring-2026-10-$day')),
  );
  return (ring.decoration as BoxDecoration).border!.top.color;
}

/// Nombre de un día tal como lo fecha la lista de checks («Viernes, 2
/// octubre» en español, sin la «de» que el formato de `intl` no pone).
String _dayLabel(DateTime day) {
  final formatted = DateFormat('EEEE, d MMMM', 'es').format(day);
  return formatted[0].toUpperCase() + formatted.substring(1);
}

/// Marcar o desmarcar el hábito [habitId] en la lista de checks.
Future<void> _check(WidgetTester tester, String habitId) async {
  await tester.tap(find.byKey(ValueKey('habit-row-$habitId')));
  await tester.pumpAndSettle();
}

/// Día al que dicen pertenecer los checks de la lista.
String _selectedLabel(WidgetTester tester) {
  return tester
      .widget<Text>(find.byKey(const Key('habit-day-label')))
      .data!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('cabecera', () {
    testWidgets('muestra el mes y el año del día actual', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Octubre 2026'), findsOneWidget);
    });

    testWidgets('el mes y el año van centrados', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      final title = tester.getCenter(find.text('Octubre 2026'));
      expect(title.dx, closeTo(800 / 2, 0.5));
    });

    testWidgets('las siglas de los días van de lunes a domingo', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      final row = find.byKey(const Key('weekday-row'));
      final initials = [
        for (final text in tester.widgetList<Text>(
          find.descendant(of: row, matching: find.byType(Text)),
        ))
          text.data!,
      ];
      expect(initials, ['L', 'M', 'X', 'J', 'V', 'S', 'D']);
    });

    testWidgets('la rejilla numera los días del mes y no los de al lado', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // El 1 de octubre de 2026 es miércoles: dos huecos antes.
      expect(_cell(1), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(_cell(31), findsOneWidget);
      // Ni un día más de los que tiene el mes.
      expect(_cell(32), findsNothing);
    });

    testWidgets('las flechas recorren los meses y saltan de año', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('step-navigator-previous')));
      await tester.pumpAndSettle();
      expect(find.text('Septiembre 2026'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('step-navigator-next')));
      await tester.tap(find.byKey(const ValueKey('step-navigator-next')));
      await tester.pumpAndSettle();
      expect(find.text('Noviembre 2026'), findsOneWidget);

      // Diciembre, y el mes siguiente ya es del año siguiente.
      await tester.tap(find.byKey(const ValueKey('step-navigator-next')));
      await tester.pumpAndSettle();
      expect(find.text('Diciembre 2026'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('step-navigator-next')));
      await tester.pumpAndSettle();
      expect(find.text('Enero 2027'), findsOneWidget);

      // Y al revés, de vuelta al mes anterior.
      await tester.tap(find.byKey(const ValueKey('step-navigator-previous')));
      await tester.pumpAndSettle();
      expect(find.text('Diciembre 2026'), findsOneWidget);
    });

    testWidgets('el botón «Hoy» solo aparece fuera del mes actual y vuelve', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('step-navigator-today')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('step-navigator-previous')));
      await tester.pumpAndSettle();

      final today = find.byKey(const Key('step-navigator-today'));
      expect(today, findsOneWidget);
      await tester.tap(today);
      await tester.pumpAndSettle();

      expect(find.text('Octubre 2026'), findsOneWidget);
      expect(find.byKey(const Key('step-navigator-today')), findsNothing);
      // Y la lista vuelve a mirar el día de hoy.
      expect(_selectedLabel(tester), 'Hoy');
    });
  });

  group('colores del calendario', () {
    testWidgets('un día anterior incompleto se pinta en rojo', (tester) async {
      await _seed(_log(completions: {'agua@2026-10-02'}));
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(_cellColor(tester, 2), AppColors.missPale);
      expect(_cellColor(tester, 1), AppColors.missPale);
    });

    testWidgets('un día anterior con todo cumplido se pinta en verde', (
      tester,
    ) async {
      await _seed(_log(completions: {
        'agua@2026-10-02',
        'lectura@2026-10-02',
      }));
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(_cellColor(tester, 2), AppColors.done);
    });

    testWidgets('hoy se queda neutro hasta que se cumplan todos', (
      tester,
    ) async {
      await _seed(_log(completions: {'agua@2026-10-03'}));
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(_cellColor(tester, 3), AppColors.cardBg);

      // Al marcar el que faltaba, hoy se cierra en verde.
      await _check(tester, 'lectura');
      expect(_cellColor(tester, 3), AppColors.done);
    });

    testWidgets('los días por venir se apagan', (tester) async {
      await _seed(_log());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(_cellColor(tester, 4), AppColors.futurePale);
      expect(_cellColor(tester, 31), AppColors.futurePale);
    });

    testWidgets('sin hábitos no hay días rojos', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(_cellColor(tester, 1), AppColors.cardBg);
      expect(_cellColor(tester, 2), AppColors.cardBg);
    });

    testWidgets('un hábito creado hoy no pone en rojo los días pasados', (
      tester,
    ) async {
      await _seed(
        HabitLog(
          ownerId: 'ana@flowly.com',
          habits: [
            Habit(
              id: 'agua',
              title: 'Beber 2 L de agua',
              createdAt: DateTime(2026, 10, 3, 9, 30),
            ),
          ],
          completions: const {},
        ),
      );
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // El 2 de octubre aún no había hábitos: neutro, no fallado.
      expect(_cellColor(tester, 2), AppColors.cardBg);
      // Hoy sí cuenta, así que está pendiente… pero sin cerrar.
      expect(_cellColor(tester, 3), AppColors.cardBg);
    });

    testWidgets('el anillo pineDeep marca el día que se está mirando', (
      tester,
    ) async {
      await _seed(_log());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // Arranca en hoy: el anillo fuerte es el suyo.
      expect(_cellRing(tester, 3), AppColors.pineDeep);

      await tester.tap(_cell(2));
      await tester.pumpAndSettle();

      expect(_cellRing(tester, 2), AppColors.pineDeep);
      // Hoy sigue señalándose, pero con el anillo neutro.
      expect(_cellRing(tester, 3), AppColors.line);
      // Los demás días no llevan anillo.
      expect(_cellRing(tester, 1), Colors.transparent);
    });

    testWidgets('la leyenda explica los dos colores', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('habits-legend')), findsOneWidget);
      expect(find.text('Todo cumplido'), findsOneWidget);
      expect(find.text('Faltó alguno'), findsOneWidget);
    });
  });

  group('lista de checks', () {
    testWidgets('arranca en los hábitos de hoy', (tester) async {
      await _seed(_log());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(_selectedLabel(tester), 'Hoy');
      expect(find.text('Beber 2 L de agua'), findsOneWidget);
      expect(find.text('30 minutos de lectura'), findsOneWidget);
      expect(find.text('0 de 2'), findsOneWidget);
    });

    testWidgets('sin hábitos muestra la pista y el botón de añadir', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Sin hábitos todavía. Añade el primero.'), findsOneWidget);
      expect(find.byKey(const Key('habits-add')), findsOneWidget);
    });

    testWidgets('tocar un día del calendario cambia los checks de ese día', (
      tester,
    ) async {
      // El 2 está completo y el 3 no: cada día tiene su propio color.
      await _seed(
        _log(completions: {'agua@2026-10-02', 'lectura@2026-10-02'}),
      );
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_cell(2));
      await tester.pumpAndSettle();

      expect(_selectedLabel(tester), _dayLabel(DateTime(2026, 10, 2)));
      expect(find.text('2 de 2'), findsOneWidget);
    });

    testWidgets('completar un día pasado lo pone en verde', (tester) async {
      await _seed(_log(completions: {'agua@2026-10-02'}));
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_cell(2));
      await tester.pumpAndSettle();
      expect(_cellColor(tester, 2), AppColors.missPale);

      await _check(tester, 'lectura');

      expect(_cellColor(tester, 2), AppColors.done);
      expect(find.text('2 de 2'), findsOneWidget);
    });

    testWidgets('desmarcar un díapassed lo devuelve al rojo', (tester) async {
      await _seed(
        _log(completions: {'agua@2026-10-02', 'lectura@2026-10-02'}),
      );
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_cell(2));
      await tester.pumpAndSettle();
      await _check(tester, 'lectura');

      expect(_cellColor(tester, 2), AppColors.missPale);
      expect(find.text('1 de 2'), findsOneWidget);
    });

    testWidgets('el check de un hábito solo toca su día', (tester) async {
      await _seed(_log(completions: {'agua@2026-10-02', 'lectura@2026-10-02'}));
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await _check(tester, 'agua');

      // El 2 sigue completo: el check fue al 3, que es el día de la lista.
      expect(_cellColor(tester, 2), AppColors.done);
      expect(_cellColor(tester, 3), AppColors.cardBg);
      expect(find.text('1 de 2'), findsOneWidget);
    });

    testWidgets('un día por venir se muestra en solo lectura', (tester) async {
      await _seed(_log());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_cell(10));
      await tester.pumpAndSettle();
      expect(_selectedLabel(tester), _dayLabel(DateTime(2026, 10, 10)));

      await _check(tester, 'agua');

      // Ni se marca ni cambia el color de la celda.
      expect(find.text('0 de 2'), findsOneWidget);
      expect(_cellColor(tester, 10), AppColors.futurePale);
    });
  });

  group('alta y borrado de hábitos', () {
    testWidgets('añadir un hábito lo suma al día y lo guarda', (
      tester,
    ) async {
      await _seed(_log());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('habits-add')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('habit-title-field')),
        'Estiramientos',
      );
      await tester.tap(find.text('Añadir'));
      await tester.pumpAndSettle();

      expect(find.text('Estiramientos'), findsOneWidget);
      expect(find.text('0 de 3'), findsOneWidget);

      // Reinicio de la app: el hábito sigue ahí.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();
      expect(find.text('Estiramientos'), findsOneWidget);
      expect(find.text('0 de 3'), findsOneWidget);
    });

    testWidgets('un hábito en blanco no se crea', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('habits-add')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('habit-title-field')), '   ');
      await tester.tap(find.text('Añadir'));
      await tester.pumpAndSettle();

      // El diálogo sigue abierto: no se creó nada.
      expect(find.byKey(const Key('habit-title-field')), findsOneWidget);
      expect(find.text('Sin hábitos todavía. Añade el primero.'), findsOneWidget);
    });

    testWidgets('borrar un hábito pide confirmación y se lleva sus checks', (
      tester,
    ) async {
      await _seed(_log(completions: {'agua@2026-10-03'}));
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('habit-row-agua')),
          matching: find.byType(PopupMenuButton<String>),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar').last);
      await tester.pumpAndSettle();

      // Cancelar no borra nada.
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Beber 2 L de agua'), findsOneWidget);

      // Confirmar sí.
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('habit-row-agua')),
          matching: find.byType(PopupMenuButton<String>),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar').last);
      await tester.pumpAndSettle();

      expect(find.text('Beber 2 L de agua'), findsNothing);
      expect(find.text('0 de 1'), findsOneWidget);
      // Sin ese hábito, hoy ya no se puede cerrar.
      expect(_cellColor(tester, 3), AppColors.cardBg);
    });

    testWidgets('cada usuario tiene sus hábitos', (tester) async {
      await _seed(_log());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_harness(ownerId: 'bob@flowly.com'));
      await tester.pumpAndSettle();

      expect(find.text('Beber 2 L de agua'), findsNothing);
      expect(find.text('Sin hábitos todavía. Añade el primero.'), findsOneWidget);
    });

    testWidgets('los checks se guardan entre sesiones', (tester) async {
      await _seed(_log());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await _check(tester, 'agua');

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('1 de 2'), findsOneWidget);
      final saved = await LocalHabitRepository().load('ana@flowly.com');
      expect(saved!.isDone('agua', _today), isTrue);
    });
  });

  group('rejilla', () {
    testWidgets('cambiar de mes no mueve el día seleccionado', (
      tester,
    ) async {
      await _seed(_log());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.tap(_cell(2));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('step-navigator-previous')));
      await tester.pumpAndSettle();

      // La lista sigue fechada en el 2, aunque ahora se vea septiembre.
      expect(_selectedLabel(tester), _dayLabel(DateTime(2026, 10, 2)));
    });

    testWidgets('las medidas del mockup se respetan', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(tester.getSize(_cell(3)).height, MonthGrid.cellSize);
      expect(tester.getSize(_cell(3)).width, MonthGrid.cellSize);
    });
  });
}