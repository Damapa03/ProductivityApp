import 'package:flutter/material.dart';

import '../app/theme/colors.dart';
import '../app/theme/text_styles.dart';
import '../l10n/app_localizations.dart';

/// Flechas para retroceder y avanzar en el tiempo, con un atajo de vuelta al
/// día actual.
///
/// Companion del selector Día / Semana de la agenda: una flecha mueve el día
/// que se está mirando o, en modo semanal, la semana entera (siete días). Las
/// medidas salen del `.month-nav` del mockup 03, el único sitio del diseño
/// donde ya había navegación: botones circulares pequeños, con borde y glifo
/// apagado.
///
/// El botón «Hoy» solo aparece cuando no se está ya en hoy, de modo que volver
/// al día actual no ocupa sitio en el uso habitual. El texto de las flechas no
/// se pinta (solo hay sitio para los glifos); [isWeekView] únicamente cambia
/// el mensaje que ven los lectores de pantalla, para no anunciar «día» cuando
/// lo que avanza es una semana.
class StepNavigator extends StatelessWidget {
  const StepNavigator({
    super.key,
    required this.onPrevious,
    required this.onNext,
    this.onToday,
    this.isWeekView = false,
  });

  /// Notifica que se quiere ver el intervalo anterior.
  final VoidCallback onPrevious;

  /// Notifica que se quiere ver el intervalo siguiente.
  final VoidCallback onNext;

  /// Notifica que se quiere volver al día actual; `null` oculta el botón.
  final VoidCallback? onToday;

  /// Si la agenda está en modo semanal (las flechas mueven una semana entera).
  final bool isWeekView;

  /// Diámetro de los botones circulares (mockup 03).
  static const double buttonSize = 26;

  /// Separación entre los botones.
  static const double gap = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onToday != null) ...[
          _TodayButton(label: l10n.scheduleToday, onTap: onToday!),
          const SizedBox(width: gap),
        ],
        _StepButton(
          icon: Icons.chevron_left,
          tooltip: isWeekView ? l10n.schedulePreviousWeek : l10n.schedulePreviousDay,
          onPressed: onPrevious,
        ),
        const SizedBox(width: gap),
        _StepButton(
          icon: Icons.chevron_right,
          tooltip: isWeekView ? l10n.scheduleNextWeek : l10n.scheduleNextDay,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// Botón «Hoy»: devuelve al día actual, con el mismo contorno que las flechas.
class _TodayButton extends StatelessWidget {
  const _TodayButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('step-navigator-today'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(StepNavigator.buttonSize),
      child: Container(
        height: StepNavigator.buttonSize,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.pinePale,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(StepNavigator.buttonSize),
        ),
        child: Text(label, style: AppTextStyles.statusBadge),
      ),
    );
  }
}

/// Botón circular con una flecha.
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          key: ValueKey(
            icon == Icons.chevron_left
                ? 'step-navigator-previous'
                : 'step-navigator-next',
          ),
          width: StepNavigator.buttonSize,
          height: StepNavigator.buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line),
          ),
          child: Icon(icon, size: 16, color: AppColors.inkSoft),
        ),
      ),
    );
  }
}