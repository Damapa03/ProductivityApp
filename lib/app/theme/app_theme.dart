import 'package:flutter/material.dart';

import 'colors.dart';
import 'text_styles.dart';

/// Tema claro de Flowly (Material 3).
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.pine,
        onPrimary: Color(0xFFF3F4EF),
        onPrimaryContainer: AppColors.pinePale,
        primaryContainer: AppColors.pinePale,
        onSecondaryContainer: AppColors.pineDeep,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.inkSoft,
      ),
      scaffoldBackgroundColor: AppColors.paper,
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: AppTextStyles.headline,
        bodyMedium: AppTextStyles.subline,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pineDeep,
          foregroundColor: const Color(0xFFF3F4EF),
          minimumSize: const Size(0, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: AppTextStyles.buttonPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pine,
          textStyle: AppTextStyles.link,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        hintStyle: AppTextStyles.fieldPlaceholder,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: true,
        fillColor: AppColors.cardBg,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 20,
      ),
    );
  }
}
