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
}
