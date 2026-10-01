import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../models/schedule_event.dart';
import 'schedule_painting.dart';

/// Línea de tiempo del día actual con sus 24 horas (mockup 04).
///
/// Cada hora ocupa una fila de 56 px con su etiqueta (formato 24 h) a la
/// izquierda. Tocar un hueco abre la creación de una franja ([onCreateEvent]),
/// con el minuto deducido de la posición vertical del toque. Las franjas se
/// dibujan encima, posicionadas por su hora de inicio y duración: las que
/// contienen a otras quedan al fondo y las contenidas se pintan encima
/// (orden por contención, independiente del orden de creación). Al tocar una
/// franja se notifica [onTapEvent]. Una línea horizontal marca la hora actual
/// y se recalcula en cada `build` (al volver a entrar en la pantalla).
class DayTimeline extends StatelessWidget {
  const DayTimeline({
    super.key,
    required this.controller,
    required this.events,
    required this.onCreateEvent,
    required this.onTapEvent,
    this.showNowLine = true,
  });

  /// Controlador del desplazamiento vertical (scroll inicial hacia la hora actual).
  final ScrollController controller;

  /// Franjas del día a dibujar.
  final List<ScheduleEvent> events;

  /// Si se dibuja la línea de la hora actual. La pantalla lo desactiva al
  /// mostrar un día que no es hoy: esa marca solo tiene sentido sobre el día
  /// en el que ocurre.
  final bool showNowLine;

  /// Notifica la hora de inicio de una nueva franja al tocar un hueco.
  final ValueChanged<DateTime> onCreateEvent;

  /// Notifica la franja tocada (para abrir el menú editar/eliminar).
  final ValueChanged<ScheduleEvent> onTapEvent;

  /// Altura de cada fila de hora (mockup 04): 56 px.
  static const double hourHeight = 56;

  /// Ancho de la columna de etiquetas de hora (mockup 04): 52 px.
  static const double hourLabelWidth = 52;

  /// Horas representadas en el día.
  static const int hoursCount = 24;

  /// Alto total de la línea de tiempo.
  static double get totalHeight => hoursCount * hourHeight;

  /// Píxeles desde el inicio del día hasta [time].
  static double offsetFor(DateTime time) {
    final minutes = time.hour * 60 + time.minute;
    return minutes / 60 * hourHeight;
  }

  @override
  Widget build(BuildContext context) {
    // Hora capturada en cada reconstrucción: al volver a entrar en la pestaña
    // Agenda (que vive en un IndexedStack) la pantalla se reconstruye y la
    // marca de la hora actual se renueva sin necesidad de un temporizador.
    final now = DateTime.now();
    // Orden de pintado por contención: si una franja contiene a otra (empieza
    // antes o a la misma hora y termina después o a la misma hora), se dibuja
    // detrás de ella. El orden se deduce solo de los intervalos (inicio asc,
    // fin desc), por lo que el apilado no depende del orden de creación o
    // edición. Las franjas con el mismo intervalo exacto comparten clave y se
    // reparten el ancho en franjas verticales (ver _EventBlock), sin
    // superponerse.
    final ordered = [...events]..sort((a, b) {
      final byStart = a.start.compareTo(b.start);
      if (byStart != 0) return byStart;
      return b.end.compareTo(a.end);
    });
    final slotIndex = <String, int>{};
    final slotCount = <String, int>{};
    final byInterval = <String, List<ScheduleEvent>>{};
    for (final event in ordered) {
      final key =
          '${event.start.microsecondsSinceEpoch}-${event.end.microsecondsSinceEpoch}';
      byInterval.putIfAbsent(key, () => []).add(event);
    }
    for (final group in byInterval.values) {
      for (var i = 0; i < group.length; i++) {
        slotIndex[group[i].id] = i;
        slotCount[group[i].id] = group.length;
      }
    }

    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        key: const Key('day-timeline'),
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        child: SizedBox(
          height: totalHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Ancho disponible para las franjas (sin la columna de horas).
              final trackWidth = constraints.maxWidth - hourLabelWidth;
              return Stack(
                children: [
                  // Capa base: filas de hora; cada pista abre la creación.
                  Column(
                    children: [
                      for (var h = 0; h < hoursCount; h++)
                        _HourRow(
                          hour: h,
                          height: hourHeight,
                          labelWidth: hourLabelWidth,
                          onTap: onCreateEvent,
                        ),
                    ],
                  ),
                  // Capa de franjas, en orden de contención: las que contienen
                  // a otras quedan al fondo y las contenidas, encima.
                  for (var i = 0; i < ordered.length; i++)
                    _EventBlock(
                      event: ordered[i],
                      paletteIndex: i,
                      trackWidth: trackWidth,
                      slotIndex: slotIndex[ordered[i].id] ?? 0,
                      slotCount: slotCount[ordered[i].id] ?? 1,
                      onTap: () => onTapEvent(ordered[i]),
                    ),
                  // Marca de la hora actual, encima de las franjas.
                  if (showNowLine) _NowLine(now: now),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Fila de una hora: etiqueta «HH:00» a la izquierda y pista.
///
/// El borde superior dibuja la línea de cuadrícula; la primera fila no lleva
/// borde (como en el mockup). La etiqueta se sube 7 px para que cruce la
/// cuadrícula. El gesto de toque calcula el minuto desde la posición vertical
/// (redondeando al cuarto de hora) y notifica el instante de inicio.
class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.hour,
    required this.height,
    required this.labelWidth,
    required this.onTap,
  });

  final int hour;
  final double height;
  final double labelWidth;
  final ValueChanged<DateTime> onTap;

  /// Etiqueta en formato 24 h: «00:00» … «23:00».
  String get _label => scheduleHourLabel(hour);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final minutesFromTap =
            (details.localPosition.dy / height * 60).round();
        // Redondea al cuarto de hora más cercano dentro de la misma hora.
        final minute = (minutesFromTap / 15).round() * 15;
        final now = DateTime.now();
        final day = DateTime(now.year, now.month, now.day);
        onTap(
          day.add(
            Duration(hours: hour, minutes: minute.clamp(0, 59)),
          ),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: hour == 0
              ? null
              : const Border(top: BorderSide(color: AppColors.lineFaint)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: labelWidth,
              height: height,
              child: Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: const Offset(0, -7),
                  child: Text(_label, style: AppTextStyles.hourLabel),
                ),
              ),
            ),
            // Pista de la hora (hueco donde se crean franjas).
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

/// Bloque de una franja, posicionado sobre la cuadrícula.
class _EventBlock extends StatelessWidget {
  const _EventBlock({
    required this.event,
    required this.paletteIndex,
    required this.trackWidth,
    required this.slotIndex,
    required this.slotCount,
    required this.onTap,
  });

  final ScheduleEvent event;

  /// Índice en [scheduleBlockPalettes] para elegir color y texto del bloque.
  final int paletteIndex;

  /// Ancho total disponible para las franjas (contenido menos etiquetas).
  final double trackWidth;

  /// Posición dentro de las franjas con el mismo intervalo exacto.
  final int slotIndex;

  /// Número de franjas que comparten el mismo intervalo exacto.
  final int slotCount;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = scheduleBlockPaletteAt(paletteIndex);
    final top = DayTimeline.offsetFor(event.start).clamp(0.0, DayTimeline.totalHeight);
    final maxHeight = DayTimeline.totalHeight - top;
    final durationHeight = event.duration.inSeconds / 3600 * DayTimeline.hourHeight;
    final height = durationHeight.clamp(0.0, maxHeight);
    // Reparto en franjas verticales cuando varias coinciden en la misma hora;
    // en caso contrario la franja ocupa todo el ancho de la pista.
    final slotWidth = trackWidth / slotCount;
    final left = DayTimeline.hourLabelWidth + (slotIndex * slotWidth);
    final timeRange = scheduleTimeRange(context, event);

    return Positioned(
      key: ValueKey('event-block-${event.id}'),
      left: left,
      top: top,
      width: slotWidth,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: palette.bg,
            border: palette.outline
                ? Border.all(color: AppColors.line)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.eventName.copyWith(color: palette.fg),
              ),
              const SizedBox(height: 2),
              Text(
                timeRange,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.eventTime.copyWith(color: palette.fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Línea horizontal que marca la hora actual (el `--now` del mockup 04).
///
/// Dibuja una línea de 2 px en rosa con un punto en su arranque. Ignora los
/// toques para no bloquear la creación o edición de franjas. La hora llega
/// recalculada desde el `build` de la línea de tiempo ([DayTimeline.build]).
class _NowLine extends StatelessWidget {
  const _NowLine({required this.now});

  /// Instante capturado al reconstruir la pantalla.
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final top = DayTimeline.offsetFor(now).clamp(0.0, DayTimeline.totalHeight);
    return Positioned(
      key: const Key('now-line'),
      left: DayTimeline.hourLabelWidth,
      right: 0,
      top: top,
      height: 2,
      child: IgnorePointer(
        child: Stack(
          children: [
            // Línea de 2 px a todo lo ancho.
            Align(
              alignment: Alignment.centerLeft,
              child: Container(height: 2, color: AppColors.rose),
            ),
            // Punto de 8 px centrado sobre el arranque de la línea.
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