import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/palette.dart';
import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/habit.dart';

/// Rejilla mensual del calendario de hábitos (ver mockup 03).
///
/// Encima, la fila de siglas de los días y debajo los números del mes en una
/// columna por día, empezando en lunes. El fondo de cada celda lo decide el
/// estado del día (ver [DayStatus]) y el anillo marca el día que se está
/// mirando, que es el que gobierna los checks de abajo.
///
/// No dibuja la leyenda ni el título del mes: la pantalla compone las tres
/// piezas, porque la leyenda solo tiene sentido junto a la lista.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.today,
    required this.selectedDay,
    required this.statusOf,
    required this.onTapDay,
  });

  /// Primer día del mes visible, a las 00:00.
  final DateTime month;

  /// Hoy a las 00:00: referencia para saber qué días aún no se han cerrado.
  final DateTime today;

  /// Día cuyos hábitos muestra la lista de abajo.
  final DateTime selectedDay;

  /// Estado de un día del mes visible, que decide el fondo de su celda.
  final DayStatus Function(DateTime day) statusOf;

  /// Notifica el día tocado; la lista de checks pasa a mostrar sus hábitos.
  final ValueChanged<DateTime> onTapDay;

  /// Lado de la celda pintada (el anillo de hoy se dibuja fuera, con 2 de
  /// margen a cada lado).
  static const double cellSize = 32;

  /// Grosor del anillo que marca el día seleccionado y el de hoy.
  static const double ringWidth = 2;

  /// Separación entre filas (`row-gap` de la rejilla del mockup).
  static const double rowGap = 8;

  /// Separación entre la fila de siglas y la rejilla.
  static const double weekdayGap = 10;

  /// Días por semana.
  static const int daysPerWeek = 7;

  /// El día a las 00:00, que es la referencia de todas las comparaciones.
  static DateTime _dateOf(DateTime day) =>
      DateTime(day.year, day.month, day.day);

  @override
  Widget build(BuildContext context) {
    final cells = _cells();
    final palette = Palette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeekdayRow(initials: _weekdayInitials(context)),
        const SizedBox(height: weekdayGap),
        for (var row = 0; row < cells.length ~/ daysPerWeek; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: rowGap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var column = 0; column < daysPerWeek; column++)
                  Expanded(child: _slot(cells[row * daysPerWeek + column], palette)),
              ],
            ),
          ),
      ],
    );
  }

  /// Siglas de los días en el idioma activo, empezando en lunes.
  ///
  /// Se pide el nombre corto (`EEEEE`), que en español es justo la serie del
  /// mockup (L M X J V S D) y en inglés la de las iniciales (M T W T F S S). La
  /// inicial del nombre abreviado no sirve: en español «mar» y «mié» empezarían
  /// por la misma letra.
  static List<String> _weekdayInitials(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Lunes de esta semana como referencia: el orden de la rejilla no cambia
    // con el mes que se esté mirando.
    final today = _dateOf(DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return [
      for (var day = 0; day < daysPerWeek; day++)
        DateFormat('EEEEE', locale)
            .format(monday.add(Duration(days: day)))
            .substring(0, 1)
            .toUpperCase(),
    ];
  }

  /// Días del mes en filas completas de siete, con `null` en los huecos.
  ///
  /// La primera fila empieza en el día de la semana en que cae el 1 (lunes = 0)
  /// y por delante van los huecos del relleno inicial; al final no se pintan
  /// celdas de días que no existen en el mes.
  List<int?> _cells() {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1;
    final rowCount = ((leading + daysInMonth) / daysPerWeek).ceil();

    return [
      for (var position = 0; position < rowCount * daysPerWeek; position++)
        if (position < leading || position >= leading + daysInMonth)
          null
        else
          position - leading + 1,
    ];
  }

  /// Una casilla de la rejilla: un hueco invisible o el día que toque.
  Widget _slot(int? number, Palette palette) {
    if (number == null) return const SizedBox.shrink();

    final day = DateTime(month.year, month.month, number);
    return _DayCell(
      day: day,
      number: number,
      month: month,
      status: statusOf(day),
      today: today,
      selectedDay: selectedDay,
      palette: palette,
      onTap: onTapDay,
    );
  }
}

/// Celda de un día del calendario.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.number,
    required this.month,
    required this.status,
    required this.today,
    required this.selectedDay,
    required this.palette,
    required this.onTap,
  });

  /// El día, a las 00:00.
  final DateTime day;
  final int number;
  final DateTime month;
  final DayStatus status;
  final DateTime today;
  final DateTime selectedDay;

  /// Paleta activa, para pintar el fondo y el anillo según el tema.
  final Palette palette;

  /// Notifica que se ha tocado esta celda.
  final ValueChanged<DateTime> onTap;

  /// Si la celda es el día de hoy.
  bool get _isToday => _isSameDay(day, today);

  /// Si la celda es el día cuyos hábitos muestra la lista de abajo.
  ///
  /// El anillo pineDeep marca siempre al seleccionado; el de hoy solo se ve
  /// cuando es otro, para saber cuál es hoy sin confundirlo con el que se está
  /// editando.
  bool get _isSelected => _isSameDay(day, selectedDay);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = l10n.habitsDayStatus(
      number,
      _monthName(context),
      _statusLabel(l10n),
    );

    return Semantics(
      label: label,
      button: true,
      selected: _isSelected,
      child: InkWell(
        // Cuadrada y sin radio visible: la celda pintada es la que lleva las
        // esquinas del mockup.
        borderRadius: BorderRadius.circular(MonthGrid.cellSize),
        onTap: () => onTap(day),
        child: Center(
          // El anillo va por fuera de la celda, así que la casilla se reserva
          // su grosor: hoy no descuadra la rejilla.
          child: SizedBox(
            width: _ringSize,
            height: _ringSize,
            child: DecoratedBox(
              key: ValueKey(
                'day-ring-${month.year}-${month.month}-$number',
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _ringColor,
                  width: MonthGrid.ringWidth,
                ),
                borderRadius: BorderRadius.circular(_ringRadius),
              ),
              child: Center(
                child: Container(
                  // La clave va en la celda pintada, que es la que lleva el
                  // color con el que se juzga el día.
                  key: ValueKey(
                    'day-cell-${month.year}-${month.month}-$number',
                  ),
                  width: MonthGrid.cellSize,
                  height: MonthGrid.cellSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.circular(_cellRadius),
                  ),
                  child: Text('$number', style: _textStyle),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Nombre del mes visible, para el texto que anuncia el lector de pantalla.
  String _monthName(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.MMMM(locale).format(month);
  }

  String _statusLabel(AppLocalizations l10n) => switch (status) {
        DayStatus.done => l10n.habitsStatusDone,
        DayStatus.missed => l10n.habitsStatusMissed,
        DayStatus.future => l10n.habitsStatusFuture,
        _ => l10n.habitsStatusNeutral,
      };

  /// Radio de la celda pintada (mockup 03); el anillo que la envuelve va algo
  /// más redondeado para acompañar las esquinas por fuera.
  static const double _cellRadius = 9;

  /// Lado de la casilla con su anillo: la celda más el grosor del anillo a
  /// cada lado, que es lo que ocupa la fila de la rejilla.
  static const double _ringSize =
      MonthGrid.cellSize + MonthGrid.ringWidth * 2;

  static const double _ringRadius = _cellRadius + MonthGrid.ringWidth;

  /// Fondo de la celda según el estado del día.
  Color get _background => switch (status) {
        DayStatus.done => palette.done,
        DayStatus.missed => palette.missPale,
        DayStatus.future => palette.futurePale,
        _ => palette.cardBg,
      };

  TextStyle get _textStyle {
    final styles = AppTextStyles.from(palette);
    return switch (status) {
      DayStatus.done => styles.dayDone,
      DayStatus.missed => styles.dayMissed,
      DayStatus.future => styles.dayFuture,
      _ => styles.dayNeutral,
    };
  }

  Color get _ringColor {
    if (_isSelected) return palette.pineDeep;
    if (_isToday) return palette.line;
    return Colors.transparent;
  }
}

/// Fila de las siglas de los días, una por columna de la rejilla.
///
/// Cada sigla se reserva también como etiqueta de la columna para que el
/// lector de pantalla sepa qué día es el que se toca.
class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.initials});

  /// Siglas de lunes a domingo.
  final List<String> initials;

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles.of(context);

    return Row(
      key: const Key('weekday-row'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final initial in initials)
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                initial,
                textAlign: TextAlign.center,
                style: styles.weekdayInitial,
              ),
            ),
          ),
      ],
    );
  }
}

/// Leyenda de los dos colores con los que se juzga un día (mockup 03).
///
/// Da la clave de la rejilla sin tener que leer los estados: verde es un día
/// cerrado con todo cumplido, rojo es un día que se quedó corto.
class HabitLegend extends StatelessWidget {
  const HabitLegend({super.key});

  /// Lado de las muestras de color.
  static const double swatchSize = 10;

  /// Separación entre muestra y texto, y entre los dos ítems.
  static const double gap = 7;

  static const double _itemsGap = 18;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);

    // `Wrap` y no `Row`: en una pantalla estrecha la segunda muestra baja de
    // línea en vez de salirse del papel.
    return Wrap(
      key: const Key('habits-legend'),
      spacing: _itemsGap,
      runSpacing: 6,
      children: [
        _item(l10n.habitsLegendDone, palette.done, styles),
        _item(l10n.habitsLegendMissed, palette.missPale, styles),
      ],
    );
  }

  Widget _item(String label, Color color, AppTextStyles styles) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: swatchSize,
          height: swatchSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: gap),
        Text(label, style: styles.legendLabel),
      ],
    );
  }
}