import 'package:flutter/material.dart';

/// Icono de bloques de tiempo: dos barras apiladas de distinta longitud.
///
/// Se usa en la pestaña «Agenda» de la navegación inferior. No existe un
/// `IconData` de Material con esta forma (los candidatos más cercanos,
/// `view_agenda` y `align_horizontal_left`, tienen barras de igual longitud o
/// demasiado bajas), así que se dibuja con dos `Container` redondeados.
///
/// El diseño está calculado sobre un lienzo de 20×20 —el mismo de los Material
/// Symbols outlined que usa el resto del set— y escala con [size]: la barra
/// superior mide 16×5, la inferior 10.3×5 (manteniendo la proporción 14:9) y
/// quedan 4 de separación. Eso da una caja óptica de 16×14, dentro del rango
/// del resto de iconos (12–16 de ancho, 12–16 de alto), y ambas barras alineadas
/// a la izquierda para que se lean como bloques apilados.
///
/// Toma el color de [IconTheme], así que en la navegación inferior se pinta
/// solo del color activo o inactivo sin que haya que pasarle nada.
class TimeBlocksIcon extends StatelessWidget {
  const TimeBlocksIcon({super.key, this.size = 20});

  /// Lado del lienzo del icono; el diseño de referencia es 20.
  final double size;

  /// Lado del lienzo de referencia sobre el que están medidas las constantes.
  static const double _canvas = 20;
  static const double _barHeight = 5;
  static const double _barGap = 4;
  static const double _topBarWidth = 16;
  static const double _bottomBarWidth = 10.3;
  static const double _radius = 1.25;

  @override
  Widget build(BuildContext context) {
    final color =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    // Escala de las medidas de referencia al tamaño pedido.
    final k = size / _canvas;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // Alineadas a la izquierda: la de arriba marca el margen y la de
          // abajo se queda más corta a su derecha.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(_topBarWidth * k, color, k),
            SizedBox(height: _barGap * k),
            _bar(_bottomBarWidth * k, color, k),
          ],
        ),
      ),
    );
  }

  /// Barra redondeada de anchura [width].
  Widget _bar(double width, Color color, double scale) {
    return Container(
      width: width,
      height: _barHeight * scale,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_radius * scale),
      ),
    );
  }
}
