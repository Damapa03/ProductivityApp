import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/app/theme/colors.dart';
import 'package:productyivity_app/features/home/home_shell.dart';
import 'package:productyivity_app/l10n/app_localizations.dart';
import 'package:productyivity_app/widgets/time_blocks_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _harness() {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const HomeShell(ownerId: 'ana@flowly.com'),
  );
}

/// Iconos del set, en el orden del mockup 07. El índice 2 es el icono propio.
const List<Object> _icons = [
  Icons.view_list_outlined,
  Icons.calendar_month_outlined,
  TimeBlocksIcon,
  Icons.schedule_outlined,
  Icons.description_outlined,
  Icons.person_outline,
];

/// Item de la pestaña [index].
Finder _item(int index) => find.byKey(ValueKey('nav-item-$index'));

Finder _bar() => find.byKey(const Key('bottom-nav'));

/// Índice de la pestaña resaltada, o -1 si ninguna lo está.
///
/// El item activo es el único con relleno [AppColors.pinePale].
int _activeIndex(WidgetTester tester) {
  for (var i = 0; i < _icons.length; i++) {
    final decoration = tester
        .widget<AnimatedContainer>(
          find.descendant(
            of: _item(i),
            matching: find.byType(AnimatedContainer),
          ),
        )
        .decoration;
    if ((decoration as BoxDecoration?)?.color == AppColors.pinePale) return i;
  }
  return -1;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('el nav muestra los seis iconos del mockup', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    for (var i = 0; i < _icons.length; i++) {
      final finder = switch (_icons[i]) {
        final IconData icon => find.byIcon(icon),
        _ => find.byType(TimeBlocksIcon),
      };
      expect(
        find.descendant(of: _item(i), matching: finder),
        findsOneWidget,
        reason: 'la pestaña $i no muestra su icono',
      );
    }
  });

  testWidgets('los iconos del nav se pintan a 20 px', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    for (var i = 0; i < _icons.length; i++) {
      final icon = find.descendant(
        of: _item(i),
        matching: find.byType(TimeBlocksIcon),
      );
      final size = icon.evaluate().isNotEmpty
          ? tester.getSize(icon)
          : tester.getSize(
              find.descendant(of: _item(i), matching: find.byType(Icon)),
            );
      expect(size.height, 20.0, reason: 'icono de la pestaña $i');
    }
  });

  testWidgets('la barra y los items tienen las medidas del mockup', (
    tester,
  ) async {
    // Ancho del dispositivo del mockup; el reparto del Row depende de él.
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Barra de 64 con items de 38x38.
    expect(tester.getSize(_bar()).height, 64.0);
    for (var i = 0; i < _icons.length; i++) {
      expect(tester.getSize(_item(i)), const Size(38, 38));
    }

    // Reparto space-around: 6 items de 38 en 375 - 20 de margen = 355;
    // sobran 127, que se reparten como 10.58 de aire a cada lado del
    // primer item (127 / 6 / 2).
    expect(tester.getTopLeft(_item(0)).dx, closeTo(10 + 127 / 12, 0.1));
    // El último queda pegado al margen derecho, simétrico al primero.
    expect(375 - tester.getTopRight(_item(5)).dx, closeTo(10 + 127 / 12, 0.1));
  });

  testWidgets('arranca en Tareas y no muestra ningún marcador', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(_activeIndex(tester), 0);
    expect(find.text('Tareas diarias'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Próximamente'), findsNothing);
  });

  testWidgets('cada pestaña pendiente muestra su marcador', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Pestaña y nombre que debe verse al entrar.
    const pending = [
      (1, 'Hábitos'),
      (3, 'Timer'),
      (4, 'Black List'),
      (5, 'Perfil'),
    ];

    for (final (index, name) in pending) {
      await tester.tap(_item(index));
      await tester.pumpAndSettle();

      expect(_activeIndex(tester), index, reason: 'no se activó $name');
      expect(find.text(name), findsOneWidget);
      expect(find.text('Próximamente'), findsOneWidget);
      // El tablero ya no está a la vista.
      expect(find.text('Tareas diarias'), findsNothing);
    }
  });

  testWidgets('el marcador reutiliza el icono de su pestaña a 40 px', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(_item(1));
    await tester.pumpAndSettle();

    expect(_activeIndex(tester), 1);
    expect(find.text('Hábitos'), findsOneWidget);

    // El icono de Hábitos aparece dos veces: a 20 en el nav y a 40 en el
    // marcador.
    final icons = find.byIcon(Icons.calendar_month_outlined);
    expect(icons, findsNWidgets(2));
    final heights = [
      tester.getSize(icons.at(0)).height,
      tester.getSize(icons.at(1)).height,
    ]..sort();
    expect(heights, [20.0, 40.0]);
  });

  testWidgets('la pestaña Agenda muestra su línea de tiempo', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(_item(2));
    await tester.pumpAndSettle();

    expect(_activeIndex(tester), 2);
    expect(find.text('Plan de hoy'), findsOneWidget);
    expect(find.text('Próximamente'), findsNothing);
    // El icono de Agenda solo aparece en el nav (a 20 px): ya no hay marcador.
    final icons = find.byType(TimeBlocksIcon);
    expect(icons, findsOneWidget);
    expect(tester.getSize(icons).height, 20.0);
  });

  testWidgets('volver a Tareas conserva el estado del tablero', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Cambiar a la vista de lista para comprobar que se conserva.
    await tester.tap(find.text('Todas las tareas'));
    await tester.pumpAndSettle();

    // Ir a Perfil y volver.
    await tester.tap(_item(5));
    await tester.pumpAndSettle();
    expect(find.text('Próximamente'), findsOneWidget);

    await tester.tap(_item(0));
    await tester.pumpAndSettle();

    expect(_activeIndex(tester), 0);
    // La vista de lista sigue activa: el IndexedStack no la ha reconstruido.
    expect(find.text('Todas las tareas'), findsOneWidget);
    expect(find.text('Search'), findsNothing);
  });

  testWidgets('tocar la pestaña ya activa es un no-op', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(_item(0));
    await tester.pumpAndSettle();

    expect(_activeIndex(tester), 0);
    expect(find.text('Tareas diarias'), findsOneWidget);
  });

  testWidgets('cada item expone su nombre como etiqueta accesible', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    for (final name in [
      'Tareas',
      'Hábitos',
      'Agenda',
      'Timer',
      'Black List',
      'Perfil',
    ]) {
      expect(find.bySemanticsLabel(name), findsOneWidget);
    }

    handle.dispose();
  });
}
