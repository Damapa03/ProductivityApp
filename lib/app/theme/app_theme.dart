import 'package:flutter/material.dart';

import 'palette.dart';
import 'text_styles.dart';

/// Temas claro y oscuro de Flowly (Material 3).
///
/// Los dos comparten el mismo armazón: solo cambian la [Palette] con la que se
/// resuelven los tokens y la [Brightness] del `ColorScheme`.
abstract final class AppTheme {
  /// Tema claro (paleta [Palette.light]).
  static ThemeData get light => _build(Palette.light, Brightness.light);

  /// Tema oscuro (paleta [Palette.dark]).
  static ThemeData get dark => _build(Palette.dark, Brightness.dark);

  static ThemeData _build(Palette palette, Brightness brightness) {
    final styles = AppTextStyles.from(palette);
    final colorScheme = brightness == Brightness.light
        ? ColorScheme.light(
            primary: palette.pine,
            onPrimary: palette.onPrimary,
            onPrimaryContainer: palette.pinePale,
            primaryContainer: palette.pinePale,
            onSecondaryContainer: palette.pineDeep,
            surface: palette.paper,
            onSurface: palette.ink,
            onSurfaceVariant: palette.inkSoft,
          )
        : ColorScheme.dark(
            primary: palette.pine,
            onPrimary: palette.onPrimary,
            onPrimaryContainer: palette.pinePale,
            primaryContainer: palette.pinePale,
            onSecondaryContainer: palette.pineDeep,
            surface: palette.paper,
            onSurface: palette.ink,
            onSurfaceVariant: palette.inkSoft,
          );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.paper,
      // Deja la paleta disponible para cualquier `Palette.of(context)`.
      extensions: [palette],
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: styles.headline,
        bodyMedium: styles.subline,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.pineDeep,
          foregroundColor: palette.onPrimary,
          minimumSize: const Size(0, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: styles.buttonPrimary,
        ),
      ),
      // Selectores de modo y tiempo del timer: se alinean con el color del
      // botón de inicio (FilledButton en `primary`, pine) para que toda la
      // pantalla comparta la misma gama. El segmento sin seleccionar usa la
      // variante clara (pinePale) para no competir con el seleccionado.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: palette.pinePale,
          foregroundColor: palette.pineDeep,
          selectedBackgroundColor: palette.pine,
          selectedForegroundColor: colorScheme.onPrimary,
          side: BorderSide(color: palette.line),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.pine,
          textStyle: styles.link,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        hintStyle: styles.fieldPlaceholder,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: true,
        fillColor: palette.cardBg,
      ),
      dividerTheme: DividerThemeData(
        color: palette.line,
        thickness: 1,
        space: 20,
      ),
      // La cabecera del selector de hora (hora : minutos) hereda por defecto
      // `onPrimaryContainer`, que en Flowly es `pinePale`: demasiado clara y
      // casi invisible sobre el fondo del diálogo. Se fuerza un tono oscuro
      // para que la hora y los minutos elegidos se lean bien.
      timePickerTheme: TimePickerThemeData(
        hourMinuteTextColor: palette.ink,
        timeSelectorSeparatorColor: WidgetStatePropertyAll(palette.inkSoft),
      ),
    );
  }
}
