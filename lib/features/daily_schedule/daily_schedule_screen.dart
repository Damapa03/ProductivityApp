import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';
import 'day_timeline.dart';

/// Pantalla «Daily Schedule»: plan del día actual sobre una línea de tiempo
/// con sus 24 horas (ver mockup 04).
///
/// Comparte cabecera con Daily Tasks: fecha del día (eyebrow) y título de la
/// pantalla. Al entrar, la línea de tiempo se desplaza para mostrar la franja
/// cercana a la hora actual.
class DailyScheduleScreen extends StatefulWidget {
  const DailyScheduleScreen({super.key});

  @override
  State<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends State<DailyScheduleScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToCurrentHour();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Tras el primer frame, desplaza la línea de tiempo hacia la hora actual
  /// (con dos horas de contexto arriba), limitado al máximo del recorrido.
  ///
  /// Se hace en el post-frame para que el lienzo ya tenga dimensiones.
  void _scrollToCurrentHour() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final now = DateTime.now();
      final target =
          ((now.hour - 2) * DayTimeline.hourHeight).clamp(0.0, double.infinity);
      final position = _scrollController.position;
      _scrollController.jumpTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    });
  }

  /// Fecha del día localizada («lunes, 28 septiembre») con mayúscula inicial.
  String _formattedDate(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatted = DateFormat('EEEE, d MMMM', locale).format(DateTime.now());
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              // Mismo margen superior y lateral que Daily Tasks para alinear
              // la cabecera con la línea de tiempo.
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formattedDate(context), style: AppTextStyles.eyebrow),
                  const SizedBox(height: 3),
                  Text(l10n.scheduleTitle, style: AppTextStyles.screenTitle),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: DayTimeline(controller: _scrollController),
            ),
          ],
        ),
      ),
    );
  }
}