import 'package:flutter/material.dart';

import 'colors.dart';

/// Familias tipográficas Flowly (Space Grotesk · IBM Plex Sans).
abstract final class AppFonts {
  static const String display = 'Space Grotesk';
  static const String body = 'IBM Plex Sans';
}

/// Escala tipográfica base.
abstract final class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 1.08,
    letterSpacing: -0.015,
    color: AppColors.ink,
  );

  static const TextStyle subline = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 14.5,
    height: 1.5,
    color: AppColors.inkSoft,
  );

  /// Título de pantalla tipo Daily Tasks (27px, Space Grotesk 700).
  static const TextStyle screenTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 27,
    height: 1.15,
    letterSpacing: -0.01,
    color: AppColors.ink,
  );

  /// Nombre de columna del kanban.
  static const TextStyle columnTitle = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.3,
    color: AppColors.ink,
  );

  /// Contador de tareas de una columna.
  static const TextStyle columnCount = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 11.5,
    height: 1.3,
    color: AppColors.inkSoft,
  );

  /// Texto de una tarjeta de tarea.
  static const TextStyle taskText = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
    height: 1.35,
    color: AppColors.ink,
  );

  /// Escritura libre de la lista negra (mockup 06): cada línea es un apunte.
  static const TextStyle writingText = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.7,
    color: AppColors.ink,
  );

  /// Placeholder del área de escritura de la lista negra.
  static const TextStyle writingHint = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.7,
    color: AppColors.inkFaint,
  );

  /// Aviso de columna vacía.
  static const TextStyle emptyHint = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: AppColors.inkFaint,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.3,
    letterSpacing: 0.04,
    color: AppColors.inkSoft,
  );

  static const TextStyle wordmark = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 19,
    height: 1.2,
    color: AppColors.ink,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12.5,
    height: 1.3,
    color: AppColors.inkSoft,
  );

  static const TextStyle fieldInput = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 15.5,
    height: 1.3,
    color: AppColors.ink,
  );

  static const TextStyle fieldError = TextStyle(
  fontFamily: AppFonts.body,
  fontWeight: FontWeight.w400,
  fontSize: 12,
  height: 1.3,
  color: AppColors.rose,
);

static const TextStyle fieldPlaceholder = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 15.5,
    height: 1.3,
    color: AppColors.inkFaint,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.2,
    letterSpacing: 0.01,
    color: Color(0xFFF3F4EF),
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 13.5,
    height: 1.2,
    color: AppColors.ink,
  );

  static const TextStyle link = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 12.5,
    height: 1.3,
    color: AppColors.pine,
  );

  /// Opción del selector de vista (switcher, ver mockup 02b).
  static const TextStyle segmented = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 13.5,
    height: 1.2,
    color: AppColors.inkSoft,
  );

  /// Nombre del estado dentro de la burbuja de la vista de lista.
  static const TextStyle statusBadge = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 10.5,
    height: 1.2,
    color: AppColors.inkSoft,
  );

  /// Etiqueta de hora de la línea de tiempo de agenda (mockup 04).
  static const TextStyle hourLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 1,
    color: AppColors.inkFaint,
  );

  /// Nombre de una franja en la línea de tiempo (mockup 04).
  ///
  /// El color de texto lo fija la paleta del bloque.
  static const TextStyle eventName = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 12.5,
    height: 1.25,
    color: AppColors.ink,
  );

  /// Franja horaria «inicio – fin» de un bloque de la línea de tiempo.
  static const TextStyle eventTime = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 10.5,
    height: 1.2,
    color: AppColors.ink,
  );

  /// Sigla del día en la cabecera de la rejilla semanal (p. ej. «Mie»).
  static const TextStyle weekDayName = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 10.5,
    height: 1.2,
    color: AppColors.inkSoft,
  );

  /// Número de día en la cabecera de la rejilla semanal (mockup 04b).
  static const TextStyle weekDayNumber = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.25,
    color: AppColors.ink,
  );

  /// Título de una franja en la rejilla semanal.
  ///
  /// Las columnas son estrechas, así que solo cabe el nombre: las horas las
  /// aporta la posición del bloque. El color lo fija la paleta.
  static const TextStyle weekEventName = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 9.5,
    height: 1.2,
    color: AppColors.ink,
  );

  /// Nombre del mes y año sobre el calendario de hábitos (mockup 03).
  ///
  /// Va centrado y es algo más pequeño que [screenTitle]: el mes es un dato
  /// que acompaña a la rejilla, no el título de una sección.
  static const TextStyle monthTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 23,
    height: 1.15,
    letterSpacing: -0.01,
    color: AppColors.ink,
  );

  /// Sigla del día sobre la rejilla mensual (p. ej. «L», «M», «X»).
  static const TextStyle weekdayInitial = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.2,
    color: AppColors.inkSoft,
  );

  /// Número de día del calendario con todos sus hábitos cumplidos.
  static const TextStyle dayDone = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.25,
    color: AppColors.paper,
  );

  /// Número de día del calendario al que le faltó algún hábito.
  static const TextStyle dayMissed = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.25,
    color: AppColors.roseDeep,
  );

  /// Número de día del calendario que todavía no se ha cerrado.
  static const TextStyle dayNeutral = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.25,
    color: AppColors.ink,
  );

  /// Número de día del calendario que aún no ha llegado.
  static const TextStyle dayFuture = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.25,
    color: AppColors.inkSoft,
  );

  /// Nombre de un hábito en la lista de checks del día.
  static const TextStyle habitLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
    height: 1.35,
    color: AppColors.ink,
  );

  /// Nombre de un hábito todavía pendiente: apagado para que se distinga
  /// del que ya está cumplido.
  static const TextStyle habitLabelPending = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
    height: 1.35,
    color: AppColors.inkSoft,
  );

  /// Contador «2 de 4» de la lista de hábitos del día.
  static const TextStyle habitProgress = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.2,
    color: AppColors.inkSoft,
  );

  /// Fecha del día cuyos hábitos muestra la lista, bajo su título.
  static const TextStyle habitDay = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: AppColors.inkSoft,
  );

  /// Texto de la leyenda de colores del calendario.
  static const TextStyle legendLabel = TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: AppColors.inkSoft,
  );
}
