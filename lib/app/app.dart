import 'package:flutter/material.dart';

import '../features/login/login_screen.dart';
import '../l10n/app_localizations.dart';
import 'theme/app_theme.dart';

/// Raíz de la aplicación Flowly.
class FlowlyApp extends StatelessWidget {
  const FlowlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flowly',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      // Español por defecto; el mecanismo permite conmutar a «en» (sin
      // control visual todavía).
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LoginScreen(),
    );
  }
}
