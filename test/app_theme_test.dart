import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/app/theme/app_theme.dart';
import 'package:productyivity_app/app/theme/colors.dart';

void main() {
  group('AppTheme — selector de hora', () {
    final theme = AppTheme.light;
    final pickerTheme = theme.timePickerTheme;

    test('la hora y los minutos de la cabecera usan tinta oscura', () {
      // La cabecera hereda por defecto onPrimaryContainer (pinePale), casi
      // invisible sobre el fondo del diálogo; debe forzarse tinta oscura.
      expect(pickerTheme.hourMinuteTextColor, AppColors.ink);
    });

    test('el separador entre hora y minutos usa tinta media', () {
      expect(pickerTheme.timeSelectorSeparatorColor, isNotNull);
      expect(
        pickerTheme.timeSelectorSeparatorColor!.resolve(const <WidgetState>{}),
        AppColors.inkSoft,
      );
    });
  });
}