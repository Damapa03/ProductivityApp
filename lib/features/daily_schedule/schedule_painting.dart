import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../models/schedule_event.dart';

/// Piezas de pintado compartidas por las dos vistas de la agenda.
///
/// La vista diaria ([DayTimeline]) y la semanal ([WeekTimeline]) dibujan las
/// mismas franjas con la misma paleta y las mismas etiquetas de hora, así que
/// ambos toman de aquí el color y el formato para que no se desincronicen.

/// Colores de un bloque de franja, elegidos por el ciclo del mockup 04.
typedef ScheduleBlockPalette = ({Color bg, Color fg, bool outline});

/// Paleta de bloques en ciclo por índice: pine, ámbar, rosa y neutro con borde.
const List<ScheduleBlockPalette> scheduleBlockPalettes = [
  (bg: AppColors.pinePale, fg: AppColors.pineDeep, outline: false),
  (bg: AppColors.amberPale, fg: AppColors.amberDeep, outline: false),
  (bg: AppColors.rosePale, fg: AppColors.roseDeep, outline: false),
  (bg: AppColors.cardBg, fg: AppColors.ink, outline: true),
];

/// Colores del bloque número [index], cíclicos.
ScheduleBlockPalette scheduleBlockPaletteAt(int index) =>
    scheduleBlockPalettes[index % scheduleBlockPalettes.length];

/// Etiqueta de hora en formato 24 h: «00:00» … «23:00».
String scheduleHourLabel(int hour) => '${hour.toString().padLeft(2, '0')}:00';

/// Franja horaria de un bloque en el idioma activo: «10:00 – 12:00».
String scheduleTimeRange(BuildContext context, ScheduleEvent event) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final start = DateFormat.Hm(locale).format(event.start);
  final end = DateFormat.Hm(locale).format(event.end);
  return '$start – $end';
}
