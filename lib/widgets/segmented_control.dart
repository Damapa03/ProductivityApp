import 'package:flutter/material.dart';

import '../app/theme/palette.dart';
import '../app/theme/text_styles.dart';

/// Segmentado reutilizable: única opción activa a la vez y tocar la opción ya
/// activa es un no-op (ver mockups 02b y 04).
///
/// Sirve tanto al selector de vista del tablero («Por estado» / «Todas las
/// tareas») como al conmutador de la agenda («Día» / «Semana»). Quien lo usa
/// decide qué hace cada opción; por ejemplo, la agenda ignora las selecciones
/// de opciones sin funcionalidad.
class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.activeIndex,
    required this.onSelected,
  });

  /// Etiquetas de las opciones, en su orden de aparición.
  final List<String> options;

  /// Opción resaltada.
  final int activeIndex;

  /// Notifica el índice de la opción elegida (nunca la ya activa).
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final styles = AppTextStyles.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.cardBg,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: InkWell(
                // Tocar la opción activa es un no-op.
                onTap: i == activeIndex ? null : () => onSelected(i),
                borderRadius: BorderRadius.circular(6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == activeIndex
                        ? palette.pineDeep
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    options[i],
                    textAlign: TextAlign.center,
                    style: styles.segmented.copyWith(
                      color: i == activeIndex
                          ? palette.onPrimary
                          : palette.inkSoft,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}