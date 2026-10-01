import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:productyivity_app/app/theme/text_styles.dart';
import 'package:productyivity_app/l10n/app_localizations.dart';
import 'package:productyivity_app/widgets/screen_header.dart';

/// Fecha de hoy tal y como la pinta la cabecera, con mayúscula inicial.
String _today(Locale locale) {
  final formatted = DateFormat(
    'EEEE, d MMMM',
    locale.toLanguageTag(),
  ).format(DateTime.now());
  return formatted[0].toUpperCase() + formatted.substring(1);
}

/// Marca lo que en las pantallas reales va justo debajo de la cabecera
/// (selector de vista, tablero o campo de escritura).
const Key _below = Key('below-header');

Widget _harness({
  required String title,
  Locale locale = const Locale('es'),
  DateTime? date,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(title: title, date: date),
          const SizedBox(height: 20, key: _below),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('muestra la fecha de hoy y el nombre de la pantalla', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(title: 'Tareas diarias'));
    await tester.pumpAndSettle();

    expect(find.text(_today(const Locale('es'))), findsOneWidget);
    expect(find.text('Tareas diarias'), findsOneWidget);
  });

  testWidgets('usa los estilos de eyebrow y de título de pantalla', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(title: 'Lista negra'));
    await tester.pumpAndSettle();

    final date = tester.widget<Text>(find.text(_today(const Locale('es'))));
    expect(date.style, AppTextStyles.eyebrow);

    final title = tester.widget<Text>(find.text('Lista negra'));
    expect(title.style, AppTextStyles.screenTitle);
  });

  testWidgets('la fecha sigue al idioma de la app', (tester) async {
    await tester.pumpWidget(
      _harness(title: 'Lista negra', locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    expect(find.text(_today(const Locale('en'))), findsOneWidget);
    expect(find.text(_today(const Locale('es'))), findsNothing);
  });

  testWidgets('admite fijar el día para poder comprobarlo', (tester) async {
    await tester.pumpWidget(
      _harness(title: 'Plan de hoy', date: DateTime(2026, 3, 14)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sábado, 14 marzo'), findsOneWidget);
    expect(find.text(_today(const Locale('es'))), findsNothing);
  });

  testWidgets('deja aire arriba, a los lados y con el contenido de debajo', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(title: 'Tareas diarias'));
    await tester.pumpAndSettle();

    // 12 px de aire para que la fecha no quede pegada al borde y 24 a los
    // lados, la misma alineación que el resto de contenidos de las pantallas.
    expect(
      tester.getTopLeft(find.text(_today(const Locale('es')))).dy,
      ScreenHeader.padding.top,
    );
    expect(tester.getTopLeft(find.text('Tareas diarias')).dx, 24.0);

    // 3 px entre fecha y título, y 18 de separación con lo que viene debajo.
    final dateBottom = tester.getBottomLeft(find.text(_today(const Locale('es')))).dy;
    final titleTop = tester.getTopLeft(find.text('Tareas diarias')).dy;
    expect(titleTop - dateBottom, ScreenHeader.titleSpacing);

    final titleBottom = tester.getBottomLeft(find.text('Tareas diarias')).dy;
    expect(
      tester.getTopLeft(find.byKey(_below)).dy - titleBottom,
      ScreenHeader.bottomSpacing,
    );
  });

  testWidgets('no lleva flecha de retroceso (es una pestaña del shell)', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(title: 'Tareas diarias'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });
}
