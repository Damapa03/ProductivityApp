import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/text_styles.dart';
import '../../l10n/app_localizations.dart';

/// Marcador de posición para las pantallas del nav que aún no existen.
///
/// Muestra el icono de la pestaña a tamaño grande, el nombre de la pantalla y
/// un aviso, de modo que se lea como una pantalla real y no como un hueco.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.icon});

  /// Nombre de la pantalla, p. ej. «Agenda».
  final String title;

  /// Icono de la pestaña, reutilizado aquí a mayor tamaño.
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme(
                  data: const IconThemeData(
                    color: AppColors.inkFaint,
                    size: 40,
                  ),
                  child: icon,
                ),
                const SizedBox(height: 20),
                Text(title, style: AppTextStyles.eyebrow),
                const SizedBox(height: 6),
                Text(
                  l10n.comingSoonTitle,
                  style: AppTextStyles.screenTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.comingSoonBody,
                  style: AppTextStyles.subline,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
