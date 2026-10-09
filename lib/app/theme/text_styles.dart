import 'package:flutter/material.dart';

import 'palette.dart';

/// Familias tipográficas Flowly (Space Grotesk · IBM Plex Sans).
abstract final class AppFonts {
  static const String display = 'Space Grotesk';
  static const String body = 'IBM Plex Sans';
}

/// Escala tipográfica Flowly resuelta contra la [Palette] activa.
///
/// Los estilos ya no son `const` con el color incrustado: se piden con
/// [AppTextStyles.of] desde un `BuildContext` (o con [AppTextStyles.from]
/// cuando la paleta ya está resuelta, como en `AppTheme`) para que el texto
/// siga al tema claro u oscuro.
class AppTextStyles {
  /// Escala sobre una paleta concreta.
  const AppTextStyles(this.palette);

  /// Escala de la paleta registrada en [context].
  static AppTextStyles of(BuildContext context) =>
      AppTextStyles(Palette.of(context));

  /// Escala de una paleta ya resuelta.
  static AppTextStyles from(Palette palette) => AppTextStyles(palette);

  /// Paleta contra la que se resuelven los colores de los estilos.
  final Palette palette;

  TextStyle get headline => TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 1.08,
    letterSpacing: -0.015,
    color: palette.ink,
  );

  TextStyle get subline => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 14.5,
    height: 1.5,
    color: palette.inkSoft,
  );

  /// Título de pantalla tipo Daily Tasks (27px, Space Grotesk 700).
  TextStyle get screenTitle => TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 27,
    height: 1.15,
    letterSpacing: -0.01,
    color: palette.ink,
  );

  /// Nombre de columna del kanban.
  TextStyle get columnTitle => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.3,
    color: palette.ink,
  );

  /// Contador de tareas de una columna.
  TextStyle get columnCount => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 11.5,
    height: 1.3,
    color: palette.inkSoft,
  );

  /// Texto de una tarjeta de tarea.
  TextStyle get taskText => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
    height: 1.35,
    color: palette.ink,
  );

  /// Escritura libre de la lista negra (mockup 06): cada línea es un apunte.
  TextStyle get writingText => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.7,
    color: palette.ink,
  );

  /// Placeholder del área de escritura de la lista negra.
  TextStyle get writingHint => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.7,
    color: palette.inkFaint,
  );

  /// Aviso de columna vacía.
  TextStyle get emptyHint => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: palette.inkFaint,
  );

  TextStyle get eyebrow => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.3,
    letterSpacing: 0.04,
    color: palette.inkSoft,
  );

  TextStyle get wordmark => TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 19,
    height: 1.2,
    color: palette.ink,
  );

  TextStyle get fieldLabel => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12.5,
    height: 1.3,
    color: palette.inkSoft,
  );

  TextStyle get fieldInput => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 15.5,
    height: 1.3,
    color: palette.ink,
  );

  TextStyle get fieldError => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: palette.rose,
  );

  TextStyle get fieldPlaceholder => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 15.5,
    height: 1.3,
    color: palette.inkFaint,
  );

  TextStyle get buttonPrimary => TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.2,
    letterSpacing: 0.01,
    color: palette.onPrimary,
  );

  TextStyle get buttonSecondary => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 13.5,
    height: 1.2,
    color: palette.ink,
  );

  TextStyle get link => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 12.5,
    height: 1.3,
    color: palette.pine,
  );

  /// Opción del selector de vista (switcher, ver mockup 02b).
  TextStyle get segmented => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 13.5,
    height: 1.2,
    color: palette.inkSoft,
  );

  /// Nombre del estado dentro de la burbuja de la vista de lista.
  TextStyle get statusBadge => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 10.5,
    height: 1.2,
    color: palette.inkSoft,
  );

  /// Etiqueta de hora de la línea de tiempo de agenda (mockup 04).
  TextStyle get hourLabel => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 1,
    color: palette.inkFaint,
  );

  /// Nombre de una franja en la línea de tiempo (mockup 04).
  ///
  /// El color de texto lo fija la paleta del bloque.
  TextStyle get eventName => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 12.5,
    height: 1.25,
    color: palette.ink,
  );

  /// Franja horaria «inicio – fin» de un bloque de la línea de tiempo.
  TextStyle get eventTime => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 10.5,
    height: 1.2,
    color: palette.ink,
  );

  /// Sigla del día en la cabecera de la rejilla semanal (p. ej. «Mie»).
  TextStyle get weekDayName => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 10.5,
    height: 1.2,
    color: palette.inkSoft,
  );

  /// Número de día en la cabecera de la rejilla semanal (mockup 04b).
  TextStyle get weekDayNumber => TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.25,
    color: palette.ink,
  );

  /// Título de una franja en la rejilla semanal.
  ///
  /// Las columnas son estrechas, así que solo cabe el nombre: las horas las
  /// aporta la posición del bloque. El color lo fija la paleta.
  TextStyle get weekEventName => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 9.5,
    height: 1.2,
    color: palette.ink,
  );

  /// Nombre del mes y año sobre el calendario de hábitos (mockup 03).
  ///
  /// Va centrado y es algo más pequeño que [screenTitle]: el mes es un dato
  /// que acompaña a la rejilla, no el título de una sección.
  TextStyle get monthTitle => TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 23,
    height: 1.15,
    letterSpacing: -0.01,
    color: palette.ink,
  );

  /// Sigla del día sobre la rejilla mensual (p. ej. «L», «M», «X»).
  TextStyle get weekdayInitial => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.2,
    color: palette.inkSoft,
  );

  /// Número de día del calendario con todos sus hábitos cumplidos.
  TextStyle get dayDone => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.25,
    color: palette.paper,
  );

  /// Número de día del calendario al que le faltó algún hábito.
  TextStyle get dayMissed => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.25,
    color: palette.roseDeep,
  );

  /// Número de día del calendario que todavía no se ha cerrado.
  TextStyle get dayNeutral => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.25,
    color: palette.ink,
  );

  /// Número de día del calendario que aún no ha llegado.
  TextStyle get dayFuture => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.25,
    color: palette.inkSoft,
  );

  /// Título de la tarjeta de hábitos del día (mockup 03).
  TextStyle get habitCardTitle => TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.2,
    color: palette.ink,
  );

  /// Nombre de un hábito en la lista de checks del día.
  TextStyle get habitLabel => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
    height: 1.35,
    color: palette.ink,
  );

  /// Nombre de un hábito todavía pendiente: apagado para que se distinga
  /// del que ya está cumplido.
  TextStyle get habitLabelPending => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
    height: 1.35,
    color: palette.inkSoft,
  );

  /// Contador «2 de 4» de la lista de hábitos del día.
  TextStyle get habitProgress => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.2,
    color: palette.inkSoft,
  );

  /// Fecha del día cuyos hábitos muestra la lista, bajo su título.
  TextStyle get habitDay => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: palette.inkSoft,
  );

  /// Texto de la leyenda de colores del calendario.
  TextStyle get legendLabel => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: palette.inkSoft,
  );

  /// Iniciales dentro del avatar de la cabecera de la pantalla Perfil
  /// (mockup 07).
  TextStyle get profileInitials => TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 19,
    height: 1.2,
    color: palette.pineDeep,
  );

  /// Nombre junto al avatar en la pantalla Perfil (mockup 07).
  TextStyle get profileName => TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 16.5,
    height: 1.2,
    color: palette.ink,
  );

  /// Email bajo el nombre en la pantalla Perfil (mockup 07).
  TextStyle get profileEmail => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12.5,
    height: 1.3,
    color: palette.inkSoft,
  );

  /// Etiqueta de grupo («Cuenta», «Preferencias»…) sobre cada bloque de la
  /// pantalla Perfil (mockup 07).
  TextStyle get profileGroupLabel => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 11.5,
    height: 1.3,
    color: palette.inkSoft,
  );

  /// Texto de una fila de la pantalla Perfil (mockup 07).
  TextStyle get profileRowLabel => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 13.5,
    height: 1.3,
    color: palette.ink,
  );

  /// Valor a la derecha de una fila («2 vinculados», «Lunes», mockup 07).
  TextStyle get profileRowValue => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.3,
    color: palette.inkSoft,
  );

  /// Texto del botón «Cerrar sesión» (mockup 07).
  TextStyle get profileLogout => TextStyle(
    fontFamily: AppFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 13.5,
    height: 1.2,
    color: palette.rose,
  );
}
