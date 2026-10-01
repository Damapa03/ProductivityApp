import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/theme/text_styles.dart';

/// Cabecera común de las pantallas: la fecha de hoy y el nombre de la pantalla.
///
/// Reúne el formato de la fecha («lunes, 28 septiembre», con mayúscula
/// inicial), los estilos y los márgenes que ya compartían Tareas diarias, Plan
/// de hoy y Lista negra, para que cualquier pantalla que lo use mantenga la
/// misma alineación con el contenido que lleva debajo.
///
/// No lleva flecha de retroceso: la pantalla ya no es una ruta encima del
/// login, es una pestaña del shell.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.date});

  /// Nombre de la pantalla, p. ej. «Tareas diarias».
  final String title;

  /// Día que se muestra. Por defecto, hoy (útil en tests para fijar la fecha).
  final DateTime? date;

  /// Margen de la cabecera: 12 arriba —para que la fecha no quede pegada al
  /// borde, ya que en navegador el `SafeArea` no aporta aire— y 24 a los lados,
  /// la misma alineación que el selector de vista y el tablero.
  static const EdgeInsets padding = EdgeInsets.fromLTRB(24, 12, 24, 0);

  /// Separación con el contenido de debajo (selector, tablero o campo).
  static const double bottomSpacing = 18;

  /// Separación entre la fecha y el título.
  static const double titleSpacing = 3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formattedDate(context), style: AppTextStyles.eyebrow),
          const SizedBox(height: titleSpacing),
          Text(title, style: AppTextStyles.screenTitle),
          const SizedBox(height: bottomSpacing),
        ],
      ),
    );
  }

  /// Fecha localizada del día indicado («lunes, 28 septiembre») con mayúscula
  /// inicial, en el idioma activo en la app.
  String _formattedDate(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted =
        DateFormat('EEEE, d MMMM', locale).format(date ?? DateTime.now());
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}
