import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productyivity_app/app/theme/colors.dart';
import 'package:productyivity_app/widgets/time_blocks_icon.dart';

Widget _harness({double size = 20, Color? color}) {
  return MaterialApp(
    home: IconTheme(
      data: IconThemeData(color: color ?? AppColors.ink),
      child: Center(child: TimeBlocksIcon(size: size)),
    ),
  );
}

/// Las dos barras del icono, en orden (arriba y abajo).
List<Size> _bars(WidgetTester tester) {
  final finder = find.descendant(
    of: find.byType(TimeBlocksIcon),
    matching: find.byType(Container),
  );
  return [tester.getSize(finder.at(0)), tester.getSize(finder.at(1))];
}

void main() {
  testWidgets('a 20 px las barras miden 16x5 y 10.3x5', (tester) async {
    await tester.pumpWidget(_harness());

    expect(_bars(tester), const [Size(16, 5), Size(10.3, 5)]);
  });

  testWidgets('el lienzo es de 20x20 y las barras quedan centradas', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    expect(tester.getSize(find.byType(TimeBlocksIcon)), const Size(20, 20));

    // Coordenadas relativas al lienzo, para no depender del viewport.
    final canvas = tester.getTopLeft(find.byType(TimeBlocksIcon));
    final top = tester.getTopLeft(
      find
          .descendant(
            of: find.byType(TimeBlocksIcon),
            matching: find.byType(Container),
          )
          .at(0),
    );
    // La barra superior (16 de ancho) deja 2 a cada lado.
    expect(top.dx - canvas.dx, 2.0);
    // 4 de separación y 5 de alto por barra = 14, centrado en 20 -> 3.
    expect(top.dy - canvas.dy, 3.0);
  });

  testWidgets('las barras están separadas 4 px y alineadas a la izquierda', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    final bars = find.descendant(
      of: find.byType(TimeBlocksIcon),
      matching: find.byType(Container),
    );
    final topBottom = tester.getBottomLeft(bars.at(0)).dy;
    final bottomTop = tester.getTopLeft(bars.at(1)).dy;
    expect(bottomTop - topBottom, 4.0);

    // Comparten margen izquierdo, como los bloques de tiempo del mockup.
    expect(tester.getTopLeft(bars.at(1)).dx, tester.getTopLeft(bars.at(0)).dx);
  });

  testWidgets('la barra de abajo es más corta que la de arriba', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    final bars = _bars(tester);
    // Proporción 14:9, la del mockup.
    expect(bars[1].width / bars[0].width, closeTo(9 / 14, 0.001));
  });

  testWidgets('todas las medidas escalan con el tamaño', (tester) async {
    await tester.pumpWidget(_harness(size: 40));

    expect(_bars(tester), const [Size(32, 10), Size(20.6, 10)]);
    expect(tester.getSize(find.byType(TimeBlocksIcon)), const Size(40, 40));
  });

  testWidgets('toma el color del IconTheme', (tester) async {
    await tester.pumpWidget(_harness(color: AppColors.pineDeep));

    final bars = find.descendant(
      of: find.byType(TimeBlocksIcon),
      matching: find.byType(Container),
    );
    for (var i = 0; i < 2; i++) {
      final decoration =
          tester.widget<Container>(bars.at(i)).decoration! as BoxDecoration;
      expect(decoration.color, AppColors.pineDeep);
      expect(decoration.borderRadius, BorderRadius.circular(1.25));
    }
  });
}
