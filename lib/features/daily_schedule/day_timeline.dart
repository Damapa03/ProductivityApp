import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';

/// Línea de tiempo del día actual con sus 24 horas (mockup 04).
///
/// Cada hora ocupa una fila de 56 px con su etiqueta (formato 24 h) pegada a
/// la izquierda, y el resto de la pista queda libre para futuros eventos. El
/// conjunto es desplazable en vertical.
class DayTimeline extends StatelessWidget {
  const DayTimeline({super.key, required this.controller});

  /// Controlador del desplazamiento vertical (para el scroll inicial de
  /// [DailyScheduleScreen] hacia la hora actual).
  final ScrollController controller;

  /// Altura de cada fila de hora (mockup 04): 56 px.
  static const double hourHeight = 56;

  /// Ancho de la columna de etiquetas de hora (mockup 04): 52 px.
  static const double hourLabelWidth = 52;

  /// Horas representadas en el día.
  static const int hoursCount = 24;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        key: const Key('day-timeline'),
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        child: Column(
          children: [
            for (var h = 0; h < hoursCount; h++)
              _HourRow(hour: h, height: hourHeight, labelWidth: hourLabelWidth),
          ],
        ),
      ),
    );
  }
}

/// Fila de una hora: etiqueta «HH:00» a la izquierda y pista vacía.
///
/// El borde superior dibuja la línea de cuadrícula; la primera fila no lleva
/// borde (como en el mockup). La etiqueta se sube 7 px para que cruce la
/// cuadrícula y se lea en la misma posición del mockup.
class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.hour,
    required this.height,
    required this.labelWidth,
  });

  final int hour;
  final double height;
  final double labelWidth;

  /// Etiqueta en formato 24 h: «00:00» … «23:00».
  String get _label => '${hour.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Pista de la hora (sin contenido por ahora, aparte de la cuadrícula).
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}