import 'package:flutter/material.dart';

/// Paleta Flowly (token `flowly-design-tokens.json`).
abstract final class AppColors {
  // Base
  static const Color paper = Color(0xFFEDEFEA);
  static const Color ink = Color(0xFF191C19);
  static const Color inkSoft = Color(0xFF565B54);
  static const Color inkFaint = Color(0xFF9CA097);
  static const Color line = Color(0xFFC9CDC3);
  static const Color lineFaint = Color(0xFFDDE0D6);
  static const Color cardBg = Color(0xFFF7F8F4);
  static const Color pine = Color(0xFF33564A);
  static const Color pineDeep = Color(0xFF22392F);
  static const Color pinePale = Color(0xFFDCE5DF);
  static const Color amber = Color(0xFFD9A441);
  static const Color amberPale = Color(0xFFF3E4C4);
  static const Color rose = Color(0xFFB5675C);
  static const Color rosePale = Color(0xFFF0DBD7);
  static const Color done = Color(0xFF4C7A62);
  static const Color donePale = Color(0xFFCBDDD1);
  static const Color missPale = Color(0xFFEFD9D4);
  static const Color futurePale = Color(0xFFE4E6DF);
  static const Color stageBg = Color(0xFFDADDD3);
  static const Color overviewBg = Color(0xFFC9CDBF);

  /// Icono inactivo de la navegación inferior (mockup 07).
  ///
  /// Más apagado que [inkFaint] a propósito: convive con el icono activo en
  /// pine y no debe competir con él.
  static const Color navInactive = Color(0xFFACB2A5);

  // Columnas del kanban (ver mockup 02).
  static const Color columnGray = Color(0xFF9AA79E);
  static const Color columnGrayPale = Color(0xFFE4E9E3);
  static const Color amberDeep = Color(0xFF8A6A22);
  static const Color roseDeep = Color(0xFF8C443A);

  /// Paleta de puntos de columna, en orden cíclico por índice.
  static const List<Color> columnDots = [
    columnGray, // Search (gris)
    rose, // TODO
    amber, // Doing
    pine, // Done
  ];
}
