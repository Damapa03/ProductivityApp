import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/app/theme/app_theme.dart';
import 'package:productyivity_app/app/theme/colors.dart';
import 'package:productyivity_app/app/theme/palette.dart';
import 'package:productyivity_app/app/theme/text_styles.dart';

void main() {
  test('cada tema registra su paleta', () {
    expect(AppTheme.light.extension<Palette>(), Palette.light);
    expect(AppTheme.dark.extension<Palette>(), Palette.dark);
  });

  test('el fondo y la tipografía siguen a la paleta de cada tema', () {
    expect(AppTheme.light.scaffoldBackgroundColor, AppColors.paper);
    expect(AppTheme.dark.scaffoldBackgroundColor, AppColorsDark.paper);

    final darkStyles = AppTextStyles.from(Palette.dark);
    expect(darkStyles.screenTitle.color, AppColorsDark.ink);
    expect(darkStyles.subline.color, AppColorsDark.inkSoft);
  });

  testWidgets('Palette.of resuelve la paleta del tema activo', (tester) async {
    late Palette fromLight;
    late Palette fromDark;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            fromLight = Palette.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(fromLight, Palette.light);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) {
            fromDark = Palette.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    // El cambio de tema se anima; se espera a que termine la interpolación.
    await tester.pumpAndSettle();
    expect(fromDark, Palette.dark);
  });

  testWidgets('sin paleta registrada, Palette.of cae en la clara', (
    tester,
  ) async {
    late Palette resolved;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            resolved = Palette.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(resolved, Palette.light);
  });

  test('la paleta oscura invierte los pares de contraste base', () {
    // Texto claro sobre fondo oscuro (y al revés que en claro).
    expect(AppColorsDark.paper.computeLuminance(), lessThan(0.2));
    expect(AppColorsDark.ink.computeLuminance(), greaterThan(0.6));
    expect(AppColors.paper.computeLuminance(), greaterThan(0.6));
    expect(AppColors.ink.computeLuminance(), lessThan(0.2));
  });
}
