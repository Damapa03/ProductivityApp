import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/app/theme/colors.dart';
import 'package:productyivity_app/app/theme/theme_controller.dart';
import 'package:productyivity_app/data/profile_repository.dart';
import 'package:productyivity_app/features/profile/profile_screen.dart';
import 'package:productyivity_app/l10n/app_localizations.dart';
import 'package:productyivity_app/models/profile.dart';
import 'package:productyivity_app/widgets/screen_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _harness({String ownerId = 'ana@flowly.com'}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ProfileScreen(ownerId: ownerId),
  );
}

/// Chip de icono a la izquierda de cada fila.
final Finder _chips = find.byKey(const Key('profile-row-chip'));

/// Interrupor de la fila indicada («reminders» o «dark»).
Finder _toggle(String id) => find.byKey(Key('profile-toggle-$id'));

/// Fija el tamaño del dispositivo del mockup para que el scroll quepa.
void _mockupSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Color de carril de un interruptor.
Color _toggleColor(WidgetTester tester, Finder toggle) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(of: toggle, matching: find.byType(AnimatedContainer)),
  );
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // El tema es global ([ThemeController]): cada prueba arranca en claro.
    ThemeController.instance.value = ThemeMode.light;
  });

  testWidgets('muestra el título «Perfil» sin la fecha del ScreenHeader', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.byType(ScreenHeader), findsNothing);
  });

  testWidgets('muestra el perfil guardado con su avatar de iniciales', (
    tester,
  ) async {
    await LocalProfileRepository().save(
      Profile(
        name: 'Daniel Marín',
        email: 'damapa2003@gmail.com',
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Daniel Marín'), findsOneWidget);
    expect(find.text('damapa2003@gmail.com'), findsOneWidget);
    expect(find.text('DM'), findsOneWidget);
  });

  testWidgets('sin perfil guardado usa el email de sesión', (tester) async {
    await tester.pumpWidget(_harness(ownerId: 'ana@flowly.com'));
    await tester.pumpAndSettle();

    // El nombre cae en el propio email, que se pinta también como email.
    expect(find.text('ana@flowly.com'), findsNWidgets(2));
    expect(find.text('AN'), findsOneWidget);
  });

  testWidgets('reproduce los grupos y las filas del mockup', (tester) async {
    _mockupSize(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    for (final text in [
      'Cuenta',
      'Editar perfil',
      'Cambiar contraseña',
      'Calendarios vinculados',
      '2 vinculados',
      'Preferencias',
      'Recordatorios diarios',
      'Modo oscuro',
      'La semana empieza en',
      'Lunes',
      'Soporte',
      'Centro de ayuda',
      'Cerrar sesión',
    ]) {
      expect(find.text(text), findsOneWidget, reason: 'falta «$text»');
    }
  });

  testWidgets('cada fila lleva un chip de 30×30 con icono de 16 px', (
    tester,
  ) async {
    _mockupSize(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Siete filas: tres de Cuenta, tres de Preferencias y una de Soporte.
    expect(_chips, findsNWidgets(7));
    expect(tester.getSize(_chips.first), const Size(30, 30));

    final icon = find.descendant(of: _chips.first, matching: find.byType(Icon));
    expect(tester.getSize(icon), const Size(16, 16));
  });

  testWidgets('las filas navegables tienen ripple y las del interruptor no', (
    tester,
  ) async {
    _mockupSize(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(
      find.ancestor(of: find.text('Editar perfil'), matching: find.byType(InkWell)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: find.text('Lunes'), matching: find.byType(InkWell)),
      findsOneWidget,
    );
    // Las filas de interruptor son su control: no arrastran un ripple propio.
    expect(
      find.ancestor(of: find.text('Modo oscuro'), matching: find.byType(InkWell)),
      findsNothing,
    );
  });

  testWidgets('los interruptores alternan de pine a line al tocarlos', (
    tester,
  ) async {
    _mockupSize(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Arrancan como en el mockup: recordatorios activos, modo oscuro inactivo.
    expect(_toggleColor(tester, _toggle('reminders')), AppColors.pine);
    expect(_toggleColor(tester, _toggle('dark')), AppColors.line);

    await tester.tap(_toggle('dark'));
    await tester.pumpAndSettle();
    expect(_toggleColor(tester, _toggle('dark')), AppColors.pine);

    await tester.tap(_toggle('reminders'));
    await tester.pumpAndSettle();
    expect(_toggleColor(tester, _toggle('reminders')), AppColors.line);
  });

  testWidgets('el interruptor de modo oscuro cambia el tema de la app', (
    tester,
  ) async {
    _mockupSize(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(ThemeController.instance.value, ThemeMode.light);

    await tester.tap(_toggle('dark'));
    await tester.pumpAndSettle();

    // No es estado local: cambia el tema compartido por toda la app.
    expect(ThemeController.instance.value, ThemeMode.dark);
    expect(_toggleColor(tester, _toggle('dark')), AppColors.pine);

    await tester.tap(_toggle('dark'));
    await tester.pumpAndSettle();
    expect(ThemeController.instance.value, ThemeMode.light);
  });

  testWidgets('los interruptores exponen su estado a lectores de pantalla', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    _mockupSize(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    bool isToggled(Finder finder) =>
        tester.getSemantics(finder).getSemanticsData().flagsCollection.isToggled ==
        Tristate.isTrue;

    expect(isToggled(_toggle('reminders')), isTrue);
    expect(isToggled(_toggle('dark')), isFalse);

    await tester.tap(_toggle('dark'));
    await tester.pumpAndSettle();
    expect(isToggled(_toggle('dark')), isTrue);

    // El nodo fusiona la etiqueta de la fila con el estado del interruptor.
    expect(find.bySemanticsLabel('Modo oscuro'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('«Cerrar sesión» pinta el texto en rose y el borde en line', (
    tester,
  ) async {
    _mockupSize(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final label = find.text('Cerrar sesión');
    expect(tester.widget<Text>(label).style?.color, AppColors.rose);

    // El único InkWell de esa cadena es el del botón; su hijo es la caja
    // con el borde.
    final inkWell = tester.widget<InkWell>(
      find.ancestor(of: label, matching: find.byType(InkWell)),
    );
    final box = inkWell.child! as Container;
    final border = (box.decoration! as BoxDecoration).border! as Border;
    expect(border.top.color, AppColors.line);
    expect(border.left.color, AppColors.line);
  });

  testWidgets('el contenido baja hasta «Cerrar sesión» en un 375×812', (
    tester,
  ) async {
    _mockupSize(tester);
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    final rect = tester.getRect(find.text('Cerrar sesión'));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(812));
  });
}
