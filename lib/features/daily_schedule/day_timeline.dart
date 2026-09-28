import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../models/schedule_event.dart';

/// Línea de tiempo del día actual con sus 24 horas (mockup 04).
///
/// Cada hora ocupa una fila de 56 px con su etiqueta (formato 24 h) a la
/// izquierda. Tocar un hueco abre la creación de una franja ([onCreateEvent]),
/// con el minuto deducido de la posición vertical del toque. Las franjas se
/// dibujan encima, posicionadas por su hora de inicio y duración, y al tocarlas
/// se notifica [onTapEvent].
class DayTimeline extends StatelessWidget {
  const DayTimeline({
    super.key,
    required this.controller,
    required this.events,
    required this.onCreateEvent,
    required this.onTapEvent,
  });

  /// Controlador del desplazamiento vertical (scroll inicial hacia la hora actual).
  final ScrollController controller;

  /// Franjas del día a dibujar.
  final List<ScheduleEvent> events;

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
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        key: const Key('day-timeline'),
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        child: SizedBox(
          height: totalHeight,
          child: Stack(
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
              // Capa de franjas posicionadas sobre la cuadrícula.
              for (var i = 0; i < events.length; i++)
                _EventBlock(
                  event: events[i],
                  paletteIndex: i,
                  onTap: () => onTapEvent(events[i]),
                ),
            ],
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
  String get _label => '${hour.toString().padLeft(2, '0')}:00';

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

/// Colores de los bloques del mockup 04, en ciclo por índice: pine, ámbar,
/// rosa y neutro con borde.
const List<({Color bg, Color fg, bool outline})> _eventPalettes = [
  (bg: AppColors.pinePale, fg: AppColors.pineDeep, outline: false),
  (bg: AppColors.amberPale, fg: AppColors.amberDeep, outline: false),
  (bg: AppColors.rosePale, fg: AppColors.roseDeep, outline: false),
  (bg: AppColors.cardBg, fg: AppColors.ink, outline: true),
];

/// Bloque de una franja, posicionado sobre la cuadrícula.
class _EventBlock extends StatelessWidget {
  const _EventBlock({
    required this.event,
    required this.paletteIndex,
    required this.onTap,
  });

  final ScheduleEvent event;

  /// Índice en [_eventPalettes] para elegir color y texto del bloque.
  final int paletteIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _eventPalettes[paletteIndex % _eventPalettes.length];
    final top = DayTimeline.offsetFor(event.start).clamp(0.0, DayTimeline.totalHeight);
    final maxHeight = DayTimeline.totalHeight - top;
    final durationHeight = event.duration.inSeconds / 3600 * DayTimeline.hourHeight;
    final height = durationHeight.clamp(0.0, maxHeight);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final start = DateFormat.Hm(locale).format(event.start);
    final end = DateFormat.Hm(locale).format(event.end);

    return Positioned(
      left: DayTimeline.hourLabelWidth,
      top: top,
      right: 0,
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
                '$start – $end',
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