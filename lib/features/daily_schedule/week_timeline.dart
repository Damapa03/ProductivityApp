import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../models/schedule_event.dart';
import 'schedule_painting.dart';

/// Rejilla de la semana completa con sus 24 horas (mockup 04b).
///
/// Es la misma vista de agenda que [DayTimeline] pero con los siete días de la
/// semana (lunes a domingo) en columnas, en lugar de un único día. Las
/// funciones son las mismas: tocar un hueco abre la creación de una franja con
/// la fecha y la hora de esa celda ([onCreateEvent]) y tocar una franja notifica
/// [onTapEvent] para editarla o eliminarla. Los bloques, la paleta y las
/// etiquetas de hora se comparten con la vista diaria (ver
/// `schedule_painting.dart`).
///
/// La rejilla ocupa todo el ancho del que puede: las siete columnas se reparten
/// a partes iguales el espacio sobrante, sin techo, de modo que la semana llena
/// la pantalla por muy ancha que sea. [minDayWidth] es el suelo; por debajo, las
/// columnas no encogen más y la rejilla se desplaza en horizontal.
///
/// La fila con la sigla y el número de cada día queda fija arriba y solo se
/// desplazan las 24 horas (con el [controller] que le pasa la pantalla para
/// reenfocar la hora actual), así que siempre se sabe en qué día se está. Cada
/// columna y cada cabecera llevan su línea vertical izquierda, que separa un
/// día del siguiente. Ninguna columna lleva tinte de fondo, ni siquiera los días
/// que ya han pasado: solo el de hoy se resalta en la cabecera. A la derecha
/// queda un respiro de [rightGutter] para que la última columna no toque el
/// borde de la pantalla.
class WeekTimeline extends StatelessWidget {
  const WeekTimeline({
    super.key,
    required this.controller,
    required this.weekStart,
    required this.events,
    required this.onCreateEvent,
    required this.onTapEvent,
  });

  /// Controlador del desplazamiento vertical.
  final ScrollController controller;

  /// Lunes de la semana mostrada, a las 00:00 (ver [startOfWeek]).
  final DateTime weekStart;

  /// Franjas de la semana a dibujar, ya filtradas por la pantalla.
  final List<ScheduleEvent> events;

  /// Notifica el inicio de una nueva franja al tocar un hueco, con la fecha de
  /// la columna y la hora de la fila.
  final ValueChanged<DateTime> onCreateEvent;

  /// Notifica la franja tocada (para abrir el menú editar/eliminar).
  final ValueChanged<ScheduleEvent> onTapEvent;

  /// Días de la semana: de lunes a domingo.
  static const int daysCount = 7;

  /// Altura de cada fila de hora (mockup 04b): 38 px.
  static const double hourHeight = 38;

  /// Horas representadas, igual que en la vista diaria.
  static const int hoursCount = 24;

  /// Ancho de la columna de etiquetas de hora (mockup 04b): 38 px.
  static const double hourLabelWidth = 38;

  /// Ancho mínimo de una columna de día (mockup 04b): 46 px.
  ///
  /// Por debajo de este ancho el título de una franja deja de leerse, así que
  /// en pantallas muy estrechas la rejilla se sale a scroll en vez de encoger
  /// las columnas.
  static const double minDayWidth = 46;

  /// Alto de la cabecera de días (sigla + número): queda fija sobre el
  /// desplazamiento de las horas, así que los siete días se leen siempre.
  static const double dayHeaderHeight = 44;

  /// Alto total de las 24 horas.
  static double get totalHeight => hoursCount * hourHeight;

  /// Respiro a la derecha de la rejilla, para que la última columna no quede
  /// pegada al borde de la pantalla y su separador se lea suelto.
  ///
  /// Va incluido en el ancho de la rejilla, no como margen por fuera: así la
  /// semana sigue estirándose hasta llenar la pantalla y el hueco se come el
  /// sobrante repartido entre los siete días.
  static const double rightGutter = 8;

  /// Ancho de cada columna de día para un ancho disponible [availableWidth].
  ///
  /// La rejilla se estira todo lo que pueda: los siete días se reparten a
  /// partes iguales el sobrante, sin techo, de modo que en un monitor la
  /// semana ocupa la pantalla entera. [minDayWidth] es el suelo: por debajo la
  /// rejilla deja de caber y aparece el desplazamiento horizontal.
  static double dayWidthFor(double availableWidth) {
    final available =
        (availableWidth - hourLabelWidth - rightGutter) / daysCount;
    return math.max(minDayWidth, available);
  }

  /// `true` si con un ancho de [availableWidth] la rejilla no cabe entera y hay
  /// que desplazarla en horizontal.
  static bool needsHorizontalScroll(double availableWidth) =>
      gridWidthFor(dayWidthFor(availableWidth)) > availableWidth;

  /// Ancho total de la rejilla con columnas de [dayWidth], hora y respiro
  /// incluidos.
  static double gridWidthFor(double dayWidth) =>
      hourLabelWidth + daysCount * dayWidth + rightGutter;

  /// Margen interior de un bloque dentro de su columna.
  static const double blockInset = 2;

  /// Alto mínimo de un bloque: una franja de 15 minutos ocupa 9,5 px y su
  /// título no se leería, así que se dibuja algo más alta.
  static const double minBlockHeight = 16;

  /// Lunes de la semana a la que pertenece [date], a las 00:00.
  static DateTime startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  /// Rango de la semana en texto («6 – 12 sept»), con mayúscula inicial.
  ///
  /// El mes solo se escribe una vez cuando los dos días son del mismo mes.
  static String rangeLabel(BuildContext context, DateTime weekStart) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final lastDay = weekStart.add(const Duration(days: daysCount - 1));
    final month = DateFormat.MMM(locale);
    final from = weekStart.month == lastDay.month
        ? '${weekStart.day}'
        : '${weekStart.day} ${month.format(weekStart)}';
    final to = '${lastDay.day} ${month.format(lastDay)}';
    final range = '$from – $to';
    return range[0].toUpperCase() + range.substring(1);
  }

  /// Píxeles desde el inicio del día hasta [time].
  static double offsetFor(DateTime time) =>
      (time.hour * 60 + time.minute) / 60 * hourHeight;

  /// Identificador de la columna de un día, para pruebas y para el tap por
  /// posición en tests.
  static Key dayColumnKey(int dayIndex) => ValueKey('week-day-$dayIndex');

  @override
  Widget build(BuildContext context) {
    // Hora capturada en cada reconstrucción: al volver a entrar en la pestaña
    // Agenda (que vive en un IndexedStack) la marca de la hora actual se
    // renueva sin necesidad de un temporizador.
    final now = DateTime.now();

    return LayoutBuilder(
      builder: (context, constraints) {
        // La rejilla se estira todo lo que pueda: los siete días reparten a
        // partes iguales el ancho sobrante. Solo cuando ni con el ancho mínimo
        // de columna cabe entera se desplaza en horizontal.
        final dayWidth = dayWidthFor(constraints.maxWidth);
        final gridWidth = gridWidthFor(dayWidth);
        final scrollsSideways = gridWidth > constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Los nombres de los días se quedan fijos arriba: solo las horas se
            // desplazan, así que por muy abajo que se baje se sabe siempre en
            // qué día se está.
            SizedBox(
              height: dayHeaderHeight,
              child: _sideways(
                SizedBox(width: gridWidth, child: _dayHeaders(dayWidth)),
                scrollsSideways,
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: controller,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  key: const Key('week-timeline'),
                  controller: controller,
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _sideways(
                    SizedBox(
                      width: gridWidth,
                      child: _hourGrid(dayWidth, now),
                    ),
                    scrollsSideways,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Envuelve [child] en el desplazamiento horizontal cuando la rejilla no cabe
  /// en el ancho disponible. Con [scrollsSideways] a `false` se devuelve tal
  /// cual: en una pantalla normal no hay nada que desplazar en este eje.
  Widget _sideways(Widget child, bool scrollsSideways) {
    if (!scrollsSideways) return child;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: child,
    );
  }

  /// Fila con la sigla y el número de los siete días.
  ///
  /// Lleva su propio borde inferior, que hace de línea de separación entre los
  /// días y las horas y además cierra la cabecera al desplazarla.
  Widget _dayHeaders(double dayWidth) {
    return Row(
      children: [
        // Hueco sobre las etiquetas de hora, a la altura de la cabecera.
        const SizedBox(width: hourLabelWidth, height: dayHeaderHeight),
        for (var dayIndex = 0; dayIndex < daysCount; dayIndex++)
          Builder(
            builder: (context) {
              final day = weekStart.add(Duration(days: dayIndex));
              return _DayHeader(
                day: day,
                width: dayWidth,
                isToday: _isToday(day),
              );
            },
          ),
        // Respiro final, el mismo que deja la rejilla de horas.
        const SizedBox(width: rightGutter),
      ],
    );
  }

  /// Las 24 horas de los siete días con las franjas encima y la línea de la
  /// hora actual, que solo aparece si hoy está en la semana mostrada.
  Widget _hourGrid(double dayWidth, DateTime now) {
    final todayIndex = todayIndexIn(weekStart, now);

    // Paleta por franja, recorriendo el orden de pintado.
    var paletteIndex = 0;
    final blocks = <Widget>[];
    for (var dayIndex = 0; dayIndex < daysCount; dayIndex++) {
      final day = weekStart.add(Duration(days: dayIndex));
      // Cada franja va a la columna del día en que empieza, el mismo criterio
      // que usa la vista diaria: una franja de madrugada aparece en la columna
      // de la noche en la que se abrió, no en la del día siguiente.
      final dayEvents = events
          .where(
            (e) =>
                e.start.year == day.year &&
                e.start.month == day.month &&
                e.start.day == day.day,
          )
          .toList();
      // Las franjas que se pisan entre sí se reparten el ancho de la columna.
      final columns = layoutDayColumns(dayEvents);
      for (final event in dayEvents) {
        final slot = columns[event.id] ?? (column: 0, columns: 1);
        final slotWidth = (dayWidth - 2 * blockInset) / slot.columns;
        blocks.add(
          _WeekEventBlock(
            event: event,
            paletteIndex: paletteIndex,
            left: hourLabelWidth +
                dayIndex * dayWidth +
                blockInset +
                slot.column * slotWidth,
            width: slotWidth - 1,
            onTap: () => onTapEvent(event),
          ),
        );
        paletteIndex++;
      }
    }

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // Capa base: las 24 horas de cada día; cada celda abre la creación
          // de una franja.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HourLabelColumn(),
              for (var dayIndex = 0; dayIndex < daysCount; dayIndex++)
                Builder(
                  builder: (context) {
                    final day = weekStart.add(Duration(days: dayIndex));
                    return _DayColumn(
                      key: dayColumnKey(dayIndex),
                      day: day,
                      width: dayWidth,
                      onTap: onCreateEvent,
                    );
                  },
                ),
              // Respiro final, el mismo que deja la cabecera de días.
              const SizedBox(width: rightGutter),
            ],
          ),
          // Capa de franjas, encima de la rejilla.
          ...blocks,
          if (todayIndex >= 0)
            _NowLine(now: now, dayIndex: todayIndex, dayWidth: dayWidth),
        ],
      ),
    );
  }
}

/// Reparto de las franjas de un día en subcolumnas, para que las que se pisan
/// no se tapen entre sí en una columna tan estrecha.
///
/// Agrupa por solapamiento: una franja entra en el grupo mientras empiece antes
/// de que terminen todas las del grupo, así que dos franjas con el mismo
/// intervalo comparten el ancho y tres encadenadas («9–10», «9:30–10:30»,
/// «10–11») se reparten en tres. Devuelve, por id de franja, su subcolumna y
/// cuántas hay en su grupo.
Map<String, ({int column, int columns})> layoutDayColumns(
  List<ScheduleEvent> events,
) {
  final ordered = [...events]..sort((a, b) {
    final byStart = a.start.compareTo(b.start);
    if (byStart != 0) return byStart;
    // A igual hora de inicio, la más larga primero: la más corta queda
    // encima al pintarse después.
    return b.end.compareTo(a.end);
  });

  final result = <String, ({int column, int columns})>{};
  // Final de la última franja de cada subcolumna del grupo en curso.
  final slotEnds = <DateTime>[];
  final group = <({ScheduleEvent event, int column})>[];
  var groupEnd = DateTime.fromMillisecondsSinceEpoch(0);

  void closeGroup() {
    for (final member in group) {
      result[member.event.id] = (
        column: member.column,
        columns: slotEnds.length,
      );
    }
    group.clear();
    slotEnds.clear();
    groupEnd = DateTime.fromMillisecondsSinceEpoch(0);
  }

  for (final event in ordered) {
    // La franja arranca cuando ya no pisa a ninguna del grupo: se cierra el
    // grupo y empieza uno nuevo, para que no compartan ancho.
    if (group.isNotEmpty && !event.start.isBefore(groupEnd)) closeGroup();

    var column = slotEnds.indexWhere((end) => !end.isAfter(event.start));
    if (column == -1) {
      column = slotEnds.length;
      slotEnds.add(event.end);
    } else {
      slotEnds[column] = event.end;
    }
    group.add((event: event, column: column));
    if (event.end.isAfter(groupEnd)) groupEnd = event.end;
  }
  closeGroup();

  return result;
}

/// Si [a] y [b] caen en el mismo día, sin mirar la hora.
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Si [day] es el día en el que se está ejecutando la pantalla.
bool _isToday(DateTime day) => _sameDay(day, DateTime.now());

/// Columna de hoy dentro de la semana que empieza en [weekStart], o `-1` si la
/// semana mostrada es otra.
///
/// Sin este chequeo, mirar el lunes de la semana siguiente resaltaría la
/// columna del lunes creyendo que es hoy y la línea de la hora actual caería
/// sobre un día que no lo es.
@visibleForTesting
int todayIndexIn(DateTime weekStart, DateTime today) {
  final monday = DateTime(weekStart.year, weekStart.month, weekStart.day);
  final day = DateTime(today.year, today.month, today.day);
  if (day.isBefore(monday)) return -1;
  if (!day.isBefore(monday.add(const Duration(days: WeekTimeline.daysCount)))) {
    return -1;
  }
  return day.weekday - DateTime.monday;
}

/// Cabecera de un día de la semana: sigla y número, con el de hoy resaltado
/// (`pinePale` de fondo y número en `pineDeep`, como el mockup 04b).
///
/// Solo el de hoy lleva tinte: los días que ya han pasado se ven igual que los
/// que vienen, y es el desplazamiento de las horas el que dice si un día está
/// atrás. El borde izquierdo de cada cabecera es la línea que separa un día
/// del siguiente.
class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.width,
    required this.isToday,
  });

  final DateTime day;
  final double width;

  /// Si la columna es la del día actual.
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final name = DateFormat.E(locale).format(day);
    final number = '${day.day}';

    return Container(
      key: ValueKey('week-day-header-${day.day}'),
      width: width,
      height: WeekTimeline.dayHeaderHeight,
      decoration: BoxDecoration(
        color: isToday ? AppColors.pinePale : null,
        border: const Border(
          bottom: BorderSide(color: AppColors.line),
          left: BorderSide(color: AppColors.lineFaint),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name[0].toUpperCase() + name.substring(1),
            maxLines: 1,
            style: AppTextStyles.weekDayName,
          ),
          Text(
            number,
            style: AppTextStyles.weekDayNumber.copyWith(
              color: isToday ? AppColors.pineDeep : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// Columna de etiquetas de hora, a la izquierda de los siete días.
///
/// Una etiqueta por fila, subida 6 px para que cruce la cuadrícula (mockup
/// 04b). No recibe toques: la creación de franjas vive en las celdas de los
/// días.
class _HourLabelColumn extends StatelessWidget {
  const _HourLabelColumn();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: WeekTimeline.hourLabelWidth,
      child: Column(
        children: [
          for (var hour = 0; hour < WeekTimeline.hoursCount; hour++)
            SizedBox(
              height: WeekTimeline.hourHeight,
              child: Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: const Offset(0, -6),
                  child: Text(
                    scheduleHourLabel(hour),
                    style: AppTextStyles.hourLabel,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Columna de un día con sus 24 celdas de hora.
///
/// El gesto calcula el minuto desde la posición vertical del toque
/// (redondeando al cuarto de hora, igual que la vista diaria) y notifica el
/// instante aplicado sobre la fecha de la columna.
///
/// Ninguna columna lleva tinte de fondo, ni siquiera las de días que ya han
/// pasado: la rejilla se lee por igual y es el desplazamiento de las horas lo
/// que dice si un día está atrás. El borde izquierdo de cada celda es la línea
/// que separa un día del siguiente, y continúa la de la cabecera.
class _DayColumn extends StatelessWidget {
  const _DayColumn({
    super.key,
    required this.day,
    required this.width,
    required this.onTap,
  });

  /// Día al que pertenece la columna, a las 00:00.
  final DateTime day;
  final double width;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          for (var hour = 0; hour < WeekTimeline.hoursCount; hour++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final minutesFromTap =
                    (details.localPosition.dy / WeekTimeline.hourHeight * 60)
                        .round();
                // Redondea al cuarto de hora más cercano dentro de la misma
                // hora (mismo criterio que la vista diaria).
                final minute = (minutesFromTap / 15).round() * 15;
                onTap(
                  day.add(
                    Duration(hours: hour, minutes: minute.clamp(0, 59)),
                  ),
                );
              },
              child: Container(
                height: WeekTimeline.hourHeight,
                decoration: BoxDecoration(
                  border: Border(
                    top: hour == 0
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.lineFaint),
                    // Separador entre días, en la misma línea que la cabecera.
                    left: const BorderSide(color: AppColors.lineFaint),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bloque de una franja dentro de la columna de su día.
///
/// Solo lleva el título: las columnas son demasiado estrechas para las horas,
/// que ya se deducen de la posición vertical.
class _WeekEventBlock extends StatelessWidget {
  const _WeekEventBlock({
    required this.event,
    required this.paletteIndex,
    required this.left,
    required this.width,
    required this.onTap,
  });

  final ScheduleEvent event;

  final int paletteIndex;

  /// Distancia horizontal al borde izquierdo de la rejilla.
  final double left;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = scheduleBlockPaletteAt(paletteIndex);
    final top = WeekTimeline.offsetFor(event.start)
        .clamp(0.0, WeekTimeline.totalHeight);
    final maxHeight = WeekTimeline.totalHeight - top;
    // Una franja corta (15 min ≈ 9,5 px) se dibuja algo más alta para que su
    // título se lea, pero sin salirse nunca del día: al final de la noche el
    // hueco que queda es menor que ese mínimo.
    final preferred = math.max(
      event.duration.inSeconds / 3600 * WeekTimeline.hourHeight,
      math.min(WeekTimeline.minBlockHeight, maxHeight),
    );
    final height = preferred.clamp(0.0, maxHeight);

    return Positioned(
      key: ValueKey('event-block-${event.id}'),
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: palette.bg,
            border: palette.outline
                ? Border.all(color: AppColors.line)
                : null,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.weekEventName.copyWith(color: palette.fg),
          ),
        ),
      ),
    );
  }
}

/// Línea de la hora actual, solo en la columna de hoy (mockup 04b).
///
/// Dibuja una línea de 2 px en rosa con un punto en su arranque. Ignora los
/// toques para no bloquear la creación o edición de franjas. La hora llega
/// recalculada desde el `build` de la rejilla.
class _NowLine extends StatelessWidget {
  const _NowLine({
    required this.now,
    required this.dayIndex,
    required this.dayWidth,
  });

  /// Instante capturado al reconstruir la pantalla.
  final DateTime now;

  /// Columna del día actual, de lunes a domingo.
  final int dayIndex;

  /// Ancho de una columna de día, ya calculado para la pantalla.
  final double dayWidth;

  @override
  Widget build(BuildContext context) {
    final top = WeekTimeline.offsetFor(now).clamp(0.0, WeekTimeline.totalHeight);
    return Positioned(
      key: const Key('week-now-line'),
      left: WeekTimeline.hourLabelWidth + dayIndex * dayWidth,
      top: top,
      width: dayWidth,
      height: 2,
      child: IgnorePointer(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(height: 2, color: AppColors.rose),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: const Offset(-4, 0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.rose,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
